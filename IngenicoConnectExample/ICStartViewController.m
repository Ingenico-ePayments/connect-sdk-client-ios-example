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
#import <IngenicoConnectExample/ICJsonDialogViewController.h>
#import <IngenicoConnectExample/ICEndViewController.h>
#import <IngenicoConnectExample/ICPaymentProductsViewControllerTarget.h>
#import <IngenicoConnectExample/ICStartPaymentParsedJsonData.h>

#import <IngenicoConnectSDK/ICPaymentAmountOfMoney.h>
#import <IngenicoConnectSDK/ICPaymentProductGroup.h>
#import <IngenicoConnectSDK/ICBasicPaymentProductGroup.h>

@interface ICStartViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *parsableFieldsContainer;

@property (strong, nonatomic) UITextView *explanation;
@property (strong, nonatomic) ICLabel *clientSessionIdLabel;
@property (strong, nonatomic) ICTextField *clientSessionIdTextField;
@property (strong, nonatomic) ICLabel *customerIdLabel;
@property (strong, nonatomic) ICTextField *customerIdTextField;
@property (strong, nonatomic) ICLabel *baseURLLabel;
@property (strong, nonatomic) ICTextField *baseURLTextField;
@property (strong, nonatomic) ICLabel *assetsBaseURLLabel;
@property (strong, nonatomic) ICTextField *assetsBaseURLTextField;
@property (strong, nonatomic) UIButton *jsonButton;
@property (strong, nonatomic) ICLabel *merchantIdLabel;
@property (strong, nonatomic) ICTextField *merchantIdTextField;
@property (strong, nonatomic) ICLabel *amountLabel;
@property (strong, nonatomic) ICTextField *amountTextField;
@property (strong, nonatomic) ICLabel *countryCodeLabel;
@property (strong, nonatomic) ICPickerView *countryCodePicker;
@property (strong, nonatomic) ICLabel *currencyCodeLabel;
@property (strong, nonatomic) ICPickerView *currencyCodePicker;
@property (strong, nonatomic) ICLabel *isRecurringLabel;
@property (strong, nonatomic) ICSwitch *isRecurringSwitch;
@property (strong, nonatomic) UIButton *payButton;
@property (strong, nonatomic) ICLabel *groupMethodsLabel;
@property (strong, nonatomic) UISwitch *groupMethodsSwitch;
@property (strong, nonatomic) ICPaymentProductsViewControllerTarget *paymentProductsViewControllerTarget;

@property (nonatomic) long amountValue;

@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (strong, nonatomic) ICSession *session;
@property (strong, nonatomic) ICPaymentContext *context;

@property (strong, nonatomic) NSArray *countryCodes;
@property (strong, nonatomic) NSArray *currencyCodes;

@property (strong, nonatomic) ICJsonDialogViewController *jsonDialogViewController;

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
    self.jsonDialogViewController = [[ICJsonDialogViewController alloc] init];
    
    self.countryCodes = [[kICCountryCodes componentsSeparatedByString:@", "] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.currencyCodes = [[kICCurrencyCodes componentsSeparatedByString:@", "] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    UIView *superContainerView = [[UIView alloc] init];
    superContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    superContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:superContainerView];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [superContainerView addSubview:self.containerView];


    self.explanation = [[UITextView alloc] init];
    self.explanation.translatesAutoresizingMaskIntoConstraints = NO;
    self.explanation.text = NSLocalizedStringFromTable(@"SetupExplanation", kICAppLocalizable, @"To process a payment using the services provided by the IngenicoConnect platform, the following information must be provided by a merchant.\n\nAfter providing the information requested below, this example app can process a payment.");
    self.explanation.editable = NO;
    self.explanation.backgroundColor = [UIColor colorWithRed:0.85 green:0.94 blue:0.97 alpha:1];
    self.explanation.textColor = [UIColor colorWithRed:0 green:0.58 blue:0.82 alpha:1];
    self.explanation.layer.cornerRadius = 5.0;
    self.explanation.scrollEnabled = NO;
    [self.containerView addSubview:self.explanation];

    self.parsableFieldsContainer = [[UIView alloc] init];
    self.parsableFieldsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.parsableFieldsContainer.layer.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2].CGColor;
    self.parsableFieldsContainer.layer.cornerRadius = 10;
    [self.containerView addSubview:self.parsableFieldsContainer];

    self.clientSessionIdLabel = [self.viewFactory labelWithType:ICLabelType];
    self.clientSessionIdLabel.text = NSLocalizedStringFromTable(@"ClientSessionIdentifier", kICAppLocalizable, @"Client session identifier");
    self.clientSessionIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.clientSessionIdTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.clientSessionIdTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.clientSessionIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.clientSessionIdTextField.text = [StandardUserDefaults objectForKey:kICClientSessionId];
    self.clientSessionIdTextField.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];

    [self.parsableFieldsContainer addSubview:self.clientSessionIdLabel];
    [self.parsableFieldsContainer addSubview:self.clientSessionIdTextField];

    self.customerIdLabel = [self.viewFactory labelWithType:ICLabelType];
    self.customerIdLabel.text = NSLocalizedStringFromTable(@"CustomerIdentifier", kICAppLocalizable, @"Customer identifier");
    self.customerIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.customerIdTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.customerIdTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.customerIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.customerIdTextField.text = [StandardUserDefaults objectForKey:kICCustomerId];
    self.customerIdTextField.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];

    [self.parsableFieldsContainer addSubview:self.customerIdLabel];
    [self.parsableFieldsContainer addSubview:self.customerIdTextField];
    
    self.baseURLLabel = [self.viewFactory labelWithType:ICLabelType];
    self.baseURLLabel.text = NSLocalizedStringFromTable(@"BaseURL", kICAppLocalizable, @"Client session identifier");
    self.baseURLLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.baseURLTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.baseURLTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.baseURLTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.baseURLTextField.text = [StandardUserDefaults objectForKey:kICBaseURL];
    self.baseURLTextField.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];

    [self.parsableFieldsContainer addSubview:self.baseURLLabel];
    [self.parsableFieldsContainer addSubview:self.baseURLTextField];
    
    self.assetsBaseURLLabel = [self.viewFactory labelWithType:ICLabelType];
    self.assetsBaseURLLabel.text = NSLocalizedStringFromTable(@"AssetsBaseURL", kICAppLocalizable, @"Customer identifier");
    self.assetsBaseURLLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.assetsBaseURLTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.assetsBaseURLTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.assetsBaseURLTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.assetsBaseURLTextField.text = [StandardUserDefaults objectForKey:kICAssetsBaseURL];
    self.assetsBaseURLTextField.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];

    [self.parsableFieldsContainer addSubview:self.assetsBaseURLLabel];
    [self.parsableFieldsContainer addSubview:self.assetsBaseURLTextField];

    self.jsonButton = [self.viewFactory buttonWithType:ICButtonTypeSecondary];
    self.jsonButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.jsonButton.backgroundColor = [UIColor lightGrayColor];
    [self.jsonButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.jsonButton setTitle:NSLocalizedStringFromTable(@"Paste", kICAppLocalizable, nil) forState:UIControlStateNormal];
    [self.jsonButton addTarget:self action:@selector(presentJsonDialog) forControlEvents:UIControlEventTouchUpInside];
    [self.parsableFieldsContainer addSubview:self.jsonButton];


    self.merchantIdLabel = [self.viewFactory labelWithType:ICLabelType];
    self.merchantIdLabel.text = NSLocalizedStringFromTable(@"MerchantIdentifier", kICAppLocalizable, @"Merchant identifier");
    self.merchantIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.merchantIdTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.merchantIdTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.merchantIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.merchantIdTextField.text = [StandardUserDefaults objectForKey:kICMerchantId];
    [self.containerView addSubview:self.merchantIdLabel];
    [self.containerView addSubview:self.merchantIdTextField];
    
    self.amountLabel = [self.viewFactory labelWithType:ICLabelType];
    self.amountLabel.text = NSLocalizedStringFromTable(@"AmountInCents", kICAppLocalizable, @"Amount in cents");
    self.amountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.amountTextField = [self.viewFactory textFieldWithType:ICTextFieldType];
    self.amountTextField.translatesAutoresizingMaskIntoConstraints = NO;
    NSInteger amount = [[NSUserDefaults standardUserDefaults] integerForKey:kICPrice];
    if (amount == 0) {
        self.amountTextField.text = @"100";
    }
    else {
        self.amountTextField.text = [NSString stringWithFormat:@"%ld", (long)amount];

    }
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
    NSInteger countryCode = [[NSUserDefaults standardUserDefaults] integerForKey:kICCountryCode];
    if (countryCode == 0) {
        [self.countryCodePicker selectRow:165 inComponent:0 animated:NO];
    }
    else {
        [self.countryCodePicker selectRow:countryCode inComponent:0 animated:NO];
    }
    [self.countryCodePicker selectRow:166 inComponent:0 animated:NO];
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
    NSInteger currency = [[NSUserDefaults standardUserDefaults] integerForKey:kICCurrency];
    if (currency == 0) {
        [self.currencyCodePicker selectRow:42 inComponent:0 animated:NO];
    }
    else {
        [self.currencyCodePicker selectRow:currency inComponent:0 animated:NO];
    }
    [self.containerView addSubview:self.currencyCodeLabel];
    [self.containerView addSubview:self.currencyCodePicker];
    
    self.isRecurringLabel = [self.viewFactory labelWithType:ICLabelType];
    self.isRecurringLabel.text = NSLocalizedStringFromTable(@"RecurringPayment", kICAppLocalizable, @"Payment is recurring");
    self.isRecurringLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.isRecurringSwitch = [self.viewFactory switchWithType:ICSwitchType];
    self.isRecurringSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.isRecurringLabel];
    [self.containerView addSubview:self.isRecurringSwitch];
    
    self.groupMethodsLabel = [self.viewFactory labelWithType:ICLabelType];
    self.groupMethodsLabel.text = NSLocalizedStringWithDefaultValue(@"GroupMethods", kICAppLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Group payment products", @"");
    //groupMethodsLabel.text = NSLocalizedStringFromTable(@"GroupMethods", kICAppLocalizable, @"Display payment methods as group");
    self.groupMethodsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.groupMethodsSwitch = [self.viewFactory switchWithType:ICSwitchType];
    self.groupMethodsSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.groupMethodsLabel];
    [self.containerView addSubview:self.groupMethodsSwitch];

    self.payButton = [self.viewFactory buttonWithType:ICButtonTypePrimary];
    [self.payButton setTitle:NSLocalizedStringFromTable(@"PayNow", kICAppLocalizable, @"Pay securely now") forState:UIControlStateNormal];
    self.payButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.payButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.payButton];

    NSDictionary *views = NSDictionaryOfVariableBindings(_explanation, _clientSessionIdLabel, _clientSessionIdTextField, _customerIdLabel, _customerIdTextField, _baseURLLabel, _baseURLTextField, _assetsBaseURLLabel, _assetsBaseURLTextField, _jsonButton, _merchantIdLabel, _merchantIdTextField, _amountLabel, _amountTextField, _countryCodeLabel, _countryCodePicker, _currencyCodeLabel, _currencyCodePicker, _isRecurringLabel, _isRecurringSwitch, _payButton, _groupMethodsLabel, _groupMethodsSwitch, _parsableFieldsContainer, _containerView, _scrollView, superContainerView);
    NSDictionary *metrics = @{@"fieldSeparator": @"24", @"groupSeparator": @"72"};

    // ParsableFieldsContainer Constraints
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_clientSessionIdLabel]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_clientSessionIdTextField]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_customerIdLabel]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_customerIdTextField]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_baseURLLabel]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_baseURLTextField]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_assetsBaseURLLabel]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_assetsBaseURLTextField]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_jsonButton(>=120)]-|" options:0 metrics:nil views:views]];
    [self.parsableFieldsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_clientSessionIdLabel]-[_clientSessionIdTextField]-(fieldSeparator)-[_customerIdLabel]-[_customerIdTextField]-(fieldSeparator)-[_baseURLLabel]-[_baseURLTextField]-(fieldSeparator)-[_assetsBaseURLLabel]-[_assetsBaseURLTextField]-(fieldSeparator)-[_jsonButton]-|" options:0 metrics:metrics views:views]];

    // ContainerView constraints
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_explanation]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_parsableFieldsContainer]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_merchantIdLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_merchantIdTextField]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_amountLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_amountTextField]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_countryCodeLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_countryCodePicker]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_currencyCodeLabel]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_currencyCodePicker]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_isRecurringLabel]-[_isRecurringSwitch]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_groupMethodsLabel]-[_groupMethodsSwitch]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_payButton]-|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_explanation]-(fieldSeparator)-[_parsableFieldsContainer]-(fieldSeparator)-[_merchantIdLabel]-[_merchantIdTextField]-(groupSeparator)-[_amountLabel]-[_amountTextField]-(fieldSeparator)-[_countryCodeLabel]-[_countryCodePicker]-(fieldSeparator)-[_currencyCodeLabel]-[_currencyCodePicker]-(fieldSeparator)-[_isRecurringSwitch]-(fieldSeparator)-[_groupMethodsSwitch]-(fieldSeparator)-[_payButton]-|" options:0 metrics:metrics views:views]];

    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:superContainerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0], [NSLayoutConstraint constraintWithItem:superContainerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[superContainerView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[superContainerView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:views]];
    [superContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_containerView]|" options:0 metrics:nil views:views]];
    [superContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
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

- (BOOL)checkURL:(NSString *)url
{
    NSMutableArray<NSString *> *components;
    if (@available(iOS 7.0, *)) {
        NSURLComponents *finalComponents = [NSURLComponents componentsWithString:url];
        components = [[finalComponents.path componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:
                      [NSPredicate predicateWithFormat:@"length > 0"]].mutableCopy;
    }
    else {
        components = [[[NSURL URLWithString:url].path componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:
                      [NSPredicate predicateWithFormat:@"length > 0"]].mutableCopy;
    }
    
    
    NSArray<NSString *> *versionComponents = [kICAPIVersion componentsSeparatedByString:@"/"];
    switch (components.count) {
        case 0: {
            components = versionComponents.mutableCopy;
            break;
        }
        case 1: {
            if (![components[0] isEqualToString:versionComponents[0]]) {
                return NO;
            }
            [components addObject:versionComponents[1]];
            break;
        }
        case 2: {
            if (![components[0] isEqualToString:versionComponents[0]]) {
                return NO;
            }
            if (![components[1] isEqualToString:versionComponents[1]]) {
                return NO;
            }
            break;
        }
        default: {
            return NO;
            break;
        }
    }
    return YES;
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
    NSString *baseURL = self.baseURLTextField.text;
    [StandardUserDefaults setObject:baseURL forKey:kICBaseURL];
    NSString *assetsBaseURL = self.assetsBaseURLTextField.text;
    [StandardUserDefaults setObject:assetsBaseURL forKey:kICAssetsBaseURL];

    if (self.merchantIdTextField.text != nil) {
        NSString *merchantId = self.merchantIdTextField.text;
        [StandardUserDefaults setObject:merchantId forKey:kICMerchantId];
    }
    [StandardUserDefaults setInteger:self.amountValue forKey:kICPrice];
    [StandardUserDefaults setInteger:[self.countryCodePicker selectedRowInComponent:0] forKey:kICCountryCode];
    [StandardUserDefaults setInteger:[self.currencyCodePicker selectedRowInComponent:0] forKey:kICCurrency];

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
    if (![self checkURL:baseURL]) {
        [SVProgressHUD dismiss];
        NSMutableArray<NSString *> *components;
        if (@available(iOS 7.0, *)) {
            NSURLComponents *finalComponents = [NSURLComponents componentsWithString:baseURL];
            components = [[finalComponents.path componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"length > 0"]].mutableCopy;
        }
        else {
            components = [[[NSURL URLWithString:baseURL].path componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"length > 0"]].mutableCopy;
        }
        NSArray<NSString *> *versionComponents = [kICAPIVersion componentsSeparatedByString:@"/"];
        NSString *alertReason = [NSString stringWithFormat: @"This version of the connectSDK is only compatible with %@ , you supplied: '%@'",
                                 [versionComponents componentsJoinedByString: @"/"],
                                 [components componentsJoinedByString: @"/"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidBaseURLTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(alertReason, kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    self.session = [ICSession sessionWithClientSessionId:clientSessionId customerId:customerId baseURL:baseURL assetBaseURL:assetsBaseURL appIdentifier:kICApplicationIdentifier];

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

- (void)presentJsonDialog
{
    self.jsonDialogViewController.callback = self;
    [self presentViewController:self.jsonDialogViewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark Continue shopping target

- (void)didSelectContinueShopping
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Payment finished target

- (void)didFinishPayment:(ICPreparedPaymentRequest *)preparedPaymentRequest {
    ICEndViewController *end = [[ICEndViewController alloc] init];
    end.target = self;
    end.viewFactory = self.viewFactory;
    end.preparedPaymentRequest = preparedPaymentRequest;
    [self.navigationController pushViewController:end animated:YES];
}

#pragma mark -
#pragma mark Parse Json target
- (void)success:(ICStartPaymentParsedJsonData *)data {
    if (data.clientApiUrl != nil) {
        self.baseURLTextField.text = data.clientApiUrl;
    }
    if (data.assetUrl != nil) {
        self.assetsBaseURLTextField.text = data.assetUrl;
    }
    if (data.clientSessionId != nil) {
        self.clientSessionIdTextField.text = data.clientSessionId;
    }
    if (data.customerId != nil) {
        self.customerIdTextField.text = data.customerId;
    }
}

#pragma mark -
@end
