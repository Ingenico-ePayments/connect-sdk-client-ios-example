//
//  ICPaymentProductViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICAppConstants.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectExample/ICPaymentProductViewController.h>
#import <IngenicoConnectExample/ICFormRowsConverter.h>
#import <IngenicoConnectExample/ICFormRow.h>
#import <IngenicoConnectExample/ICFormRowTextField.h>
#import <IngenicoConnectExample/ICFormRowCurrency.h>
#import <IngenicoConnectExample/ICFormRowSwitch.h>
#import <IngenicoConnectExample/ICFormRowList.h>
#import <IngenicoConnectExample/ICFormRowButton.h>
#import <IngenicoConnectExample/ICFormRowLabel.h>
#import <IngenicoConnectExample/ICFormRowErrorMessage.h>
#import <IngenicoConnectExample/ICFormRowTooltip.h>
#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICSummaryTableHeaderView.h>
#import <IngenicoConnectExample/ICMerchantLogoImageView.h>
#import <IngenicoConnectSDK/ICPaymentAmountOfMoney.h>
#import <IngenicoConnectExample/ICFormRowCoBrandsSelection.h>
#import <IngenicoConnectSDK/ICIINDetail.h>
#import <IngenicoConnectExample/ICPaymentProductsTableRow.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectExample/ICFormRowCoBrandsExplanation.h>
#import <IngenicoConnectExample/ICPaymentProductInputData.h>
#import "ICFormRowReadonlyReview.h"
#import "ICReadonlyReviewTableViewCell.h"
#import "ICDatePickerTableViewCell.h"
#import "ICFormRowDate.h"
@interface ICPaymentProductViewController () <UITextFieldDelegate, ICDatePickerTableViewCellDelegate, ICSwitchTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *tooltipRows;
@property (nonatomic) BOOL rememberPaymentDetails;
@property (strong, nonatomic) ICSummaryTableHeaderView *header;
@property (strong, nonatomic) UITextPosition *cursorPositionInCreditCardNumberTextField;
@property (nonatomic) BOOL validation;
@property (nonatomic, strong) ICIINDetailsResponse *iinDetailsResponse;
@property (nonatomic, assign) BOOL coBrandsCollapsed;
@property (strong, nonatomic) NSBundle *sdkBundle;

@end

@implementation ICPaymentProductViewController
- (instancetype)init

{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
        self.context.forceBasicFlow = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([self.tableView respondsToSelector:@selector(setDelaysContentTouches:)] == YES) {
        self.tableView.delaysContentTouches = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [[ICMerchantLogoImageView alloc] init];
    
    self.rememberPaymentDetails = NO;
    
    [self initializeHeader];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)] == YES) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self initializeTapRecognizer];
    self.tooltipRows = [[NSMutableArray alloc] init];
    self.validation = NO;
    self.confirmedPaymentProducts = [[NSMutableSet alloc] init];
    
    self.inputData = [ICPaymentProductInputData new];
    self.inputData.paymentItem = self.paymentItem;
    self.inputData.accountOnFile = self.accountOnFile;
    if ([self.paymentItem isKindOfClass:[ICPaymentProduct class]]) {
        ICPaymentProduct *product = (ICPaymentProduct *) self.paymentItem;
        [self.confirmedPaymentProducts addObject:product.identifier];
        self.initialPaymentProduct = product;
    }
    
    [self initializeFormRows];
    [self addExtraRows];
    
    self.switching = NO;
    self.coBrandsCollapsed = YES;
    
    [self registerReuseIdentifiers];
}

- (void)registerReuseIdentifiers {
    [self.tableView registerClass:[ICTextFieldTableViewCell class] forCellReuseIdentifier:[ICTextFieldTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICButtonTableViewCell class] forCellReuseIdentifier:[ICButtonTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICCurrencyTableViewCell class] forCellReuseIdentifier:[ICCurrencyTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICSwitchTableViewCell class] forCellReuseIdentifier:[ICSwitchTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICDatePickerTableViewCell class] forCellReuseIdentifier:[ICDatePickerTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICLabelTableViewCell class] forCellReuseIdentifier:[ICLabelTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICPickerViewTableViewCell class] forCellReuseIdentifier:[ICPickerViewTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICReadonlyReviewTableViewCell class] forCellReuseIdentifier:[ICReadonlyReviewTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICErrorMessageTableViewCell class] forCellReuseIdentifier:[ICErrorMessageTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICTooltipTableViewCell class] forCellReuseIdentifier:[ICTooltipTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICPaymentProductTableViewCell class] forCellReuseIdentifier:[ICPaymentProductTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICCoBrandsSelectionTableViewCell class] forCellReuseIdentifier:[ICCoBrandsSelectionTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICCOBrandsExplanationTableViewCell class] forCellReuseIdentifier:[ICCOBrandsExplanationTableViewCell reuseIdentifier]];
}

- (void)initializeTapRecognizer
{
    UITapGestureRecognizer *tapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped)];
    tapScrollView.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapScrollView];
}

- (void)tableViewTapped
{
//    for (ICFormRow *element in self.formRows) {
//        if ([element class] == [ICFormRowTextField class]) {
//            ICFormRowTextField *formRowTextField = (ICFormRowTextField *)element;
//            if ([formRowTextField.textField isFirstResponder] == YES) {
//                [formRowTextField.textField resignFirstResponder];
//            }
//        } else if ([element class] == [ICFormRowCurrency class]) {
//            ICFormRowCurrency *formRowCurrency = (ICFormRowCurrency *)element;
//            if ([formRowCurrency.integerTextField isFirstResponder] == YES) {
//                [formRowCurrency.integerTextField resignFirstResponder];
//            }
//            if ([formRowCurrency.fractionalTextField isFirstResponder] == YES) {
//                [formRowCurrency.fractionalTextField resignFirstResponder];
//            }
//        }
//    }
}

- (void)initializeHeader
{
    NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    self.header = (ICSummaryTableHeaderView *)[self.viewFactory tableHeaderViewWithType:ICSummaryTableHeaderViewType frame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
    self.header.summary = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTableInBundle(@"gc.app.general.shoppingCart.total", kICSDKLocalizable, sdkBundle, @"Description of the amount header.")];
    NSNumber *amountAsNumber = [[NSNumber alloc] initWithFloat:self.amount / 100.0];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencyCode:self.context.amountOfMoney.currencyCode];
    NSString *amountAsString = [numberFormatter stringFromNumber:amountAsNumber];
    self.header.amount = amountAsString;
    self.header.securePayment = NSLocalizedStringFromTableInBundle(@"gc.app.general.securePaymentText", kICSDKLocalizable, sdkBundle, @"Text indicating that a secure payment method is used.");
    self.tableView.tableHeaderView = self.header;
}

- (void)addExtraRows
{
    // Add remember me switch
      ICFormRowSwitch *switchFormRow = [[ICFormRowSwitch alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.rememberMe", kICSDKLocalizable, self.sdkBundle, @"Explanation of the switch for remembering payment information.") isOn:self.rememberPaymentDetails target:self action: @selector(switchChanged:)];
    switchFormRow.isEnabled = false;
    [self.formRows addObject:switchFormRow];
    
    ICFormRowTooltip *switchFormRowTooltip = [ICFormRowTooltip new];
    switchFormRowTooltip.text = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.rememberMe.tooltip", kICSDKLocalizable, self.sdkBundle, @"");
    switchFormRow.tooltip = switchFormRowTooltip;
    [self.formRows addObject:switchFormRowTooltip];
    
    // Add pay and cancel button
    NSString *payButtonTitle = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.payButton", kICSDKLocalizable, self.sdkBundle, @"");
    ICFormRowButton *payButtonFormRow = [[ICFormRowButton alloc] initWithTitle: payButtonTitle target: self action: @selector(payButtonTapped)];
    payButtonFormRow.isEnabled = [self.paymentItem isKindOfClass:[ICPaymentProduct class]];
    [self.formRows addObject:payButtonFormRow];
    
    NSString *cancelButtonTitle = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.cancelButton", kICSDKLocalizable, self.sdkBundle, @"");
    ICFormRowButton *cancelButtonFormRow = [[ICFormRowButton alloc] initWithTitle: cancelButtonTitle target: self action: @selector(cancelButtonTapped)];
    cancelButtonFormRow.buttonType = ICButtonTypeSecondary;
    cancelButtonFormRow.isEnabled = true;
    [self.formRows addObject:cancelButtonFormRow];
}

- (void)initializeFormRows
{
    ICFormRowsConverter *mapper = [ICFormRowsConverter new];
    NSMutableArray *formRows = [mapper formRowsFromInputData: self.inputData viewFactory: self.viewFactory confirmedPaymentProducts: self.confirmedPaymentProducts];
    
    NSMutableArray *formRowsWithTooltip = [NSMutableArray new];
    for (ICFormRow *row in formRows) {
        [formRowsWithTooltip addObject:row];
        if (row != nil && [row isKindOfClass: [ICFormRowWithInfoButton class]]) {
            ICFormRowWithInfoButton *infoButtonRow = (ICFormRowWithInfoButton *)row;
            if (infoButtonRow.tooltip != nil) {
                ICFormRowTooltip *tooltipRow = infoButtonRow.tooltip;
                [formRowsWithTooltip addObject:tooltipRow];
            }
        }
    }
    
    self.formRows = formRowsWithTooltip;
}

- (void)updateFormRowsWithValidation:(BOOL)validation tooltipRows:(NSArray *)tooltipRows confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts
{
//    ICFormRowsConverter *mapper = [[ICFormRowsConverter alloc] init];
//    NSArray *rows = [mapper formRowsFromInputData:self.inputData iinDetailsResponse:self.iinDetailsResponse validation:validation viewFactory:self.viewFactory confirmedPaymentProducts:confirmedPaymentProducts];
//    NSMutableArray *formRows = [[NSMutableArray alloc] initWithArray:rows];
//    
//    if ([self.paymentItem isKindOfClass:[ICPaymentProduct class]]) {
//        NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
//        ICPaymentProduct *product = (ICPaymentProduct *) self.paymentItem;
//        if (product.allowsTokenization == YES && product.autoTokenized == NO && self.accountOnFile == nil) {
//            ICFormRowSwitch *switchFormRow = [[ICFormRowSwitch alloc] init];
//            switchFormRow.switchControl = (ICSwitch *) [self.viewFactory switchWithType:ICSwitchType];
//            switchFormRow.text = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.rememberMe", kICSDKLocalizable, sdkBundle, @"Explanation of the switch for remembering payment information.");
//            switchFormRow.switchControl.on = self.rememberPaymentDetails;
//            
//            
//            switchFormRow.showInfoButton = YES;
//            switchFormRow.tooltipIdentifier = @"RememberMeTooltip";
//            switchFormRow.tooltipText = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.rememberMe.tooltip", kICSDKLocalizable, sdkBundle, nil);
//            [formRows addObject:switchFormRow];
//        }
//    }
//    
//    NSMutableArray *formRowsWithTooltip = [NSMutableArray new];
//    for (ICFormRow *row in formRows) {
//        [formRowsWithTooltip addObject:row];
//        if ([row class] == [ICFormRowTextField class]) {
//            ICFormRowTextField *textFieldRow = (ICFormRowTextField *)row;
//            
//            if ([textFieldRow.paymentProductField.identifier isEqualToString:@"cardNumber"]) {
//                textFieldRow.textField.text = [textFieldRow.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                [self addCoBrandFormsInFormRows:formRowsWithTooltip iinDetailsResponse:self.iinDetailsResponse];
//            }
//        }
//        if ([[row class] isSubclassOfClass:[ICFormRowWithInfoButton class]]) {
//            ICFormRowWithInfoButton *infoButtonRow = (ICFormRowWithInfoButton *)row;
//            for (ICFormRowTooltip *tooltipRow in tooltipRows) {
//                if ([tooltipRow.tooltipIdentifier isEqualToString:infoButtonRow.tooltipIdentifier]) {
//                    [formRowsWithTooltip addObject:tooltipRow];
//                }
//            }
//        }
//    }
//    
//    self.formRows = formRowsWithTooltip;
//    NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
//    
//    ICFormRowButton *payButtonFormRow = [[ICFormRowButton alloc] init];
//    NSString *payButtonTitle = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.payButton", kICSDKLocalizable, sdkBundle, @"Title of the pay button on the payment product screen.");
//    UIButton* payButton = [self.viewFactory buttonWithType:ICPrimaryButtonType];
//    [payButton setTitle:payButtonTitle forState:UIControlStateNormal];
//    [payButton addTarget:self action:@selector(payButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    payButtonFormRow.button = payButton;
//    [self.formRows addObject:payButtonFormRow];
//    
//    ICFormRowButton *cancelButtonFormRow = [[ICFormRowButton alloc] init];
//    NSString *cancelButtonTitle = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.cancelButton", kICSDKLocalizable, sdkBundle, @"Title of the cancel button on the payment product screen.");
//    UIButton* cancelButton = [self.viewFactory buttonWithType:ICSecondaryButtonType];
//    [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
//    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    cancelButtonFormRow.button = cancelButton;
//    [self.formRows addObject:cancelButtonFormRow];
}

- (void)addCoBrandFormsInFormRows:(NSMutableArray *)formRows iinDetailsResponse:(ICIINDetailsResponse *)iinDetailsResponse {
    NSMutableArray *coBrands = [NSMutableArray new];
    for (ICIINDetail *coBrand in iinDetailsResponse.coBrands) {
        if (coBrand.isAllowedInContext) {
            [coBrands addObject:coBrand.paymentProductId];
        }
    }
    if (coBrands.count > 1) {
        if (!self.coBrandsCollapsed) {
            NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
            
            //Add explanation row
            ICFormRowCoBrandsExplanation *explanationRow = [ICFormRowCoBrandsExplanation new];
            [formRows addObject:explanationRow];
            
            //Add row for selection coBrands
            for (NSString *id in coBrands) {
                ICPaymentProductsTableRow *row = [[ICPaymentProductsTableRow alloc] init];
                row.paymentProductIdentifier = id;
                
                NSString *paymentProductKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.name", id];
                NSString *paymentProductValue = NSLocalizedStringFromTableInBundle(paymentProductKey, kICSDKLocalizable, sdkBundle, nil);
                row.name = paymentProductValue;
                
                ICAssetManager *assetManager = [ICAssetManager new];
                UIImage *logo = [assetManager logoImageForPaymentItem:id];
                row.logo = logo;
                
                [formRows addObject:row];
            }
        }
        
        ICFormRowCoBrandsSelection *toggleCoBrandRow = [ICFormRowCoBrandsSelection new];
        [formRows addObject:toggleCoBrandRow];
    }
}

-(void)switchToPaymentProduct:(NSString *)paymentProductId {
    if (paymentProductId != nil) {
        [self.confirmedPaymentProducts addObject:paymentProductId];
    }
    if (paymentProductId == nil) {
        if ([self.confirmedPaymentProducts containsObject:self.paymentItem.identifier]) {
            [self.confirmedPaymentProducts removeObject:self.paymentItem.identifier];
        }
        [self updateFormRows];
    }
    else if ([paymentProductId isEqualToString:self.paymentItem.identifier]) {
        [self updateFormRows];
    }
    else if (self.switching == NO) {
        self.switching = YES;
        [self.session paymentProductWithId:paymentProductId context:self.context success:^(ICPaymentProduct *paymentProduct) {
            self.paymentItem = paymentProduct;
            self.inputData.paymentItem = paymentProduct;
            [self updateFormRows];
            self.switching = NO;
        } failure:^(NSError *error) {
        }];
    }
}

-(void)updateFormRows {
    [self.tableView beginUpdates];
    for (int i = 0; i < self.formRows.count; i++) {
        ICFormRow *row = self.formRows[i];
        if ([row isKindOfClass:[ICFormRowTextField class]]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell != nil && [cell isKindOfClass:[ICTextFieldTableViewCell class]]) {
                [self updateTextFieldCell: (ICTextFieldTableViewCell *)cell row: (ICFormRowTextField *)row];
            }
            
        } else if ([row isKindOfClass:[ICFormRowList class]]) {
            ICPickerViewTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [self updatePickerCell:cell row:row];
        } else if ([row isKindOfClass:[ICFormRowSwitch class]]) {
            if (((ICFormRowSwitch *)row).action == @selector(switchChanged:)) {
                row.isEnabled = self.paymentItem != nil && [self.paymentItem isKindOfClass:[ICBasicPaymentProduct class]] && ((ICBasicPaymentProduct *)self.paymentItem).allowsTokenization && !((ICBasicPaymentProduct *)self.paymentItem).autoTokenized && self.accountOnFile == nil;
                continue;
            }
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell != nil && [cell isKindOfClass:[ICSwitchTableViewCell class]]) {
                [self updateSwitchCell:(ICSwitchTableViewCell *)cell row:(ICFormRowSwitch *)row];
            }
        } else if ([row isKindOfClass:[ICFormRowButton class]] &&  ((ICFormRowButton *)row).action == @selector(payButtonTapped)) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell != nil && [cell isKindOfClass:[ICButtonTableViewCell class]]) {
                row.isEnabled = [self.paymentItem isKindOfClass:[ICPaymentProduct class]];
                [self updateButtonCell: (ICButtonTableViewCell *)cell row: (ICFormRowButton *)row];
            }
        }
    }
    [self.tableView endUpdates];
    
}

- (void)updateTextFieldCell:(ICTextFieldTableViewCell *)cell row: (ICFormRowTextField *)row {
    // Add error messages for cells
    ICValidationError *error = [row.paymentProductField.errors firstObject];
    cell.delegate = self;
    cell.accessoryType = row.showInfoButton ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
    cell.field = row.field;
    cell.readonly = !row.isEnabled;
    if (error != nil) {
        cell.error = [ICFormRowsConverter errorMessageForError: error withCurrency: row.paymentProductField.displayHints.formElement.type == ICCurrencyType];
    } else {
        cell.error = nil;
    }
}

- (void)updateSwitchCell:(ICSwitchTableViewCell *)cell row: (ICFormRowSwitch *)row {
    // Add error messages for cells
    if (row.field == nil) {
        return;
    }
    ICValidationError *error = [row.field.errors firstObject];
    if (error != nil) {
        cell.errorMessage = [ICFormRowsConverter errorMessageForError: error withCurrency: NO];
    } else {
        cell.errorMessage = nil;
    }
}

- (void)updateButtonCell:(ICButtonTableViewCell *)cell row:(ICFormRowButton *)row {
    cell.isEnabled = row.isEnabled;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.formRows.count;
}

// TODO: indexPah argument is not used, maybe replace it with tableView
- (ICTableViewCell *)formRowCellForRow:(ICFormRow *)row atIndexPath:(NSIndexPath *)indexPath {
    Class class = [row class];
    ICTableViewCell *cell = nil;
    if (class == [ICFormRowTextField class]) {
        cell = [self cellForTextField:(ICFormRowTextField *)row tableView:self.tableView];
    } else if (class == [ICFormRowCurrency class]) {
        cell = [self cellForCurrency:(ICFormRowCurrency *) row tableView:self.tableView];
    } else if (class == [ICFormRowSwitch class]) {
        cell = [self cellForSwitch:(ICFormRowSwitch *)row tableView:self.tableView];
    } else if (class == [ICFormRowList class]) {
        cell = [self cellForList:(ICFormRowList *)row tableView:self.tableView];
    } else if (class == [ICFormRowButton class]) {
        cell = [self cellForButton:(ICFormRowButton *)row tableView:self.tableView];
    } else if (class == [ICFormRowLabel class]) {
        cell = [self cellForLabel:(ICFormRowLabel *)row tableView:self.tableView];
    } else if (class == [ICFormRowDate class]) {
        cell = [self cellForDatePicker:(ICFormRowDate *)row tableView:self.tableView];
    } else if (class == [ICFormRowErrorMessage class]) {
        cell = [self cellForErrorMessage:(ICFormRowErrorMessage *)row tableView:self.tableView];
    } else if (class == [ICFormRowTooltip class]) {
        cell = [self cellForTooltip:(ICFormRowTooltip *)row tableView:self.tableView];
    } else if (class == [ICFormRowCoBrandsSelection class]) {
        cell = [self cellForCoBrandsSelection:(ICFormRowCoBrandsSelection *)row tableView:self.tableView];
    } else if (class == [ICFormRowCoBrandsExplanation class]) {
        cell = [self cellForCoBrandsExplanation:(ICFormRowCoBrandsExplanation  *)row tableView:self.tableView];
    } else if (class == [ICPaymentProductsTableRow class]) {
        cell = [self cellForPaymentProduct:(ICPaymentProductsTableRow  *)row tableView:self.tableView];
    } else if (class == [ICFormRowReadonlyReview class]) {
        cell = [self cellForReadonlyReview:(ICFormRowReadonlyReview  *)row tableView:self.tableView];
    } else {
        [NSException raise:@"Invalid form row class" format:@"Form row class %@ is invalid", class];
    }
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICFormRow *row = self.formRows[indexPath.row];
    ICTableViewCell *cell = [self formRowCellForRow:row atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Helper methods for data source methods

- (ICReadonlyReviewTableViewCell *)cellForReadonlyReview:(ICFormRowReadonlyReview *)row tableView:(UITableView *)tableView
{
    ICReadonlyReviewTableViewCell *cell = (ICReadonlyReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICReadonlyReviewTableViewCell reuseIdentifier]];
    
    cell.data = row.data;
    return cell;
}

- (ICTextFieldTableViewCell *)cellForTextField:(ICFormRowTextField *)row tableView:(UITableView *)tableView
{
    ICTextFieldTableViewCell *cell = (ICTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICTextFieldTableViewCell reuseIdentifier]];
    
    cell.field = row.field;
    cell.delegate = self;
    cell.readonly = !row.isEnabled;
    ICValidationError *error = [row.paymentProductField.errors firstObject];
    if (error != nil && self.validation) {
        cell.error = [ICFormRowsConverter errorMessageForError: error withCurrency: row.paymentProductField.displayHints.formElement.type == ICCurrencyType];
    }
    cell.accessoryType = row.showInfoButton ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
    
    return cell;
}
- (ICDatePickerTableViewCell *)cellForDatePicker:(ICFormRowDate *)row tableView:(UITableView *)tableView
{
    ICDatePickerTableViewCell *cell = (ICDatePickerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICDatePickerTableViewCell reuseIdentifier]];
    
    cell.delegate = self;
    cell.readonly = !row.isEnabled;
    cell.date = row.date;
    return cell;
}

- (ICCurrencyTableViewCell *)cellForCurrency:(ICFormRowCurrency *)row tableView:(UITableView *)tableView
{
    ICCurrencyTableViewCell *cell = (ICCurrencyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICCurrencyTableViewCell reuseIdentifier]];
    cell.integerField = row.integerField;
    cell.delegate = self;
    cell.fractionalField = row.fractionalField;
    cell.readonly = !row.isEnabled;
    cell.accessoryType = row.showInfoButton ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
    return cell;
}

- (ICSwitchTableViewCell *)cellForSwitch:(ICFormRowSwitch *)row tableView:(UITableView *)tableView
{
    ICSwitchTableViewCell *cell = (ICSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICSwitchTableViewCell reuseIdentifier]];
    cell.attributedTitle = row.title;
    [cell setSwitchTarget:row.target action:row.action];
    cell.on = row.isOn;
    cell.delegate = self;
    ICValidationError *error = [row.field.errors firstObject];
    if (error != nil && self.validation) {
        cell.errorMessage = [ICFormRowsConverter errorMessageForError: error withCurrency: 0];
    }
    cell.accessoryType = row.showInfoButton ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
    return cell;
}

- (ICPickerViewTableViewCell *)cellForList:(ICFormRowList *)row tableView:(UITableView *)tableView
{
    ICPickerViewTableViewCell *cell = (ICPickerViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICPickerViewTableViewCell reuseIdentifier]];
    cell.items = row.items;
    cell.delegate = self;
    cell.dataSource = self;
    cell.selectedRow = row.selectedRow;
    cell.readonly = !row.isEnabled;
    return cell;
}

- (ICButtonTableViewCell *)cellForButton:(ICFormRowButton *)row tableView:(UITableView *)tableView
{
    ICButtonTableViewCell *cell = (ICButtonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICButtonTableViewCell reuseIdentifier]];
    cell.buttonType = row.buttonType;
    cell.isEnabled = row.isEnabled;
    cell.title = row.title;
    [cell setClickTarget:row.target action:row.action];
    return cell;
}

- (ICLabelTableViewCell *)cellForLabel:(ICFormRowLabel *)row tableView:(UITableView *)tableView
{
    ICLabelTableViewCell *cell = (ICLabelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICLabelTableViewCell reuseIdentifier]];
    cell.label = row.text;
    cell.bold = row.bold;
    cell.accessoryType = row.showInfoButton ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
    return cell;
}

- (ICErrorMessageTableViewCell *)cellForErrorMessage:(ICFormRowErrorMessage *)row tableView:(UITableView *)tableView
{
    ICErrorMessageTableViewCell *cell = (ICErrorMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICErrorMessageTableViewCell reuseIdentifier]];
    cell.textLabel.text = row.text;
    return cell;
}

- (ICTooltipTableViewCell *)cellForTooltip:(ICFormRowTooltip *)row tableView:(UITableView *)tableView
{
    ICTooltipTableViewCell *cell = (ICTooltipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICTooltipTableViewCell reuseIdentifier]];
    cell.label = row.text;
    cell.tooltipImage = row.image;
    return cell;
}

- (ICCoBrandsSelectionTableViewCell *)cellForCoBrandsSelection:(ICFormRowCoBrandsSelection *)row tableView:(UITableView *)tableView
{
    ICCoBrandsSelectionTableViewCell *cell = (ICCoBrandsSelectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICCoBrandsSelectionTableViewCell reuseIdentifier]];
    return cell;
}


- (ICCOBrandsExplanationTableViewCell *)cellForCoBrandsExplanation:(ICFormRowCoBrandsExplanation *)row tableView:(UITableView *)tableView
{
    ICCOBrandsExplanationTableViewCell *cell = (ICCOBrandsExplanationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICCOBrandsExplanationTableViewCell reuseIdentifier]];
    return cell;
}

- (ICPaymentProductTableViewCell *)cellForPaymentProduct:(ICPaymentProductsTableRow *)row tableView:(UITableView *)tableView
{
    ICPaymentProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ICPaymentProductTableViewCell reuseIdentifier]];
    cell.name = row.name;
    cell.logo = row.logo;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [cell setNeedsLayout];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICFormRow *row = self.formRows[indexPath.row];
    
    if ([row isKindOfClass:[ICFormRowList class]]) {
        return [ICPickerViewTableViewCell pickerHeight];
    }
    else if ([row isKindOfClass:[ICFormRowDate class]]) {
        return [ICDatePickerTableViewCell pickerHeight];
    }
    // Rows that you can toggle
    else if ([row isKindOfClass:[ICFormRowTooltip class]] && !row.isEnabled) {
        return 0;
    }
    else if ([row isKindOfClass:[ICFormRowSwitch class]] && ((ICFormRowSwitch *)row).action == @selector(switchChanged:) && !row.isEnabled) {
        return 0;
    }
    else if ([row isKindOfClass:[ICFormRowTooltip class]] && ((ICFormRowTooltip *)row).image != nil) {
        return 145;
    } else if ([row isKindOfClass:[ICFormRowTooltip class]]) {
        return [ICTooltipTableViewCell cellSizeForWidth:MIN(320, tableView.frame.size.width) forFormRow:(ICFormRowTooltip *)row].height;
    }
    else if ([row isKindOfClass:[ICFormRowLabel class]]) {
        CGFloat tableWidth = tableView.frame.size.width;
        CGFloat height = [ICLabelTableViewCell cellSizeForWidth:MIN(320, tableWidth) forFormRow:(ICFormRowLabel *)row].height;
        return height;
    } else if ([row isKindOfClass:[ICFormRowButton class]]) {
        return 52;
    } else if ([row isKindOfClass:[ICFormRowTextField class]]) {
        CGFloat width = tableView.bounds.size.width - 20;
        ICFormRowTextField *textfieldRow = (ICFormRowTextField *)row;
        if (textfieldRow.showInfoButton) {
            width -= 48;
        }
        CGFloat errorHeight = 0;

        if ([textfieldRow.paymentProductField.errors firstObject] && self.validation) {
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:@""];
            str = [[NSAttributedString alloc] initWithString: [ICFormRowsConverter errorMessageForError:[textfieldRow.paymentProductField.errors firstObject]   withCurrency: textfieldRow.paymentProductField.displayHints.formElement.type == ICCurrencyType]];
            errorHeight = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options: NSStringDrawingUsesLineFragmentOrigin context: nil].size.height;
        }
        
        CGFloat height =  10 + 44 + 10 + errorHeight;
        return height;
        
    } else if ([row isKindOfClass:[ICFormRowSwitch class]]) {
        CGFloat width = tableView.bounds.size.width - 20;
        ICFormRowSwitch *textfieldRow = (ICFormRowSwitch *)row;
        if (textfieldRow.showInfoButton) {
            width -= 48;
        }
        CGFloat errorHeight = 0;
        if ([textfieldRow.field.errors firstObject] && self.validation) {
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:@""];
            str = [[NSAttributedString alloc] initWithString: [ICFormRowsConverter errorMessageForError:[textfieldRow.field.errors firstObject]   withCurrency: 0]];
            errorHeight = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options: NSStringDrawingUsesLineFragmentOrigin context: nil].size.height + 10;
        }
    
        CGFloat height =  10 + 44 + 10 + errorHeight;
        return height;
    }

    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.formRows[indexPath.row] isKindOfClass:[ICFormRowCoBrandsSelection class]]) {
        self.coBrandsCollapsed = !self.coBrandsCollapsed;
        [self updateFormRowsWithValidation:self.validation tooltipRows:self.tooltipRows confirmedPaymentProducts:self.confirmedPaymentProducts];
        [self.tableView reloadData];
    } else if ([self.formRows[indexPath.row] isKindOfClass:[ICPaymentProductsTableRow class]]) {
        ICPaymentProductsTableRow *row = (ICPaymentProductsTableRow *)self.formRows[indexPath.row];
        [self switchToPaymentProduct:row.paymentProductIdentifier];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ICFormRow *formRow = self.formRows[indexPath.row + 1];
    if ([formRow isKindOfClass:[ICFormRowTooltip class]]) {
        
        formRow.isEnabled = !formRow.isEnabled;
        
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

#pragma mark TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = false;
    if ([textField class] == [ICTextField class]) {
        result = [self standardTextField:(ICTextField *)textField shouldChangeCharactersInRange:range replacementString:string];
    } else if ([textField class] == [ICIntegerTextField class]) {
        result = [self integerTextField:(ICIntegerTextField *)textField shouldChangeCharactersInRange:range replacementString:string];
    } else if ([textField class] == [ICFractionalTextField class]) {
        result = [self fractionalTextField:(ICFractionalTextField *)textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    if (self.validation) {
        [self validateData];
    }
    
    return result;
}
-(void)formatAndUpdateCharactersFromTextField:(UITextField *)textField cursorPosition:(NSInteger *)position indexPath:(NSIndexPath *)indexPath trimSet:(NSMutableCharacterSet *)trimSet {
    ICFormRowTextField *row = (ICFormRowTextField *)self.formRows[indexPath.row];

    NSString *formattedString = [[self.inputData maskedValueForField:row.paymentProductField.identifier cursorPosition:position] stringByTrimmingCharactersInSet: trimSet];
    row.field.text = formattedString;
    textField.text = formattedString;
    *position = MIN(*position, formattedString.length);
    UITextPosition *cursorPositionInTextField = [textField positionFromPosition:textField.beginningOfDocument offset:*position];
    [textField setSelectedTextRange:[textField textRangeFromPosition:cursorPositionInTextField toPosition:cursorPositionInTextField]];
}
- (BOOL)standardTextField:(ICTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![textField.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    if (indexPath == nil || ![self.formRows[indexPath.row] isKindOfClass:[ICFormRowTextField class]]) {
        return NO;
    }
    ICFormRowTextField *row = (ICFormRowTextField *)self.formRows[indexPath.row];
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.inputData setValue:newString forField:row.paymentProductField.identifier];
    row.field.text = [self.inputData maskedValueForField:row.paymentProductField.identifier];
    NSInteger cursorPosition = range.location + string.length;
    [self formatAndUpdateCharactersFromTextField:textField cursorPosition:&cursorPosition indexPath:indexPath trimSet: [NSMutableCharacterSet characterSetWithCharactersInString:@" /-_"]];
    return NO;
}

- (BOOL)integerTextField:(ICIntegerTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![textField.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    if (indexPath == nil || ![self.formRows[indexPath.row] isKindOfClass:[ICFormRowCurrency class]]) {
        return NO;
    }
    ICFormRowCurrency *row = (ICFormRowCurrency *)self.formRows[indexPath.row];
    NSString *integerString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *fractionalString = row.fractionalField.text;
    
    if (integerString.length > 16) {
        return NO;
    }
    
    NSString *newValue = [self updateCurrencyValueWithIntegerString:integerString fractionalString:fractionalString paymentProductFieldIdentifier:row.paymentProductField.identifier];
    if (string.length == 0) {
        return YES;
    } else {
        [self updateRowWithCurrencyValue:newValue formRowCurrency:row];
        return NO;
    }
}

- (BOOL)fractionalTextField:(ICFractionalTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![textField.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    if (indexPath == nil || ![self.formRows[indexPath.row] isKindOfClass:[ICFormRowCurrency class]]) {
        return NO;
    }
    ICFormRowCurrency *row = (ICFormRowCurrency *)self.formRows[indexPath.row];
    NSString *integerString = row.integerField.text;
    NSString *fractionalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (fractionalString.length > 2) {
        int start = (int) fractionalString.length - 2;
        int end = (int) fractionalString.length - 1;
        fractionalString = [fractionalString substringWithRange:NSMakeRange(start, end)];
    }
    
    NSString *newValue = [self updateCurrencyValueWithIntegerString:integerString fractionalString:fractionalString paymentProductFieldIdentifier:row.paymentProductField.identifier];
    if (string.length == 0) {
        return YES;
    } else {
        [self updateRowWithCurrencyValue:newValue formRowCurrency:row];
        return NO;
    }
}

- (NSString *)updateCurrencyValueWithIntegerString:(NSString *)integerString fractionalString:(NSString *)fractionalString paymentProductFieldIdentifier:(NSString *)identifier
{
    long long integerPart = [integerString longLongValue];
    int fractionalPart = [fractionalString intValue];
    long long newValue = integerPart * 100 + fractionalPart;
    NSString *newString = [NSString stringWithFormat:@"%03lld", newValue];
    [self.inputData setValue:newString forField:identifier];
    
    return newString;
}

- (void)updateRowWithCurrencyValue:(NSString *)currencyValue formRowCurrency:(ICFormRowCurrency *)formRowCurrency
{
    formRowCurrency.integerField.text = [currencyValue substringToIndex:currencyValue.length - 2];
    formRowCurrency.fractionalField.text = [currencyValue substringFromIndex:currencyValue.length - 2];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

- (void)validateData {
    [self.inputData validate];
    [self updateFormRows];
}

#pragma mark TextField delegate helper methods

- (void)resetCardNumberTextField
{
//    for (ICFormRow *row in self.formRows) {
//        if ([row class] == [ICFormRowTextField class]) {
//            ICFormRowTextField *textFieldRow = (ICFormRowTextField *)row;
//            if ([textFieldRow.paymentProductField.identifier isEqualToString:@"cardNumber"] == YES) {
//                textFieldRow.textField.rightView = textFieldRow.logo;
//                ICTextField *textField = textFieldRow.textField;
//                [textField setSelectedTextRange:[textField textRangeFromPosition:self.cursorPositionInCreditCardNumberTextField toPosition:self.cursorPositionInCreditCardNumberTextField]];
//                [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.01f];
//            }
//        }
//    }
}
#pragma mark Date picker cell delegate
-(void)datePicker:(UIDatePicker *)datePicker selectedNewDate:(NSDate *)newDate {
    ICDatePickerTableViewCell *cell = (ICDatePickerTableViewCell *)[datePicker superview];
    NSIndexPath *path = [[self tableView]indexPathForCell:cell];
    ICFormRowDate *row = self.formRows[path.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [formatter stringFromDate:newDate];
    [self.inputData setValue:dateString forField:row.paymentProductField.identifier] ;
    
}
- (void)cancelButtonTapped
{
    [self.paymentRequestTarget didCancelPaymentRequest];
}


- (void)switchChanged:(ICSwitch *)sender
{
    ICSwitchTableViewCell *cell = (ICSwitchTableViewCell *)sender.superview;
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    ICFormRowSwitch *row = self.formRows[ip.row];
    ICPaymentProductField *field = [row field];
    
    if (field == nil) {
        self.inputData.tokenize = sender.on;
    }
    else {
        [self.inputData setValue:[sender isOn] ? @"true" : @"false" forField:field.identifier];
        row.isOn = [sender isOn];
        if (self.validation) {
            [self validateData];
        }
        [self updateSwitchCell:cell row:row];
    }
}

#pragma mark Picker view delegate

- (NSInteger)numberOfComponentsInPickerView:(ICPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(ICPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerView.content.count;
}

- (NSAttributedString *)pickerView:(ICPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *item = pickerView.content[row];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:item];
    return string;
}

- (void)pickerView:(ICPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (![pickerView.superview isKindOfClass:[ICPickerViewTableViewCell class]]) {
        return;
    }
    ICPickerViewTableViewCell *cell = (ICPickerViewTableViewCell *)pickerView.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)pickerView.superview];
    if (indexPath == nil || ![self.formRows[indexPath.row] isKindOfClass:[ICFormRowList class]]) {
        return;
    }
    ICFormRowList *element = (ICFormRowList *)self.formRows[indexPath.row];
    ICValueMappingItem *selectedItem = cell.items[row];
    
    element.selectedRow = row;
    [self.inputData setValue:selectedItem.value forField:element.paymentProductField.identifier];
}

// To be overrided by subclasses
- (void)updatePickerCell:(ICPickerViewTableViewCell *)cell row: (ICFormRowList *)list
{
    return;
}
#pragma mark Button target methods

- (void)payButtonTapped
{
    BOOL valid = NO;
    
    [self.inputData validate];
    if (self.inputData.errors.count == 0) {
        ICPaymentRequest *paymentRequest = [self.inputData paymentRequest];
        [paymentRequest validate];
        if (paymentRequest.errors.count == 0) {
            valid = YES;
            [self.paymentRequestTarget didSubmitPaymentRequest:paymentRequest];
        }
    }
    if (valid == NO) {
        self.validation = YES;
        [self updateFormRows];
    }
    
}

-(void)validateExceptFields:(NSSet *)fields {
    [self.inputData validateExceptFields:fields];
    if (self.inputData.errors.count > 0) {
        self.validation = YES;
    }
}

@end
