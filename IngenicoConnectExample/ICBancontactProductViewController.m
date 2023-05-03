//
//  ICBancontactViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICBancontactProductViewController.h"
#import <IngenicoConnectSDK/ICThirdPartyStatus.h>
#import <IngenicoConnectSDK/ICThirdPartyStatusResponse.h>
#import "ICExternalAppStatusViewController.h"
#import "ICFormRowImage.h"
#import "ICImageTableViewCell.h"
#import "ICFormRowSmallLogo.h"
#import "ICLogoTableViewCell.h"
#import "ICSeparatorTableViewCell.h"
#import "ICFormRowSeparator.h"
#import "ICFormRowCoBrandsExplanation.h"
#import "ICPaymentProductsTableRow.h"
#import "ICFormRowCoBrandsSelection.h"
#import "ICFormRowQRCode.h"
#import "ICFormRowButton.h"
#import <IngenicoConnectSDK/ICPaymentItemConverter.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import "ICFormRowLabel.h"
@interface ICBancontactProductViewController ()
@property (nonatomic, strong, readonly) NSString *paymentId;
@property (nonatomic, strong, readonly) NSString *appRedirectURL;
@property (nonatomic, strong, readonly) NSString *qrCodeString;
@property (nonatomic, assign) ICThirdPartyStatus thirdPartyStatus;
@property (nonatomic, strong) void(^callback)();
@property (nonatomic, assign) CGFloat testTime;
@property (nonatomic, assign, getter=isPolling) BOOL polling;
@property (nonatomic, retain) ICExternalAppStatusViewController *statusViewController;
@end

@implementation ICBancontactProductViewController
- (void)registerReuseIdentifiers {
    [super registerReuseIdentifiers];
    [self.tableView registerClass:[ICImageTableViewCell class] forCellReuseIdentifier:[ICImageTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICSeparatorTableViewCell class] forCellReuseIdentifier:[ICSeparatorTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICLogoTableViewCell class] forCellReuseIdentifier:[ICLogoTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICCoBrandsSelectionTableViewCell class] forCellReuseIdentifier:[ICCoBrandsSelectionTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICCOBrandsExplanationTableViewCell class] forCellReuseIdentifier:[ICCOBrandsExplanationTableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ICPaymentProductTableViewCell class] forCellReuseIdentifier:[ICPaymentProductTableViewCell reuseIdentifier]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.statusViewController = [[ICExternalAppStatusViewController alloc]init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self startPolling];
    }
}
- (void)startPolling {
    self.polling = YES;
    __weak __block ICBancontactProductViewController *weakSelf = self;
    self.callback = ^ {
        [weakSelf pollWithCallback:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.callback);
        }];
    };
    self.callback();

}
- (void) updateTextFieldCell:(ICTextFieldTableViewCell *)cell row: (ICFormRowTextField *)row {
    [super updateTextFieldCell:cell row:row];
    if ([row.paymentProductField.identifier isEqualToString:@"cardNumber"]) {
        if([self.confirmedPaymentProducts containsObject:self.paymentItem.identifier]) {
            CGFloat productIconSize = 35.2;
            CGFloat padding = 4.4;

            UIView *outerView = [[UIView alloc]initWithFrame:CGRectMake(padding, padding, productIconSize, productIconSize)];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, productIconSize, productIconSize)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [outerView addSubview:imageView];
            outerView.contentMode = UIViewContentModeScaleAspectFit;

            imageView.image = row.logo;
            cell.rightView = outerView;
        }
        else {
            row.logo = nil;
            cell.rightView = [[UIView alloc]init];
        }
    }
}
-(ICTextFieldTableViewCell *)cellForTextField:(ICFormRowTextField *)row tableView:(UITableView *)tableView {
    ICTextFieldTableViewCell *cell = [super cellForTextField:row tableView:tableView];

    [self updateTextFieldCell:cell row:row];

    return cell;
}

-(ICTableViewCell *)formRowCellForRow:(ICFormRow *)abstractRow atIndexPath:(NSIndexPath *)indexPath {
    ICTableViewCell *cell;
    if ([abstractRow isKindOfClass:[ICFormRowQRCode class]]) {
        ICFormRowQRCode *row = (ICFormRowQRCode *)abstractRow;
        cell = [self cellForImage:row tableView:self.tableView];
    }
    else if ([abstractRow isKindOfClass:[ICFormRowSmallLogo class]]) {
        ICFormRowSmallLogo *row = (ICFormRowSmallLogo *)abstractRow;
        cell = [self cellForLogo:row tableView:self.tableView];
    }
    else if ([abstractRow isKindOfClass:[ICFormRowSeparator class]]) {
        ICFormRowSeparator *row = (ICFormRowSeparator *)abstractRow;
        cell = [self cellForSeparator:row tableView:self.tableView];
    }
    else {
        cell = [super formRowCellForRow:abstractRow atIndexPath:indexPath];
    }
    return cell;
}
-(void)pollWithCallback:(void(^)())callback {
    void (^success)(ICThirdPartyStatusResponse *) = ^(ICThirdPartyStatusResponse *response){
        ICThirdPartyStatus status = response.thirdPartyStatus;
        
        // START: Uncomment the following code to progress the processing screen
        //self.testTime += 1.0;
        //if (self.testTime >= 10.0) {
        //    status = ICThirdPartyStatusInitialized;
        //}
        //if (self.testTime >= 20.0) {
        //    status = ICThirdPartyStatusAuthorized;
        //}
        //if (self.testTime >= 30.0) {
        //    status = ICThirdPartyStatusCompleted;
        //}
        // END
        
        
        if (self.thirdPartyStatus == status) {
            if (status != ICThirdPartyStatusCompleted) {
                callback();
            }
            return;
        }
        self.thirdPartyStatus = status;
        switch (self.thirdPartyStatus) {
            case ICThirdPartyStatusWaiting:
            {
                callback();
                break;
            }
            case ICThirdPartyStatusInitialized:
            {
                [self presentViewController:self.statusViewController animated:YES completion:^{
                    self.statusViewController.externalAppStatus = ICThirdPartyStatusInitialized;
                    callback();
                }];
                break;
            }
            case ICThirdPartyStatusAuthorized:
            {
                self.statusViewController.externalAppStatus = ICThirdPartyStatusAuthorized;
                callback();
                break;
            }
            case ICThirdPartyStatusCompleted:
            {
                self.statusViewController.externalAppStatus = ICThirdPartyStatusAuthorized;
                [self.statusViewController dismissViewControllerAnimated:YES completion:^{
                    ICPaymentRequest *request = [[ICPaymentRequest alloc] init];
                    request.paymentProduct = (ICPaymentProduct *)self.paymentItem;
                    request.accountOnFile = self.accountOnFile;
                    request.tokenize = self.inputData.tokenize;
                    [self.paymentRequestTarget didSubmitPaymentRequest:request];
                }];
                break;
            }
                
        }
    };
    [self.session thirdPartyStatusForPayment:self.paymentId success:success failure:^(NSError *error) {
        // START: Uncomment the following code to test locally
        //ICThirdPartyStatusResponse *response = [[ICThirdPartyStatusResponse alloc]init];
        //response.thirdPartyStatus = ICThirdPartyStatusWaiting;
        //success(response);
        // END

        NSLog(@"%@", [error localizedDescription]);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setCustomServerJSON:(NSDictionary<NSString *,NSObject *> *)customServerJSON
{
    _customServerJSON = customServerJSON;
    NSDictionary<NSString *, NSObject *> *paymentDict = (NSDictionary<NSString *, NSObject *> *)self.customServerJSON[@"payment"];
    _paymentId = (NSString *)paymentDict[@"id"];
    NSDictionary<NSString *, NSObject *> *merchantAction = (NSDictionary<NSString *, NSObject *> *)customServerJSON[@"merchantAction"];
    NSArray<NSDictionary<NSString *, NSObject *> *> *formFields = (NSArray<NSDictionary<NSString *, NSObject *> *> *)merchantAction[@"formFields"];
    ICPaymentItemConverter *converter = [[ICPaymentItemConverter alloc]init];
    [self.paymentItem.fields.paymentProductFields removeAllObjects];
    [converter setPaymentProductFields:self.paymentItem.fields JSON:formFields];
//    [self.paymentItem.fields.paymentProductFields removeAllObjects];
//    for (NSDictionary<NSString *, NSObject *> *fieldJSON in formFields) {
//        ICPaymentProductField *field = [[ICPaymentProductField alloc] init];
//        if (field != nil) {
//            [self.paymentItem.fields.paymentProductFields addObject:field];
//        }
//    }
    NSArray<NSDictionary<NSString *, NSString *> *> *showData = (NSArray<NSDictionary<NSString *, NSString *> *> *)merchantAction[@"showData"];
    for (NSDictionary<NSString *, NSString *> *dict in showData) {
        if ([dict[@"key"] isEqualToString:@"URLINTENT"]) {
            _appRedirectURL = dict[@"value"];
        }
    }
    for (NSDictionary<NSString *, NSString *> *dict in showData) {
        if ([dict[@"key"] isEqualToString:@"QRCODE"]) {
            _qrCodeString = dict[@"value"];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ICFormRow *abstractRow = self.formRows[indexPath.row];
    if ([abstractRow isKindOfClass: [ICFormRowSmallLogo class]]) {
        ICFormRowSmallLogo *row = (ICFormRowSmallLogo *)abstractRow;
        ICLogoTableViewCell *cell = [self cellForLogo:row tableView:tableView];
        return [cell cellSizeWithWidth:self.tableView.frame.size.width].height;
    }
    if ([abstractRow isKindOfClass: [ICFormRowImage class]]) {
        ICFormRowImage *row = (ICFormRowImage *)abstractRow;
        ICImageTableViewCell *cell = [self cellForImage:row tableView:tableView];
        CGFloat tableWidth = self.tableView.frame.size.width;
        return [cell cellSizeWithWidth:MIN(tableWidth, 320)].height;
    }
    if (([abstractRow isKindOfClass:[ICFormRowCoBrandsExplanation class]] || [abstractRow isKindOfClass:[ICPaymentProductsTableRow class]]) && ![abstractRow isEnabled]) {
        return 0;
    }
    else if ([abstractRow isKindOfClass:[ICFormRowCoBrandsExplanation class]]) {
        NSAttributedString *cellString = ICCOBrandsExplanationTableViewCell.cellString;
        CGRect rect = [cellString boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return rect.size.height + 20;
    }
    else if ([abstractRow isKindOfClass:[ICFormRowCoBrandsSelection class]]) {
        return 30;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (ICLabelTableViewCell *)cellForLabel:(ICFormRowLabel *)row tableView:(UITableView *)tableView
{
    ICLabelTableViewCell *cell = (ICLabelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICLabelTableViewCell reuseIdentifier]];
    cell.label = row.text;
    cell.bold = row.bold;
    return cell;
}

- (ICImageTableViewCell *)cellForImage:(ICFormRowImage *)row tableView:(UITableView *)tableView {
    ICImageTableViewCell *cell = (ICImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICImageTableViewCell reuseIdentifier]];
    
    cell.displayImage = row.image;
    
    return cell;
}

- (ICLogoTableViewCell *)cellForLogo:(ICFormRowSmallLogo *)row tableView:(UITableView *)tableView {
    ICLogoTableViewCell *cell = (ICLogoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICLogoTableViewCell reuseIdentifier]];
    
    cell.displayImage = row.image;
    
    return cell;

}
- (ICSeparatorTableViewCell *)cellForSeparator:(ICFormRowSeparator *)row tableView:(UITableView *)tableView {
    ICSeparatorTableViewCell *cell = (ICSeparatorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ICSeparatorTableViewCell reuseIdentifier]];
    
    cell.separatorText = row.text;
    
    return cell;
    
}

-(void)insertSeparator
{
    NSString *separatorTextKey = @"gc.general.paymentProducts.3012.divider";
    NSString *separatorTextValue = NSLocalizedStringWithDefaultValue(separatorTextKey, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], @"Or", @"");
    ICFormRowSeparator *separator = [[ICFormRowSeparator alloc]init];
    separator.text = separatorTextValue;
    [self.formRows insertObject:separator atIndex:0];
}
-(void)insertButtonWithKey:(NSString *)key value:(NSString *)value selector:(SEL)selector enabled:(BOOL)enabled
{
    NSString *buttonTitle = NSLocalizedStringWithDefaultValue(key, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], value, @"");
    ICFormRowButton *button = [[ICFormRowButton alloc]init];
    button.title = buttonTitle;
    button.isEnabled = enabled;
    button.target = self;
    button.action = selector;
    [self.formRows insertObject:button atIndex:0];
}
-(void)insertLabelWithKey:(NSString *)key value:(NSString *)value isBold:(BOOL)bold
{
    NSString *labelText = NSLocalizedStringWithDefaultValue(key, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], value, @"");
    ICFormRowLabel *label = [[ICFormRowLabel alloc]init];
    label.text = labelText;
    label.bold = bold;
    [self.formRows insertObject:label atIndex:0];

}
-(void)insertQRCode
{
    ICFormRowQRCode *code  = [[ICFormRowQRCode alloc]initWithString:self.qrCodeString];
    [self.formRows insertObject:code atIndex:0];
}
-(void)insertLogo
{
    ICFormRowSmallLogo *code  = [[ICFormRowSmallLogo alloc]initWithImage:self.paymentItem.displayHints.logoImage];
    [self.formRows insertObject:code atIndex:0];
}

- (void)initializeFormRows
{
    [super initializeFormRows];
    [self insertLabelWithKey:@"gc.general.paymentProducts.3012.payWithCardLabel" value:@"Pay with your Bancontact card" isBold:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self insertSeparator];
        [self insertLabelWithKey:@"gc.general.paymentProducts.3012.qrCodeLabel" value:@"Open the app on your phone, click 'Pay' and scan with a QR code." isBold:NO];
        [self insertQRCode];
        [self insertLabelWithKey:@"gc.general.paymentProducts.3012.qrCodeShortLabel" value:@"Scan a QR code" isBold:YES];
    }
    [self insertSeparator];
    [self insertButtonWithKey:@"gc.general.paymentProducts.3012.payWithAppButtonText" value:@"Open App" selector:@selector(didTapOpenAppButton) enabled:YES];
    [self insertLabelWithKey:@"gc.general.paymentProducts.3012.payWithAppButtonText" value:@"Pay with your bancontact app" isBold:NO];
    [self insertLabelWithKey:@"gc.general.paymentProducts.3012.introduction" value:@"How would you like to pay?" isBold:YES];
    [self insertLogo];

}

-(void)didTapOpenAppButton
{
    // START: Remove the following code to test locally
    NSURL *url = [NSURL URLWithString:self.appRedirectURL];
    if (url == nil) {
        return;
    }
    // END
    
    // START: Uncomment the following to test locally
    //NSURL *url = [NSURL URLWithString: @"http://www.google.com"];
    // END
    if (![UIApplication.sharedApplication canOpenURL:url]) {
        return;
    }
    if ([UIApplication.sharedApplication respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
    else {
        [UIApplication.sharedApplication openURL:url];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReturn) name:UIApplicationDidBecomeActiveNotification object:nil];

}

-(void)didReturn
{
    // START: Uncomment the following code to test locally
    //self.testTime += 10.0;
    // END
    if (!self.polling) {
        [self startPolling];
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
