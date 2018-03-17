//
//  ICArvatoProductViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 19/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICArvatoProductViewController.h"
#import "ICFormRowSeparator.h"
#import "ICFormRowButton.h"
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import "ICFormRowLabel.h"
#import "ICSeparatorTableViewCell.h"
#import "ICFormRowReadonlyReview.h"
#import "ICFormRowList.h"
#import "ICDetailedPickerViewCell.h"
#import <IngenicoConnectSDK/ICPaymentAmountOfMoney.h>
#import <IngenicoConnectSDK/ICDisplayElement.h>
#import "ICFormRowSwitch.h"
#import "ICFormRowsConverter.h"
#import "ICReadonlyReviewTableViewCell.h"
#import "ICFormRowCurrency.h"
#import "ICFormRowDate.h"
#import <IngenicoConnectSDK/ICValidationErrorTermsAndConditions.h>
@interface ICArvatoProductViewController ()
@property (nonatomic, assign) NSInteger failCount;
@property (nonatomic, assign) BOOL didFind;
@property (nonatomic, assign) BOOL hasFullData;
@property (nonatomic, assign) BOOL hasLookup;
@property (nonatomic, assign) NSUInteger installmentPlanFields;
@property (nonatomic, retain) NSString *errorMessageText;
@end
@implementation ICArvatoProductViewController
- (instancetype)initWithPaymentItem:(NSObject<ICPaymentItem> *)paymentItem Session:(ICSession *)session context:(ICPaymentContext *)context viewFactory:(ICViewFactory *)viewFactory accountOnFile:(ICAccountOnFile *)accountsOnFile
{
    self = [super init];
    if (self) {
        super.paymentItem = paymentItem;
        super.session = session;
        super.context = context;
        super.viewFactory = viewFactory;
        super.accountOnFile = accountsOnFile;
        self.errorMessageText = @"";
        NSArray *paymentProductFields = paymentItem.fields.paymentProductFields;
        BOOL hasLookup = false;
        for (ICPaymentProductField *field in paymentProductFields) {
            BOOL usedForLookup = field.usedForLookup;
            hasLookup =  (hasLookup || usedForLookup);
        }
        _hasLookup = hasLookup;
    }
    return self;
}
-(void)reload
{
    [self initializeFormRows];
    [self addExtraRows];
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        [self.tableView reloadData];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [CATransaction commit];
}
-(void)setHasLookup:(BOOL)hasLookup
{
    _hasLookup = hasLookup;
    [self reload];
}
- (ICTableViewCell *)formRowCellForRow:(ICFormRow *)row atIndexPath:(NSIndexPath *)indexPath {
    ICTableViewCell *cell = nil;
    if ([row isKindOfClass:[ICFormRowSeparator class]]) {
        cell = [self cellForSeparator:(ICFormRowSeparator *)row tableView:self.tableView];
    }
    else {
        cell = [super formRowCellForRow:row atIndexPath:indexPath];
    }
    return cell;
}
- (ICSeparatorTableViewCell *)cellForSeparator:(ICFormRowSeparator *)row tableView:(UITableView *)tableView {
    ICSeparatorTableViewCell *cell = (ICSeparatorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICSeparatorTableViewCell reuseIdentifier]];
    
    cell.separatorText = row.text;
    
    return cell;
    
}
- (void)updatePickerCell:(ICPickerViewTableViewCell *)cell row: (ICFormRowList *)list
{
    if (![cell isKindOfClass:[ICDetailedPickerViewCell class]]) {
        return;
    }
    id error = list.paymentProductField.errors.firstObject;
    if (error) {
        ((ICDetailedPickerViewCell *)cell).errorMessage = [ICFormRowsConverter errorMessageForError:error withCurrency:NO];
    }
    else {
        ((ICDetailedPickerViewCell *)cell).errorMessage = @"";

    }
}
- (void)pickerView:(ICPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [super pickerView: pickerView didSelectRow:row inComponent:component];
    
    if (self.validation) {
        [self.inputData validate];
    }
    [self updateFormRows];
    // Update row height for picker
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
- (void)searchButtonTapped {
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.inputData.paymentItem.fields.paymentProductFields.count];
    for (ICPaymentProductField *field in self.inputData.paymentItem.fields.paymentProductFields) {
        if (field.usedForLookup) {
            NSString *identifier = field.identifier;
            NSString *value = [self.inputData unmaskedValueForField:identifier];
            NSDictionary *param = @{@"key": identifier, @"value": value};
            [values addObject:param];
        }
    }
    [self.session customerDetailsForProductId:self.initialPaymentProduct.identifier withLookupValues:values countryCode:self.context.countryCode success:^(ICCustomerDetails *details) {
        self.didFind = YES;
        NSString *installmentId = [self.inputData unmaskedValueForField:@"installmentId"];
        NSString *termsAndConditions = [self.inputData unmaskedValueForField:@"termsAndConditions"];
        NSMutableArray *identifiers = self.initialPaymentProduct.fields.paymentProductFields;
        NSMutableDictionary *lookupFields = [NSMutableDictionary dictionary];
        for (ICPaymentProductField *field in identifiers) {
            if ([field usedForLookup]) {
                [lookupFields setObject:[self.inputData unmaskedValueForField:field.identifier] forKey:field.identifier];
            }
        }
        [self.inputData removeAllFieldValues];
        for (NSString *key in lookupFields) {
            [self.inputData setValue:lookupFields[key] forField:key];

        }
        [self.inputData setValue:installmentId forField:@"installmentId"];
        [self.inputData setValue:termsAndConditions forField:@"termsAndConditions"];
        
        for (NSString *key in details.values) {
            NSString *value = details.values[key];
            [self.inputData setValue:value forField:key];
        }
        // We still want to display the summary if the terms are not accepted yet
        [self validateExceptFields:[NSSet setWithObjects:@"termsAndConditions", @"installmentId", nil]];
        if (self.inputData.errors.count == 0) {
            self.hasFullData = YES;
        }
        [self reload];
    } failure:^(NSError *error) {
        
        self.failCount += 1;
        NSDictionary *details = error.userInfo[@"com.ingenicoconnect.responseBody"][@"errors"][0];
        NSString *errorId = details[@"id"];
        if (self.failCount >= 10) {
            self.errorMessageText = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.result.failed.tooMuch", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Too much", @"");
        }
        else if ([errorId isEqualToString:@"PARAMETER_NOT_FOUND_IN_REQUEST"]) {
            self.errorMessageText = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.result.failed.errors.missingValue", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Too much", @"");
            NSString *propertyString = details[@"propertyName"];
            NSRange range1 = [propertyString rangeOfString:@"'" options:NSBackwardsSearch];
            NSRange restRange = NSMakeRange(0, range1.location);
            NSRange range2 = [propertyString rangeOfString:@"'" options:NSBackwardsSearch range:restRange];
            
            // Exclude he "'" character
            range2.location += 1;
            if (range1.location != NSNotFound && range2.location != NSNotFound) {
                NSRange propertyRange = NSMakeRange(range2.location, range1.location - range2.location);
                NSString *property = [propertyString substringWithRange:propertyRange];
                NSString *labelKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.label", [self.paymentItem identifier], property];
                NSString *labelValue = NSLocalizedStringFromTableInBundle(labelKey, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil);
                if ([labelKey isEqualToString:labelValue] == YES) {
                    labelKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.label", property];
                    labelValue = NSLocalizedStringFromTableInBundle(labelKey, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil);
                }

                self.errorMessageText = [self.errorMessageText stringByReplacingOccurrencesOfString:@"{propertyName}" withString:labelValue];
            }
        }
        else {
            self.errorMessageText = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.result.failed.invalidData", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Too much", @"");
        }
        self.didFind = false;
        [self reload];
        
    }];
}
- (void)cancelSearchButtonTapped {
    self.didFind = YES;
    [self reload];
}
- (void)editInformationButtonTapped {
    self.hasFullData = NO;
    [self reload];
}
- (void)searchAgainButtonTapped {
    self.didFind = NO;
    self.hasFullData = NO;
    self.failCount = 0;
    [self reload];
}
-(void)initializeFormRows
{
    [super initializeFormRows];
//    int fieldNum = 0;
    int propertyNum = 0;
    NSEnumerator *enumerator = [self.formRows objectEnumerator];
    ICFormRow *row = [enumerator nextObject];
    NSMutableArray<ICFormRow *> *newFormRows = [[NSMutableArray alloc]init];
    while (row) {
        // Find first label
        if (!([row isKindOfClass:[ICFormRowLabel class]] || [row isKindOfClass:[ICFormRowSwitch class]])) {
            row = [enumerator nextObject];
            continue;
        }
        NSMutableArray<ICFormRow *> *propertyRows = [[NSMutableArray alloc] init];
        ICFormRow *label = row;
        // Collect all rows until the next label
        while ((row = [enumerator nextObject]) && !([row isKindOfClass:[ICFormRowLabel class]] || [row isKindOfClass:[ICFormRowSwitch class]])) {
            [propertyRows addObject:row];
        }
        ICPaymentProductField  *item = self.inputData.paymentItem.fields.paymentProductFields[propertyNum];
        
        
        if ([[item identifier] isEqualToString:@"installmentId"]) {
            self.installmentPlanFields = [propertyRows count] + 1;

            for (ICFormRow *nonLabelRow in propertyRows) {
                [newFormRows insertObject:nonLabelRow atIndex:0];
            }
            [newFormRows insertObject:label atIndex:0];
        }
        else if ([item usedForLookup]) {
            if (self.installmentPlanFields > 0) {
                for (ICFormRow *nonLabelRow in propertyRows) {
                    [newFormRows insertObject:nonLabelRow atIndex:self.installmentPlanFields];
                }
                [newFormRows insertObject:label atIndex:self.installmentPlanFields];
            }
            else {
                for (ICFormRow *nonLabelRow in propertyRows) {
                    [newFormRows insertObject:nonLabelRow atIndex:0];
                }
                [newFormRows insertObject:label atIndex:0];

            }
        }
        else {
            [newFormRows addObject:label];
            for (ICFormRow *nonLabelRow in [propertyRows reverseObjectEnumerator]) {
                [newFormRows addObject:nonLabelRow];
            }
        }
        if (self.hasLookup && !self.didFind) {
            BOOL isVisible = (item.usedForLookup && !self.hasFullData) || [item.identifier isEqualToString:@"installmentId"];
            label.isEnabled = isVisible;
            for (ICFormRow *nonLabelRow in propertyRows) {
                nonLabelRow.isEnabled = isVisible;
            }
        }
        else {
            label.isEnabled = !self.hasFullData || [item.identifier isEqualToString:@"installmentId"];
            for (ICFormRow *nonLabelRow in propertyRows) {
                nonLabelRow.isEnabled = !self.hasFullData || [item.identifier isEqualToString:@"installmentId"];

            }
            // Show terms and conditions in readonly mode too
            if ([item.identifier isEqualToString:@"termsAndConditions"]) {
                if (self.hasFullData) {
                    label.isEnabled = YES;
                }
            }
        }
        propertyNum += 1;
    }
    for (ICFormRow *row in newFormRows) {
        if ([row isKindOfClass:[ICFormRowList class]] && ![[((ICFormRowList *)row).items objectAtIndex:0].value isEqualToString:@"-1"] && [((ICFormRowList *)row).paymentProductField.identifier isEqualToString:@"installmentId"]) {
            ICValueMappingItem *placeholderItem = [[ICValueMappingItem alloc]init];
            NSString *placeHolder = NSLocalizedStringFromTableInBundle(@"gc.general.paymentProductFields.installmentId.placeholder", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil);
            placeholderItem.displayName = placeHolder;
            placeholderItem.value = @"-1";
            ICFormRowList *formRowList = ((ICFormRowList *)row);
            [formRowList.items insertObject:placeholderItem atIndex:0];
            NSInteger rowIndex = 0;
            NSInteger selectedRow = 0;
            if ([[self.inputData maskedValueForField:@"installmentId"] isEqualToString:@""]) {
                [self.inputData setValue:@"-1" forField:@"installmentId"];

            }
            for (ICValueMappingItem *item in formRowList.items) {
                if (item.value != nil) {
                    if ([item.value isEqualToString:[self.inputData maskedValueForField:@"installmentId"]]) {
                        selectedRow = rowIndex;
                    }
                }
                ++rowIndex;
            }
            formRowList.selectedRow = selectedRow;
            [self.inputData setValue:formRowList.items[selectedRow].value forField:@"installmentId"];
        }
    }
    if ([[self.inputData unmaskedValueForField:@"termsAndConditions"] length] == 0) {
        [self.inputData setValue:@"false" forField:@"termsAndConditions"];
    }
    

    self.formRows = newFormRows;
}

- (void)registerReuseIdentifiers {
    [super registerReuseIdentifiers];
    [self.tableView registerClass:[ICSeparatorTableViewCell class] forCellReuseIdentifier:[ICSeparatorTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICDetailedPickerViewCell class] forCellReuseIdentifier:[ICDetailedPickerViewCell reuseIdentifier]];

    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICFormRow *row = [self.formRows objectAtIndex:indexPath.row];
    BOOL notEnabled = ![row isEnabled];
    if (notEnabled) {
        return 0;
    }
    if ([row isKindOfClass:[ICFormRowList class]]) {
        ICFormRowList *listRow = (ICFormRowList *)row;
        NSUInteger max = listRow.items[listRow.selectedRow].displayElements.count * ([UIFont systemFontSize] + 2);
        if (max > 0) {
            max += 10;
        }
        CGFloat errorHeight = 0;
        
        if ([listRow.paymentProductField.errors firstObject] && self.validation) {
            NSAttributedString *str = [[NSAttributedString alloc] initWithString: [ICFormRowsConverter errorMessageForError:[listRow.paymentProductField.errors firstObject]   withCurrency: false]];
            errorHeight = ceil([str boundingRectWithSize:CGSizeMake(MIN(self.tableView.frame.size.width, 320), CGFLOAT_MAX) options: NSStringDrawingUsesLineFragmentOrigin context: nil].size.height);
        }

        return max  + [ICDetailedPickerViewCell pickerHeight] + errorHeight + 5;
    }

    if ([row isKindOfClass:[ICFormRowReadonlyReview class]]) {
        //return [[ICReadonlyReviewTableViewCell labelAttributedStringForData:((ICFormRowReadonlyReview *)row).data inWidth:self.tableView.frame.size.width] boundingRectWithSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 20;
        //return ((ICFormRowReadonlyReview *)row).data.count * 17.0;
        return [ICReadonlyReviewTableViewCell cellHeightForData:((ICFormRowReadonlyReview *)row).data inWidth:tableView.frame.size.width];
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (ICPickerViewTableViewCell *)cellForList:(ICFormRowList *)row tableView:(UITableView *)tableView
{
    ICDetailedPickerViewCell *cell = (ICDetailedPickerViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICDetailedPickerViewCell reuseIdentifier]];
    cell.delegate = self;
    cell.dataSource = self;
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [currencyFormatter setCurrencyCode:self.context.amountOfMoney.currencyCode];
    
    
    for (ICValueMappingItem *m in row.items) {
        NSString *amountAsString = nil;
        NSString *numberOfInstallments = nil;
        NSUInteger i = 0;
        NSUInteger displayElementIndex = NSNotFound;
        for (ICDisplayElement *el in m.displayElements) {
            if ([el.identifier isEqualToString:@"displayName"]) {
                displayElementIndex = i;
            }
            if ([el.identifier isEqualToString:@"installmentAmount"]) {
                amountAsString = [currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[el.value doubleValue]/100.0]];
            }
            if ([el.identifier isEqualToString:@"numberOfInstallments"]) {
                numberOfInstallments = el.value;
            }
            if (!amountAsString)  {
                continue;
            }
            if (!numberOfInstallments) {
                continue;
            }
            NSString *selectionMessageValueWithPlaceholders = NSLocalizedStringFromTableInBundle(@"gc.general.paymentProductFields.installmentId.selectionTextTemplate", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil);

            NSString *selectionMessageValueWithPlaceholder = [selectionMessageValueWithPlaceholders stringByReplacingOccurrencesOfString:@"{installmentAmount}" withString:amountAsString];
            NSString *selectionMessage = [selectionMessageValueWithPlaceholder stringByReplacingOccurrencesOfString:@"{numberOfInstallments}" withString:numberOfInstallments];
            m.displayName = selectionMessage;
            if (displayElementIndex != NSNotFound) {
                m.displayElements[displayElementIndex].value = m.displayName;
            }
            i += 1;
        }
    }
    cell.items = row.items;
    cell.fieldIdentifier = row.paymentProductField.identifier;
    cell.currencyFormatter = currencyFormatter;
    id error = row.paymentProductField.errors.firstObject;
    if (error && self.validation) {
        cell.errorMessage = [ICFormRowsConverter errorMessageForError:error withCurrency:NO];
    }
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentFormatter.locale = [NSLocale localeWithLocaleIdentifier:self.context.locale];
    percentFormatter.minimumFractionDigits = 0;
    percentFormatter.maximumFractionDigits = 3;
    cell.percentFormatter = percentFormatter;
    cell.selectedRow = row.selectedRow;
    return cell;
}
- (void)updateSwitchCell:(ICSwitchTableViewCell *)cell row: (ICFormRowSwitch *)row {
    // Add error messages for cells
    if (row.field == nil) {
        return;
    }
    ICValidationError *error = [row.field.errors firstObject];
    if ([[[row field] identifier] isEqualToString:@"termsAndConditions"]) {
        NSInteger errorNum = [row.field.errors indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[ICValidationErrorTermsAndConditions class]]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (errorNum != NSNotFound) {
            error = row.field.errors[errorNum];
        }
    }
    if (error != nil) {
        cell.errorMessage = [ICFormRowsConverter errorMessageForError: error withCurrency: NO];
    } else {
        cell.errorMessage = nil;
    }
}

- (void) addExtraRows
{
    NSString *labelText = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.label", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Your billing details", @"");
    ICFormRowLabel *label = [[ICFormRowLabel alloc]init];
    label.isEnabled = self.hasLookup;
    label.bold = YES;
    label.text = labelText;
    [self.formRows insertObject:label atIndex:self.installmentPlanFields];
    
    ICFormRowTooltip *tooltip = [[ICFormRowTooltip alloc]init];
    tooltip.text = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.tooltipText", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"", @"");
    label.tooltip = tooltip;
    [self.formRows insertObject:tooltip atIndex:self.installmentPlanFields + 1];
    
    ICFormRowSeparator *separator = [[ICFormRowSeparator alloc]init];
    separator.isEnabled = self.installmentPlanFields > 0;
    [self.formRows insertObject:separator atIndex:self.installmentPlanFields]; // Insert after installment plan

    
    ICFormRowReadonlyReview *reviewRow = [[ICFormRowReadonlyReview alloc]init];
    NSMutableDictionary<NSString *, NSString *> *filteredData = [NSMutableDictionary dictionary];
    for (NSString *key in self.inputData.fields) {
        if ( [key isEqualToString:@"installmentId"]) {
            continue;
        }
        BOOL shouldBeInReview = NO;
        for (ICBasicPaymentProduct *product in self.paymentItem.fields.paymentProductFields) {
            if ([key isEqualToString:product.identifier]) {
                shouldBeInReview = YES;
            }
        }
        if (shouldBeInReview) {
            filteredData[key] = [self.inputData maskedValueForField:key];
        }
    }
    reviewRow.isEnabled = self.hasFullData;
    [reviewRow setData:filteredData];
    [self.formRows addObject:reviewRow];

    NSString *searchAgainButtonTitle = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.buttons.searchAgain", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Search Again", @"Title of the enter manually button on the payment product screen.");
    ICFormRowButton *searchAgainButtonFormRow = [[ICFormRowButton alloc]init];
    searchAgainButtonFormRow.title = searchAgainButtonTitle;
    searchAgainButtonFormRow.target = self;
    searchAgainButtonFormRow.isEnabled = (self.hasLookup && self.hasFullData) && self.failCount < 10;
    searchAgainButtonFormRow.action = @selector(searchAgainButtonTapped);
    searchAgainButtonFormRow.buttonType = ICButtonTypePrimary;
    [self.formRows addObject:searchAgainButtonFormRow];

    NSString *editInformationButtonTitle = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.buttons.editInformation", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Edit Information", @"Title of the search button on the payment product screen.");
    ICFormRowButton *editInformationButtonFormRow = [[ICFormRowButton alloc]init];
    editInformationButtonFormRow.title = editInformationButtonTitle;
    editInformationButtonFormRow.target = self;
    editInformationButtonFormRow.buttonType = ICButtonTypeSecondary;
    editInformationButtonFormRow.action = @selector(editInformationButtonTapped);
    editInformationButtonFormRow.isEnabled =  [self hasFullData] && (self.failCount < 10 || [self didFind]);
    [self.formRows addObject:editInformationButtonFormRow];
    
    
    NSUInteger lastLookupIndex = 0;
    NSInteger i = -1;
    for (ICFormRow *fr in self.formRows) {
        i += 1;
        if ([fr isKindOfClass:[ICFormRowSwitch class]]) {
            if (((ICFormRowSwitch *)fr).field.usedForLookup) {
                lastLookupIndex = i;
                if ([self.formRows[i + 1] isKindOfClass:[ICFormRowTooltip class]]) {
                    lastLookupIndex += 1;
                }
            }
        } else if ([fr isKindOfClass:[ICFormRowList class]]) {
            if (((ICFormRowList *)fr).paymentProductField.usedForLookup) {
                lastLookupIndex = i;
                if ([self.formRows[i + 1] isKindOfClass:[ICFormRowTooltip class]]) {
                    lastLookupIndex += 1;
                }
            }
        } else if ([fr isKindOfClass:[ICFormRowDate class]]) {
            if (((ICFormRowDate *)fr).paymentProductField.usedForLookup) {
                lastLookupIndex = i;
                if ([self.formRows[i + 1] isKindOfClass:[ICFormRowTooltip class]]) {
                    lastLookupIndex += 1;
                }
            }
        } else if ([fr isKindOfClass:[ICFormRowTextField class]]) {
            if (((ICFormRowTextField *)fr).paymentProductField.usedForLookup) {
                lastLookupIndex = i;
                if ([self.formRows[i + 1] isKindOfClass:[ICFormRowTooltip class]]) {
                    lastLookupIndex += 1;
                }
            }
        } else if ([fr isKindOfClass:[ICFormRowCurrency class]]) {
            if (((ICFormRowCurrency *)fr).paymentProductField.usedForLookup) {
                lastLookupIndex = i;
                if ([self.formRows[i + 1] isKindOfClass:[ICFormRowTooltip class]]) {
                    lastLookupIndex += 1;
                }
            }
        }
    }



    NSString *badMessageTitleEarly = self.errorMessageText;
    ICFormRowLabel *badMessageEarlyRow = [[ICFormRowLabel alloc]init];
    badMessageEarlyRow.text = badMessageTitleEarly;
    badMessageEarlyRow.isEnabled = self.hasLookup && !self.didFind && !self.hasFullData && self.failCount > 0;
    [self.formRows insertObject:badMessageEarlyRow atIndex: lastLookupIndex + 1];
    
    
    NSString *searchButtonTitle = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.buttons.search", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Search", @"Title of the search button on the payment product screen.");
    ICFormRowButton *searchButtonFormRow = [[ICFormRowButton alloc]init];
    searchButtonFormRow.title = searchButtonTitle;
    searchButtonFormRow.target = self;
    searchButtonFormRow.action = @selector(searchButtonTapped);
    searchButtonFormRow.isEnabled = self.hasLookup && !self.hasFullData && self.failCount < 10;
    [self.formRows insertObject:searchButtonFormRow atIndex: lastLookupIndex + 2];

    
    NSString *cancelSearchButtonTitle = NSLocalizedStringWithDefaultValue(@"gc.app.paymentProductDetails.searchConsumer.buttons.enterInformation", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Enter manually", @"Title of the enter manually button on the payment product screen.");
    ICFormRowButton *cancelSearchButtonFormRow = [[ICFormRowButton alloc]init];
    cancelSearchButtonFormRow.title = cancelSearchButtonTitle;
    cancelSearchButtonFormRow.target = self;
    cancelSearchButtonFormRow.isEnabled = self.hasLookup && !self.didFind && !self.hasFullData;
    cancelSearchButtonFormRow.action = @selector(cancelSearchButtonTapped);
    cancelSearchButtonFormRow.buttonType = ICButtonTypeSecondary;
    [self.formRows insertObject:cancelSearchButtonFormRow atIndex: lastLookupIndex + 3];

    
    ICFormRowSeparator *paymentSeparator = [[ICFormRowSeparator alloc]init];
    paymentSeparator.isEnabled = YES;
    [self.formRows addObject:paymentSeparator];

    // Terms and conditions should be displayed just before the Pay button the ReadonlyReview row
    NSUInteger termsAndConditionsIndex = [self.formRows indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL * stop) {
        if ([obj isKindOfClass:[ICFormRowSwitch class]]) {
            ICFormRowSwitch *switchRow = obj;
            return [switchRow.field.identifier isEqualToString:@"termsAndConditions"];
        }
        return NO;
    }];
    if (termsAndConditionsIndex != NSNotFound) {
        ICFormRowSwitch *termsAndConditionsRow = [self.formRows objectAtIndex:termsAndConditionsIndex];
        termsAndConditionsRow.isEnabled = YES;
        [self.formRows removeObjectAtIndex:termsAndConditionsIndex];
        [self.formRows addObject:termsAndConditionsRow];
    }
    
    [super addExtraRows];
    
    NSEnumerator *enumerator = self.formRows.reverseObjectEnumerator;
    ICFormRow *cancelButton = ((ICFormRow *)[enumerator nextObject]);
    cancelButton.isEnabled = YES; // Enable cancel button
    ICFormRow *payButton = ((ICFormRow *)[enumerator nextObject]);
    payButton.isEnabled = YES; // Enable pay button

}
@end
