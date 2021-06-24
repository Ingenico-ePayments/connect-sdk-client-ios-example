//
// Created by Sjors de Haas on 22/04/2021.
// Copyright (c) 2021 Ingenico. All rights reserved.
//

#import "ICJsonDialogViewController.h"
#import "ICStartPaymentParsedJsonData.h"
#import "ICParseJsonTarget.h"
#import "ICViewFactory.h"
#import "ICAppConstants.h"

@interface ICJsonDialogViewController () <UITextViewDelegate>

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *buttonContainer;
@property (strong, nonatomic) UIView *dialogView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIButton *parseButton;
@property (strong, nonatomic) UILabel *dialogTitle;
@property (strong, nonatomic) UITextView *dialogMessage;
@property (strong, nonatomic) UITextView *dialogInputText;
@property (strong, nonatomic) UITextView *errorLabel;

@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) ICStartPaymentParsedJsonData *sessionData;

@property (strong, nonatomic) ICViewFactory *viewFactory;

@end

@implementation ICJsonDialogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewFactory = [[ICViewFactory alloc] init];
    self.placeholderText = NSLocalizedStringFromTable(@"JsonPlaceholder", kICAppLocalizable, nil);

    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 10;
    [self.view addSubview:self.containerView];

    self.dialogView = [[UIView alloc] init];
    self.dialogView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dialogView.layer.cornerRadius = 10;
    [self.containerView addSubview:self.dialogView];

    self.buttonContainer = [[UIView alloc]init];
    self.buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.buttonContainer];

    self.dismissButton = [self.viewFactory buttonWithType:ICButtonTypeSecondary];
    self.dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *dismissButtonTitle = NSLocalizedStringFromTable(@"Dismiss", kICAppLocalizable, nil);
    [self.dismissButton setTitle:dismissButtonTitle forState:UIControlStateNormal];
    self.dismissButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [self.dismissButton addTarget:self action:@selector(dismissPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer addSubview:self.dismissButton];

    self.parseButton = [self.viewFactory buttonWithType:ICButtonTypePrimary];
    self.parseButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *parseButtonTitle = NSLocalizedStringFromTable(@"Parse", kICAppLocalizable, nil);
    [self.parseButton setTitle:parseButtonTitle forState:UIControlStateNormal];
    [self.parseButton addTarget:self action:@selector(parsePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer addSubview:self.parseButton];

    self.dialogTitle = [[UILabel alloc] init];
    self.dialogTitle.translatesAutoresizingMaskIntoConstraints = NO;
    self.dialogTitle.text = NSLocalizedStringFromTable(@"Paste", kICAppLocalizable, nil);
    [self.dialogTitle setTextAlignment:NSTextAlignmentCenter];
    [self.dialogView addSubview:self.dialogTitle];

    self.dialogMessage = [[UITextView alloc] init];
    self.dialogMessage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dialogMessage setTextAlignment:NSTextAlignmentLeft];
    self.dialogMessage.editable = NO;
    self.dialogMessage.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.dialogMessage.text = NSLocalizedStringFromTable(@"JsonDialogMessage", kICAppLocalizable, nil);
    [self.dialogView addSubview:self.dialogMessage];

    self.dialogInputText = [[UITextView alloc] init];
    self.dialogInputText.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dialogInputText setTextAlignment:NSTextAlignmentLeft];
    self.dialogInputText.textColor = [UIColor lightGrayColor];
    self.dialogInputText.delegate = self;
    self.dialogInputText.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    self.dialogInputText.layer.cornerRadius = 10;
    self.dialogInputText.text = self.placeholderText;
    [self.dialogView addSubview:self.dialogInputText];

    self.errorLabel = [[UITextView alloc] init];
    self.errorLabel.textColor = [UIColor redColor];
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.errorLabel.editable = NO;
    [self.dialogView addSubview:self.errorLabel];

    NSDictionary *viewMapping = NSDictionaryOfVariableBindings(_containerView, _dialogView, _buttonContainer, _dismissButton, _parseButton, _dialogTitle, _dialogMessage, _dialogInputText, _errorLabel);
    // Format buttons with equal gravity
    [self.buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_dismissButton]-(20)-[_parseButton(==_dismissButton)]|" options:0 metrics:nil views:viewMapping]];

    // Horizontal and vertical constraints for the dialogView
    [self.dialogView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_dialogTitle]-|" options:0 metrics:nil views:viewMapping]];
    [self.dialogView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_dialogMessage]-|" options:0 metrics:nil views:viewMapping]];
    [self.dialogView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[_dialogInputText]-(10)-|" options:0 metrics:nil views:viewMapping]];
    [self.dialogView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[_errorLabel]-(10)-|" options:0 metrics:nil views:viewMapping]];
    [self.dialogView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_dialogTitle]-(20)-[_dialogMessage(40)]-(20)-[_dialogInputText(150)]-[_errorLabel(40)]" options:0 metrics:nil views:viewMapping]];

    // Horizontal constraints for the containerView
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_dialogView]|" options:0 metrics:nil views:viewMapping]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_buttonContainer]-|" options:0 metrics:nil views:viewMapping]];

    // DON'T CONSTRAIN CONTAINERVIEW WITH | | AS THIS WILL CONSTRAIN THE VIEW AGAINST THE SUPERVIEW BORDERS. (hence centering fails)
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_containerView]" options:0 metrics:nil views:viewMapping]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_containerView]" options:0 metrics:nil views:viewMapping]];

    // Center containerView on the screen
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    // Vertical Constraints in the containerView
    // dialogView to the top
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dialogView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];

    // buttonContainer to the bottom
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];

    // Size the containerview, buttoncontainer and dialogview
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.58 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.9 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dialogView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeHeight multiplier:0.9 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0]];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = nil;
        textView.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text length] == 0) {
        textView.text = self.placeholderText;
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)parsePressed
{
    NSString *jsonString = self.dialogInputText.text;
    // Is nil or empty check + is placeholder check
    if ([jsonString length] == 0 || [jsonString isEqualToString:self.placeholderText]) {
        return [self jsonParsingFailed];
    }

    [self parseJson:jsonString];

    ICStartPaymentParsedJsonData *data = self.sessionData;

    if (data == nil) {
        // Parsing failed, show errorLabel
        [self jsonParsingFailed];
    } else if (self.callback != nil) {
        // Parsing succeeded, call callback and dismiss.
        [self.callback success:data];
        [self dismissPressed];
    } else {
        // Parsing succeeded but target reference was lost. Dismiss viewcontroller.
        [self dismissPressed];
    }

}

- (void)parseJson:(NSString *)input {
    @try
    {
        self.sessionData = [[ICStartPaymentParsedJsonData alloc] initWithJSONString:input];
    }
    @catch(NSException * exception) {
        self.sessionData = nil;
    }
    // Validate if JSON parsing succeeded
    if (![self isValidSessionJson:self.sessionData]) {
        self.sessionData = nil;
    }
}

- (BOOL)isValidSessionJson:(ICStartPaymentParsedJsonData *)data
{
    if (data.customerId != nil
        || data.clientSessionId != nil
        || data.clientApiUrl != nil
        || data.assetUrl != nil) {
        // At least one property was parsed from the JSON, treat it as valid
        return YES;
    } else {
        return NO;
    }
}

- (void)jsonParsingFailed
{
    self.errorLabel.text = NSLocalizedStringFromTable(@"JsonErrorMessage", kICAppLocalizable, nil);
}

- (void)dismissPressed
{
    self.dialogInputText.text = self.placeholderText;
    self.dialogInputText.textColor = [UIColor lightGrayColor];
    self.errorLabel.text = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end