//
//  ICStartViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <PassKit/PassKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import <IngenicoConnectExample/ICAppConstants.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectSDK/ICPaymentItem.h>
#import <IngenicoConnectExample/ICStartViewController.h>
#import <IngenicoConnectExample/ICViewFactory.h>
#import <IngenicoConnectExample/ICPaymentProductsViewController.h>
#import <IngenicoConnectExample/ICPaymentProductViewController.h>
#import <IngenicoConnectExample/ICEndViewController.h>
#import <IngenicoConnectExample/ICPaymentProductsViewControllerTarget.h>

#import <IngenicoConnectSDK/ICPaymentAmountOfMoney.h>
#import <IngenicoConnectSDK/ICPaymentProductGroup.h>
#import <IngenicoConnectSDK/ICBasicPaymentProductGroup.h>

@interface ICStartViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextView *explanation;
@property (strong, nonatomic) ICLabel *clientSessionIdLabel;
@property (strong, nonatomic) ICTextField *clientSessionIdTextField;
@property (strong, nonatomic) ICLabel *customerIdLabel;
@property (strong, nonatomic) ICTextField *customerIdTextField;
@property (strong, nonatomic) ICLabel *merchantIdLabel;
@property (strong, nonatomic) ICTextField *merchantIdTextField;
@property (strong, nonatomic) ICLabel *regionLabel;
@property (strong, nonatomic) UISegmentedControl *regionControl;
@property (strong, nonatomic) ICLabel *environmentLabel;
@property (strong, nonatomic) ICPickerView *environmentPicker;
@property (strong, nonatomic) ICLabel *amountLabel;
@property (strong, nonatomic) ICTextField *amountTextField;
@property (strong, nonatomic) ICLabel *countryCodeLabel;
@property (strong, nonatomic) ICPickerView *countryCodePicker;
@property (strong, nonatomic) ICLabel *currencyCodeLabel;
@property (strong, nonatomic) ICPickerView *currencyCodePicker;
@property (strong, nonatomic) ICLabel *isRecurringLabel;
@property (strong, nonatomic) ICSwitch *isRecurringSwitch;
@property (strong, nonatomic) UIButton *payButton;
@property (strong, nonatomic) UISwitch *groupMethodsSwitch;
@property (strong, nonatomic) ICPaymentProductsViewControllerTarget *paymentProductsViewControllerTarget;

@property (nonatomic) long amountValue;

@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (strong, nonatomic) ICSession *session;
@property (strong, nonatomic) ICPaymentContext *context;

@property (strong, nonatomic) NSArray *countryCodes;
@property (strong, nonatomic) NSArray *currencyCodes;

@end

@implementation ICStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTapRecognizer];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)] == YES) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.viewFactory = [[ICViewFactory alloc] init];
    
    self.countryCodes = [[kICCountryCodes componentsSeparatedByString:@", "] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.currencyCodes = [[kICCurrencyCodes componentsSeparatedByString:@", "] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSInteger viewHeight = 1500;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewHeight);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.scrollView];
    
    UIView *superContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, viewHeight)];
    superContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrollView addSubview:superContainerView];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [superContainerView addSubview:self.containerView];

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:viewHeight];
    [self.containerView addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320];
    [self.containerView addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [superContainerView addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [superContainerView addConstraint:constraint];

    self.explanation = [[UITextView alloc] init];
    self.explanation.translatesAutoresizingMaskIntoConstraints = NO;
    self.explanation.text = NSLocalizedStringFromTable(@"SetupExplanation", kICAppLocalizable, @"To process a payment using the services provided by the IngenicoConnect platform, the following information must be provided by a merchant.\n\nAfter providing the information requested below, this example app can process a payment.");
    self.explanation.editable = NO;
    self.explanation.backgroundColor = [UIColor colorWithRed:0.85 green:0.94 blue:0.97 alpha:1];
    self.explanation.textColor = [UIColor colorWithRed:0 green:0.58 blue:0.82 alpha:1];
    self.explanation.layer.cornerRadius = 5.0;
    [self.containerView addSubview:self.explanation];

    self.clientSessionIdLabel = [self.viewFactory labelWithType:ICLabelType];
    self.clientSessionIdLabel.text = NSLocalizedStringFromTable(@"ClientSessionIdentifier", kICAppLocalizable, @"Client session identifier");
    self.clientSessionIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.clientSessionIdTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.clientSessionIdTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.clientSessionIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.clientSessionIdTextField.text = [StandardUserDefaults objectForKey:kICClientSessionId];
    [self.containerView addSubview:self.clientSessionIdLabel];
    [self.containerView addSubview:self.clientSessionIdTextField];
    
    self.customerIdLabel = [self.viewFactory labelWithType:ICLabelType];
    self.customerIdLabel.text = NSLocalizedStringFromTable(@"CustomerIdentifier", kICAppLocalizable, @"Customer identifier");
    self.customerIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.customerIdTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.customerIdTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.customerIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.customerIdTextField.text = [StandardUserDefaults objectForKey:kICCustomerId];
    [self.containerView addSubview:self.customerIdLabel];
    [self.containerView addSubview:self.customerIdTextField];
    
    self.merchantIdLabel = [self.viewFactory labelWithType:ICLabelType];
    self.merchantIdLabel.text = NSLocalizedStringFromTable(@"MerchantIdentifier", kICAppLocalizable, @"Merchant identifier");
    self.merchantIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.merchantIdTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.merchantIdTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.merchantIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.merchantIdTextField.text = [StandardUserDefaults objectForKey:kICMerchantId];
    [self.containerView addSubview:self.merchantIdLabel];
    [self.containerView addSubview:self.merchantIdTextField];

    self.regionLabel = [self.viewFactory labelWithType:ICLabelType];
    self.regionLabel.text = NSLocalizedStringFromTable(@"Region", kICAppLocalizable, @"Region");
    self.regionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.regionControl = [[UISegmentedControl alloc] initWithItems:@[@"EU", @"US", @"AMS", @"PAR"]];
    self.regionControl.selectedSegmentIndex = 0;
    self.regionControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.regionLabel];
    [self.containerView addSubview:self.regionControl];
    
    self.environmentLabel = [self.viewFactory labelWithType:ICLabelType];
    self.environmentLabel.text = NSLocalizedStringFromTable(@"Environment", kICAppLocalizable, @"Environment");
    self.environmentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.environmentPicker = [self.viewFactory pickerViewWithType:ICPickerViewType];
    self.environmentPicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.environmentPicker.content = @[@"Production", @"Pre-production", @"Sandbox"];
    self.environmentPicker.dataSource = self;
    self.environmentPicker.delegate = self;
    [self.environmentPicker selectRow:2 inComponent:0 animated:NO];
    [self.containerView addSubview:self.environmentLabel];
    [self.containerView addSubview:self.environmentPicker];
    
    self.amountLabel = [self.viewFactory labelWithType:ICLabelType];
    self.amountLabel.text = NSLocalizedStringFromTable(@"AmountInCents", kICAppLocalizable, @"Amount in cents");
    self.amountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.amountTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.amountTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.amountTextField.text = @"100";
    [self.containerView addSubview:self.amountLabel];
    [self.containerView addSubview:self.amountTextField];
    
    self.countryCodeLabel = [self.viewFactory labelWithType:ICLabelType];
    self.countryCodeLabel.text = NSLocalizedStringFromTable(@"CountryCode", kICAppLocalizable, @"Country code");
    self.countryCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.countryCodePicker = [self.viewFactory pickerViewWithType:ICPickerViewType];
    self.countryCodePicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.countryCodePicker.content = self.countryCodes;
    self.countryCodePicker.dataSource = self;
    self.countryCodePicker.delegate = self;
    [self.countryCodePicker selectRow:165 inComponent:0 animated:NO];
    [self.containerView addSubview:self.countryCodeLabel];
    [self.containerView addSubview:self.countryCodePicker];
    
    self.currencyCodeLabel = [self.viewFactory labelWithType:ICLabelType];
    self.currencyCodeLabel.text = NSLocalizedStringFromTable(@"CurrencyCode", kICAppLocalizable, @"Currency code");
    self.currencyCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.currencyCodePicker = [self.viewFactory pickerViewWithType:ICPickerViewType];
    self.currencyCodePicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.currencyCodePicker.content = self.currencyCodes;
    self.currencyCodePicker.dataSource = self;
    self.currencyCodePicker.delegate = self;
    [self.currencyCodePicker selectRow:42 inComponent:0 animated:NO];
    [self.containerView addSubview:self.currencyCodeLabel];
    [self.containerView addSubview:self.currencyCodePicker];
    
    self.isRecurringLabel = [self.viewFactory labelWithType:ICLabelType];
    self.isRecurringLabel.text = NSLocalizedStringFromTable(@"RecurringPayment", kICAppLocalizable, @"Payment is recurring");
    self.isRecurringLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.isRecurringSwitch = [self.viewFactory switchWithType:ICSwitchType];
    self.isRecurringSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.isRecurringLabel];
    [self.containerView addSubview:self.isRecurringSwitch];
    
    ICLabel *groupMethodsLabel = [self.viewFactory labelWithType:ICLabelType];
    groupMethodsLabel.text = NSLocalizedStringWithDefaultValue(@"GroupMethods", kICAppLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Group payment products", @"");
    //groupMethodsLabel.text = NSLocalizedStringFromTable(@"GroupMethods", kICAppLocalizable, @"Display payment methods as group");
    groupMethodsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _groupMethodsSwitch = [self.viewFactory switchWithType:ICSwitchType];
    _groupMethodsSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:groupMethodsLabel];
    [self.containerView addSubview:_groupMethodsSwitch];

    self.payButton = [self.viewFactory buttonWithType:ICButtonTypePrimary];
    [self.payButton setTitle:NSLocalizedStringFromTable(@"PayNow", kICAppLocalizable, @"Pay securely now") forState:UIControlStateNormal];
    self.payButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.payButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.payButton];

    NSDictionary *views = NSDictionaryOfVariableBindings(_explanation, _clientSessionIdLabel, _clientSessionIdTextField, _customerIdLabel, _customerIdTextField, _merchantIdLabel, _merchantIdTextField, _regionLabel, _regionControl, _environmentLabel, _environmentPicker, _amountLabel, _amountTextField, _countryCodeLabel, _countryCodePicker, _currencyCodeLabel, _currencyCodePicker, _isRecurringLabel, _isRecurringSwitch, _payButton, groupMethodsLabel, _groupMethodsSwitch);
    NSDictionary *metrics = @{@"largeSpace": @"24"};

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_explanation]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_clientSessionIdLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_clientSessionIdTextField]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_customerIdLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_customerIdTextField]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_merchantIdLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_merchantIdTextField]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_regionLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_regionControl]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_environmentLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_environmentPicker]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_amountLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_amountTextField]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_countryCodeLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_countryCodePicker]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_currencyCodeLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_currencyCodePicker]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_isRecurringLabel]-[_isRecurringSwitch]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[groupMethodsLabel]-[_groupMethodsSwitch]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_payButton]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(largeSpace)-[_explanation(==100)]-(largeSpace)-[_clientSessionIdLabel]-[_clientSessionIdTextField]-(largeSpace)-[_customerIdLabel]-[_customerIdTextField]-(largeSpace)-[_merchantIdLabel]-[_merchantIdTextField]-(largeSpace)-[_regionLabel]-[_regionControl]-(largeSpace)-[_environmentLabel]-[_environmentPicker]-(largeSpace)-[_amountLabel]-[_amountTextField]-(largeSpace)-[_countryCodeLabel]-[_countryCodePicker]-(largeSpace)-[_currencyCodeLabel]-[_currencyCodePicker]-(largeSpace)-[_isRecurringSwitch]-(largeSpace)-[_groupMethodsSwitch]-[_payButton]" options:0 metrics:metrics views:views]];
}

- (void)initializeTapRecognizer
{
    UITapGestureRecognizer *tapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped)];
    tapScrollView.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapScrollView];
}

- (void)tableViewTapped
{
    for (UIView *view in self.containerView.subviews) {
        if ([view class] == [ICTextField class]) {
            ICTextField *textField = (ICTextField *)view;
            if ([textField isFirstResponder] == YES) {
                [textField resignFirstResponder];
            }
        }
    }
}

#pragma mark -
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

#pragma mark -
#pragma mark Button actions

- (void)buyButtonTapped:(UIButton *)sender
{
    if (self.payButton == sender) {
        self.amountValue = (long) [self.amountTextField.text longLongValue];
    } else {
        [NSException raise:@"Invalid sender" format:@"Sender %@ is invalid", sender];
    }

    [SVProgressHUD showWithStatus:NSLocalizedStringFromTableInBundle(@"gc.app.general.loading.body", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil)];

    NSString *clientSessionId = self.clientSessionIdTextField.text;
    [StandardUserDefaults setObject:clientSessionId forKey:kICClientSessionId];
    NSString *customerId = self.customerIdTextField.text;
    [StandardUserDefaults setObject:customerId forKey:kICCustomerId];
    if (self.merchantIdTextField.text != nil) {
        NSString *merchantId = self.merchantIdTextField.text;
        [StandardUserDefaults setObject:merchantId forKey:kICMerchantId];
    }
    ICRegion region;
    if (self.regionControl.selectedSegmentIndex == 0) {
        region = ICRegionEU;
    } else if (self.regionControl.selectedSegmentIndex == 1) {
        region = ICRegionUS;
    } else if (self.regionControl.selectedSegmentIndex == 2) {
        region = ICRegionAMS;
    } else {
        region = ICRegionPAR;
    }
    ICEnvironment environment = (ICEnvironment) [self.environmentPicker selectedRowInComponent:0];

    // ***************************************************************************
    //
    // The IngenicoConnect SDK supports processing payments with instances of the
    // ICSession class. The code below shows how such an instance chould be
    // instantiated.
    //
    // The ICSession class uses a number of supporting objects. There is an
    // initializer for this class that takes these supporting objects as
    // arguments. This should make it easy to replace these additional objects
    // without changing the implementation of the SDK. Use this initializer
    // instead of the factory method used below if you want to replace any of the
    // supporting objects.
    //
    // ***************************************************************************

    self.session = [ICSession sessionWithClientSessionId:clientSessionId customerId:customerId region:region environment:environment appIdentifier:kICApplicationIdentifier];

    NSString *countryCode = [self.countryCodes objectAtIndex:[self.countryCodePicker selectedRowInComponent:0]];
    NSString *currencyCode = [self.currencyCodes objectAtIndex:[self.currencyCodePicker selectedRowInComponent:0]];
    BOOL isRecurring = self.isRecurringSwitch.on;

    // ***************************************************************************
    //
    // To retrieve the available payment products, the information stored in the
    // following ICPaymentContext object is needed.
    //
    // After the ICSession object has retrieved the payment products that match
    // the information stored in the ICPaymentContext object, a
    // selection screen is shown. This screen itself is not part of the SDK and
    // only illustrates a possible payment product selection screen.
    //
    // ***************************************************************************
    ICPaymentAmountOfMoney *amountOfMoney = [[ICPaymentAmountOfMoney alloc] initWithTotalAmount:self.amountValue currencyCode:currencyCode];
    self.context = [[ICPaymentContext alloc] initWithAmountOfMoney:amountOfMoney isRecurring:isRecurring countryCode:countryCode];

    [self.session paymentItemsForContext:self.context groupPaymentProducts:self.groupMethodsSwitch.isOn success:^(ICPaymentItems *paymentItems) {
        [SVProgressHUD dismiss];
        [self showPaymentProductSelection:paymentItems];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"PaymentProductsErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

-(void)showPaymentProductSelection:(ICPaymentItems *)paymentItems
{
    self.paymentProductsViewControllerTarget = [[ICPaymentProductsViewControllerTarget alloc] initWithNavigationController:self.navigationController session:self.session context:self.context viewFactory:self.viewFactory];
    self.paymentProductsViewControllerTarget.paymentFinishedTarget = self;
    ICPaymentProductsViewController *paymentProductSelection = [[ICPaymentProductsViewController alloc] init];
    paymentProductSelection.target = self.paymentProductsViewControllerTarget;
    paymentProductSelection.paymentItems = paymentItems;
    paymentProductSelection.viewFactory = self.viewFactory;
    paymentProductSelection.amount = self.amountValue;
    paymentProductSelection.currencyCode = self.context.amountOfMoney.currencyCode;
    [self.navigationController pushViewController:paymentProductSelection animated:YES];
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma mark Continue shopping target

- (void)didSelectContinueShopping
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Payment finished target

- (void)didFinishPayment {
    ICEndViewController *end = [[ICEndViewController alloc] init];
    end.target = self;
    end.viewFactory = self.viewFactory;
    [self.navigationController pushViewController:end animated:YES];
}

#pragma mark -

@end
