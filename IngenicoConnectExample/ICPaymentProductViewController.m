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
#import <IngenicoConnectExample/ICButtonTableViewCell.h>
#import <IngenicoConnectExample/ICSwitchTableViewCell.h>
#import <IngenicoConnectExample/ICTextFieldTableViewCell.h>
#import <IngenicoConnectExample/ICCurrencyTableViewCell.h>
#import <IngenicoConnectExample/ICPickerViewTableViewCell.h>
#import <IngenicoConnectExample/ICLabelTableViewCell.h>
#import <IngenicoConnectExample/ICErrorMessageTableViewCell.h>
#import <IngenicoConnectExample/ICTooltipTableViewCell.h>
#import <IngenicoConnectExample/ICSummaryTableHeaderView.h>
#import <IngenicoConnectExample/ICMerchantLogoImageView.h>
#import <IngenicoConnectSDK/ICPaymentAmountOfMoney.h>
#import <IngenicoConnectExample/ICFormRowCoBrandsSelection.h>
#import <IngenicoConnectSDK/ICIINDetail.h>
#import <IngenicoConnectExample/ICPaymentProductsTableRow.h>
#import <IngenicoConnectExample/ICPaymentProductTableViewCell.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectExample/ICFormRowCoBrandsExplanation.h>
#import <IngenicoConnectExample/ICCOBrandsExplanationTableViewCell.h>
#import <IngenicoConnectExample/ICPaymentProductInputData.h>

@interface ICPaymentProductViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSMutableArray *formRows;
@property (strong, nonatomic) NSMutableArray *tooltipRows;
@property (nonatomic) BOOL validation;
@property (strong, nonatomic) NSMutableSet *confirmedPaymentProducts;
@property (strong, nonatomic) ICPaymentProductInputData *inputData;
@property (nonatomic) BOOL rememberPaymentDetails;
@property (strong, nonatomic) ICSummaryTableHeaderView *header;
@property (strong, nonatomic) UITextPosition *cursorPositionInCreditCardNumberTextField;
@property (nonatomic) BOOL switching;
@property (nonatomic, strong) ICIINDetailsResponse *iinDetailsResponse;
@property (nonatomic, assign) BOOL coBrandsCollapsed;

@end

@implementation ICPaymentProductViewController

- (instancetype)init

{
    self = [super initWithStyle:UITableViewStylePlain];
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
    if ([self.paymentItem isKindOfClass:[ICPaymentProduct class]]) {
        ICPaymentProduct *product = (ICPaymentProduct *) self.paymentItem;
        [self.confirmedPaymentProducts addObject:product.identifier];
    }
    
    [self initializeFormRows];
    
    self.switching = NO;
    self.coBrandsCollapsed = YES;
}

- (void)initializeTapRecognizer
{
    UITapGestureRecognizer *tapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped)];
    tapScrollView.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapScrollView];
}

- (void)tableViewTapped
{
    for (ICFormRow *element in self.formRows) {
        if ([element class] == [ICFormRowTextField class]) {
            ICFormRowTextField *formRowTextField = (ICFormRowTextField *)element;
            if ([formRowTextField.textField isFirstResponder] == YES) {
                [formRowTextField.textField resignFirstResponder];
            }
        } else if ([element class] == [ICFormRowCurrency class]) {
            ICFormRowCurrency *formRowCurrency = (ICFormRowCurrency *)element;
            if ([formRowCurrency.integerTextField isFirstResponder] == YES) {
                [formRowCurrency.integerTextField resignFirstResponder];
            }
            if ([formRowCurrency.fractionalTextField isFirstResponder] == YES) {
                [formRowCurrency.fractionalTextField resignFirstResponder];
            }
        }
    }
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

- (void)initializeFormRows
{
    [self updateFormRowsWithValidation:self.validation tooltipRows:self.tooltipRows confirmedPaymentProducts:self.confirmedPaymentProducts];
}

- (void)updateFormRowsWithValidation:(BOOL)validation tooltipRows:(NSArray *)tooltipRows confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts
{
    ICFormRowsConverter *mapper = [[ICFormRowsConverter alloc] init];
    NSArray *rows = [mapper formRowsFromInputData:self.inputData iinDetailsResponse:self.iinDetailsResponse validation:validation viewFactory:self.viewFactory confirmedPaymentProducts:confirmedPaymentProducts];
    NSMutableArray *formRows = [[NSMutableArray alloc] initWithArray:rows];
    
    if ([self.paymentItem isKindOfClass:[ICPaymentProduct class]]) {
        NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
        ICPaymentProduct *product = (ICPaymentProduct *) self.paymentItem;
        if (product.allowsTokenization == YES && product.autoTokenized == NO && self.accountOnFile == nil) {
            ICFormRowSwitch *switchFormRow = [[ICFormRowSwitch alloc] init];
            switchFormRow.switchControl = (ICSwitch *) [self.viewFactory switchWithType:ICSwitchType];
            switchFormRow.text = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.rememberMe", kICSDKLocalizable, sdkBundle, @"Explanation of the switch for remembering payment information.");
            switchFormRow.switchControl.on = self.rememberPaymentDetails;
            
            
            switchFormRow.showInfoButton = YES;
            switchFormRow.tooltipIdentifier = @"RememberMeTooltip";
            switchFormRow.tooltipText = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.rememberMe.tooltip", kICSDKLocalizable, sdkBundle, nil);
            [formRows addObject:switchFormRow];
        }
    }
    
    NSMutableArray *formRowsWithTooltip = [NSMutableArray new];
    for (ICFormRow *row in formRows) {
        [formRowsWithTooltip addObject:row];
        if ([row class] == [ICFormRowTextField class]) {
            ICFormRowTextField *textFieldRow = (ICFormRowTextField *)row;
            
            if ([textFieldRow.paymentProductField.identifier isEqualToString:@"cardNumber"]) {
                textFieldRow.textField.text = [textFieldRow.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [self addCoBrandFormsInFormRows:formRowsWithTooltip iinDetailsResponse:self.iinDetailsResponse];
            }
        }
        if ([[row class] isSubclassOfClass:[ICFormRowWithInfoButton class]]) {
            ICFormRowWithInfoButton *infoButtonRow = (ICFormRowWithInfoButton *)row;
            for (ICFormRowTooltip *tooltipRow in tooltipRows) {
                if ([tooltipRow.tooltipIdentifier isEqualToString:infoButtonRow.tooltipIdentifier]) {
                    [formRowsWithTooltip addObject:tooltipRow];
                }
            }
        }
    }
    
    self.formRows = formRowsWithTooltip;
    NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    
    ICFormRowButton *payButtonFormRow = [[ICFormRowButton alloc] init];
    NSString *payButtonTitle = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.payButton", kICSDKLocalizable, sdkBundle, @"Title of the pay button on the payment product screen.");
    UIButton* payButton = [self.viewFactory buttonWithType:ICPrimaryButtonType];
    [payButton setTitle:payButtonTitle forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(payButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    payButtonFormRow.button = payButton;
    [self.formRows addObject:payButtonFormRow];
    
    ICFormRowButton *cancelButtonFormRow = [[ICFormRowButton alloc] init];
    NSString *cancelButtonTitle = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductDetails.cancelButton", kICSDKLocalizable, sdkBundle, @"Title of the cancel button on the payment product screen.");
    UIButton* cancelButton = [self.viewFactory buttonWithType:ICSecondaryButtonType];
    [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    cancelButtonFormRow.button = cancelButton;
    [self.formRows addObject:cancelButtonFormRow];
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
    else if ([paymentProductId isEqualToString:self.paymentItem.identifier] == YES) {
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
    self.coBrandsCollapsed = YES;
    [self updateFormRowsWithValidation:NO tooltipRows:self.tooltipRows confirmedPaymentProducts:self.confirmedPaymentProducts];
    [self.tableView reloadData];
    [self resetCardNumberTextField];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICFormRow *row = self.formRows[indexPath.row];
    Class class = [row class];
    ICTableViewCell *cell;
    if (class == [ICFormRowTextField class]) {
        cell = [self cellForTextField:(ICFormRowTextField *)row tableView:tableView];
    } else if (class == [ICFormRowCurrency class]) {
        cell = [self cellForCurrency:(ICFormRowCurrency *) row tableView:tableView];
    } else if (class == [ICFormRowSwitch class]) {
        cell = [self cellForSwitch:(ICFormRowSwitch *)row tableView:tableView];
    } else if (class == [ICFormRowList class]) {
        cell = [self cellForList:(ICFormRowList *)row tableView:tableView];
    } else if (class == [ICFormRowButton class]) {
        cell = [self cellForButton:(ICFormRowButton *)row tableView:tableView];
    } else if (class == [ICFormRowLabel class]) {
        cell = [self cellForLabel:(ICFormRowLabel *)row tableView:tableView];
    } else if (class == [ICFormRowErrorMessage class]) {
        cell = [self cellForErrorMessage:(ICFormRowErrorMessage *)row tableView:tableView];
    } else if (class == [ICFormRowTooltip class]) {
        cell = [self cellForTooltip:(ICFormRowTooltip *)row tableView:tableView];
    } else if (class == [ICFormRowCoBrandsSelection class]) {
        cell = [self cellForCoBrandsSelection:(ICFormRowCoBrandsSelection *)row tableView:tableView];
    } else if (class == [ICFormRowCoBrandsExplanation class]) {
        cell = [self cellForCoBrandsExplanation:(ICFormRowCoBrandsExplanation  *)row tableView:tableView];
    } else if (class == [ICPaymentProductsTableRow class]) {
        cell = [self cellForPaymentProduct:(ICPaymentProductsTableRow  *)row tableView:tableView];
    } else {
        [NSException raise:@"Invalid form row class" format:@"Form row class %@ is invalid", class];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Helper methods for data source methods

- (ICTextFieldTableViewCell *)cellForTextField:(ICFormRowTextField *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"text-field-cell";
    ICTextFieldTableViewCell *cell = (ICTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICTextFieldTableViewCell *)[self.viewFactory tableViewCellWithType:ICTextFieldTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.textField = row.textField;
    cell.textField.delegate = self;
    if (row.showInfoButton == YES) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (ICCurrencyTableViewCell *)cellForCurrency:(ICFormRowCurrency *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"currency-text-field-cell";
    ICCurrencyTableViewCell *cell = (ICCurrencyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICCurrencyTableViewCell *)[self.viewFactory tableViewCellWithType:ICCurrencyTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.integerTextField = row.integerTextField;
    cell.integerTextField.delegate = self;
    cell.fractionalTextField = row.fractionalTextField;
    cell.fractionalTextField.delegate = self;
    cell.currencyCode = self.context.amountOfMoney.currencyCode;
    if (row.showInfoButton == YES) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (ICSwitchTableViewCell *)cellForSwitch:(ICFormRowSwitch *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"switch-cell";
    ICSwitchTableViewCell *cell = (ICSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICSwitchTableViewCell *)[self.viewFactory tableViewCellWithType:ICSwitchTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.switchControl = row.switchControl;
    cell.textLabel.text = row.text;
    [cell.switchControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if (row.showInfoButton == YES) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (ICPickerViewTableViewCell *)cellForList:(ICFormRowList *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"picker-view-cell";
    ICPickerViewTableViewCell *cell = (ICPickerViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICPickerViewTableViewCell *)[self.viewFactory tableViewCellWithType:ICPickerViewTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.pickerView = row.pickerView;
    cell.pickerView.delegate = self;
    cell.pickerView.dataSource = self;
    [cell.pickerView selectRow:row.selectedRow inComponent:0 animated:NO];
    return cell;
}

- (ICButtonTableViewCell *)cellForButton:(ICFormRowButton *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"button-cell";
    ICButtonTableViewCell *cell = (ICButtonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICButtonTableViewCell *)[self.viewFactory tableViewCellWithType:ICButtonTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.button = row.button;
    return cell;
}

- (ICLabelTableViewCell *)cellForLabel:(ICFormRowLabel *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"label-cell";
    ICLabelTableViewCell *cell = (ICLabelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICLabelTableViewCell *)[self.viewFactory tableViewCellWithType:ICLabelTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.label = row.label;
    return cell;
}

- (ICErrorMessageTableViewCell *)cellForErrorMessage:(ICFormRowErrorMessage *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"error-cell";
    ICErrorMessageTableViewCell *cell = (ICErrorMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICErrorMessageTableViewCell *)[self.viewFactory tableViewCellWithType:ICErrorMessageTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = row.errorMessage;
    return cell;
}

- (ICTooltipTableViewCell *)cellForTooltip:(ICFormRowTooltip *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"info-cell";
    ICTooltipTableViewCell *cell = (ICTooltipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICTooltipTableViewCell *)[self.viewFactory tableViewCellWithType:ICTooltipTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    cell.tooltipLabel.text = row.tooltipText;
    cell.tooltipImage = row.tooltipImage;
    return cell;
}

- (ICCoBrandsSelectionTableViewCell *)cellForCoBrandsSelection:(ICFormRowCoBrandsSelection *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"co-brand-selection-cell";
    ICCoBrandsSelectionTableViewCell *cell = (ICCoBrandsSelectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICCoBrandsSelectionTableViewCell *)[self.viewFactory tableViewCellWithType:ICCoBrandsSelectionTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    return cell;
}


- (ICCOBrandsExplanationTableViewCell *)cellForCoBrandsExplanation:(ICFormRowCoBrandsExplanation *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"co-brand-explanation-cell";
    ICCOBrandsExplanationTableViewCell *cell = (ICCOBrandsExplanationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICCOBrandsExplanationTableViewCell *)[self.viewFactory tableViewCellWithType:ICCoBrandsExplanationTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

- (ICPaymentProductTableViewCell *)cellForPaymentProduct:(ICPaymentProductsTableRow *)row tableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = @"payment-product-selection-cell";
    ICPaymentProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = (ICPaymentProductTableViewCell *)[self.viewFactory tableViewCellWithType:ICPaymentProductTableViewCellType reuseIdentifier:reuseIdentifier];
    }
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
    Class class = [row class];
    if (class == [ICFormRowList class]) {
        return 162.5;
    } else if (class == [ICFormRowTooltip class]) {
        ICFormRowTooltip *tooltipRow = (ICFormRowTooltip *)row;
        return tooltipRow.tooltipImage == nil?40:160;
    } else if (class == [ICFormRowCoBrandsSelection class]) {
        return 30;
    } else if (class == [ICFormRowCoBrandsExplanation class]) {
        NSAttributedString *cellString = [ICCOBrandsExplanationTableViewCell cellString];
        CGRect rect = [cellString boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
        return rect.size.height + 20;
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
    ICFormRowWithInfoButton *infoButtonRow = (ICFormRowWithInfoButton *)self.formRows[indexPath.row];
    
    NSMutableArray *newTooltipRows = [[NSMutableArray alloc] init];
    BOOL found = NO;
    for (ICFormRowTooltip *tooltipRow in self.tooltipRows) {
        if (![tooltipRow.tooltipIdentifier isEqualToString: infoButtonRow.tooltipIdentifier]) {
            [newTooltipRows addObject:tooltipRow];
        } else {
            found = YES;
        }
    }
    if (found == NO) {
        ICFormRowTooltip *tooltipRow = [[ICFormRowTooltip alloc] init];
        tooltipRow.tooltipIdentifier = infoButtonRow.tooltipIdentifier;
        tooltipRow.tooltipImage = infoButtonRow.tooltipImage;
        tooltipRow.tooltipText = infoButtonRow.tooltipText;
        [newTooltipRows addObject:tooltipRow];
    }
    self.tooltipRows = newTooltipRows;
    [self updateFormRowsWithValidation:self.validation tooltipRows:self.tooltipRows confirmedPaymentProducts:self.confirmedPaymentProducts];
    [self.tableView reloadData];
}

#pragma mark TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result;
    if ([textField class] == [ICTextField class]) {
        result = [self standardTextField:(ICTextField *)textField shouldChangeCharactersInRange:range replacementString:string];
    } else if ([textField class] == [ICIntegerTextField class]) {
        result = [self integerTextField:(ICIntegerTextField *)textField shouldChangeCharactersInRange:range replacementString:string];
    } else if ([textField class] == [ICFractionalTextField class]) {
        result = [self fractionalTextField:(ICFractionalTextField *)textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return result;
}

- (BOOL)standardTextField:(ICTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    ICFormRowTextField *row = [self formRowWithTextField:textField];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.inputData setValue:newString forField:row.paymentProductField.identifier];
    NSInteger cursorPosition = range.location + string.length;
    NSMutableCharacterSet *trimSet = [NSMutableCharacterSet characterSetWithCharactersInString:@" /-_"];
    NSString *formattedString = [[self.inputData maskedValueForField:row.paymentProductField.identifier cursorPosition:&cursorPosition] stringByTrimmingCharactersInSet: trimSet];
    textField.text = formattedString;
    cursorPosition = MIN(cursorPosition, formattedString.length);
    UITextPosition *cursorPositionInTextField = [textField positionFromPosition:textField.beginningOfDocument offset:cursorPosition];
    [textField setSelectedTextRange:[textField textRangeFromPosition:cursorPositionInTextField toPosition:cursorPositionInTextField]];
    
    if ([row.paymentProductField.identifier isEqualToString:@"cardNumber"]) {
        NSString *unmasked = [self.inputData unmaskedValueForField:row.paymentProductField.identifier];
        if (unmasked.length >= 6 && cursorPosition <= 7) {
            unmasked = [unmasked substringToIndex:6];
            
            [self.session IINDetailsForPartialCreditCardNumber:unmasked context:self.context success:^(ICIINDetailsResponse *response) {
                self.iinDetailsResponse = response;
                if (response.status == ICSupported) {
                    BOOL coBrandSelected = NO;
                    for (ICIINDetail *coBrand in response.coBrands) {
                        if ([coBrand.paymentProductId isEqualToString:self.paymentItem.identifier]) {
                            coBrandSelected = YES;
                        }
                    }
                    if (coBrandSelected == NO) {
                        [self switchToPaymentProduct:response.paymentProductId];
                    }
                    else {
                        [self switchToPaymentProduct:self.paymentItem.identifier];
                    }
                }
                else {
                    [self switchToPaymentProduct:nil];
                }
            }                                          failure:^(NSError *error) {
            }];
        }
    }
        return NO;
}

- (BOOL)integerTextField:(ICIntegerTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    ICFormRowCurrency *row = [self formRowWithIntegerTextField:textField];
    NSString *integerString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *fractionalString = row.fractionalTextField.text;
    
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
    ICFormRowCurrency *row = [self formRowWithFractionalTextField:textField];
    NSString *integerString = row.integerTextField.text;
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
    formRowCurrency.integerTextField.text = [currencyValue substringToIndex:currencyValue.length - 2];
    formRowCurrency.fractionalTextField.text = [currencyValue substringFromIndex:currencyValue.length - 2];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

#pragma mark TextField delegate helper methods

- (void)resetCardNumberTextField
{
    for (ICFormRow *row in self.formRows) {
        if ([row class] == [ICFormRowTextField class]) {
            ICFormRowTextField *textFieldRow = (ICFormRowTextField *)row;
            if ([textFieldRow.paymentProductField.identifier isEqualToString:@"cardNumber"] == YES) {
                textFieldRow.textField.rightView = textFieldRow.logo;
                ICTextField *textField = textFieldRow.textField;
                [textField setSelectedTextRange:[textField textRangeFromPosition:self.cursorPositionInCreditCardNumberTextField toPosition:self.cursorPositionInCreditCardNumberTextField]];
                [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.01f];
            }
        }
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
    ICFormRowList *element = [self formRowWithPickerView:pickerView];
    NSString *name = pickerView.content[row];
    NSString *identifier = [element.nameToIdentifierMapping objectForKey:name];
    element.selectedRow = row;
    [self.inputData setValue:identifier forField:element.paymentProductFieldIdentifier];
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
        [self updateFormRowsWithValidation:self.validation tooltipRows:self.tooltipRows confirmedPaymentProducts:self.confirmedPaymentProducts];
        [self.tableView reloadData];
    }
    
}

- (void)cancelButtonTapped
{
    [self.paymentRequestTarget didCancelPaymentRequest];
}

- (void)switchChanged:(ICSwitch *)sender
{
    self.inputData.tokenize = sender.on;
}

#pragma mark Helper methods

- (ICFormRowTextField *)formRowWithTextField:(ICTextField *)textField
{
    for (ICFormRow *row in self.formRows) {
        if ([row class] == [ICFormRowTextField class]) {
            ICFormRowTextField *textFieldRow = (ICFormRowTextField *)row;
            if (textFieldRow.textField == textField) {
                return textFieldRow;
            }
        }
    }
    return nil;
}

- (ICFormRowCurrency *)formRowWithIntegerTextField:(ICIntegerTextField *)integerTextField
{
    for (ICFormRow *row in self.formRows) {
        if ([row class] == [ICFormRowCurrency class]) {
            ICFormRowCurrency *currencyRow = (ICFormRowCurrency *)row;
            if (currencyRow.integerTextField == integerTextField) {
                return currencyRow;
            }
        }
    }
    return nil;
}

- (ICFormRowCurrency *)formRowWithFractionalTextField:(ICFractionalTextField *)fractionalTextField
{
    for (ICFormRow *row in self.formRows) {
        if ([row class] == [ICFormRowCurrency class]) {
            ICFormRowCurrency *currencyRow = (ICFormRowCurrency *)row;
            if (currencyRow.fractionalTextField == fractionalTextField) {
                return currencyRow;
            }
        }
    }
    return nil;
}

- (ICFormRowList *)formRowWithPickerView:(UIPickerView *)pickerView
{
    for (ICFormRow *row in self.formRows) {
        if ([row class] == [ICFormRowList class]) {
            ICFormRowList *listRow = (ICFormRowList *)row;
            if (listRow.pickerView == pickerView) {
                return listRow;
            }
        }
    }
    return nil;
}


@end
