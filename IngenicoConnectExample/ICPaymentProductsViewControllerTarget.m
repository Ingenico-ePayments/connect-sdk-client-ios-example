//
//  ICPaymentProductSelectionDelegate.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <IngenicoConnectExample/ICPaymentProductsViewControllerTarget.h>
#import <IngenicoConnectSDK/ICBasicPaymentProductGroup.h>
#import <IngenicoConnectSDK/ICBasicPaymentProductGroups.h>
#import <IngenicoConnectExample/ICEndViewController.h>
#import <IngenicoConnectSDK/ICPaymentContext.h>
#import <IngenicoConnectSDK/ICPaymentAmountOfMoney.h>

@interface ICPaymentProductsViewControllerTarget ()

@property (strong, nonatomic) ICSession *session;
@property (strong, nonatomic) ICPaymentContext *context;
@property (weak, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (strong, nonatomic) ICPaymentProduct *applePayPaymentProduct;
@property (strong, nonatomic) NSArray *summaryItems;
@property (strong, nonatomic) PKPaymentAuthorizationViewController * authorizationViewController;
@property (strong, nonatomic) NSBundle *sdkBundle;

@end

@implementation ICPaymentProductsViewControllerTarget


- (instancetype)initWithNavigationController:(UINavigationController *)navigationController session:(ICSession *)session context:(ICPaymentContext *)context viewFactory:(ICViewFactory *)viewFactory {
    self = [super init];
    self.navigationController = navigationController;
    self.session = session;
    self.context = context;
    self.viewFactory = viewFactory;
    self.sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];

    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class ICPaymentProductsViewControllerTarget"
                                 userInfo:nil];
    return nil;
}


#pragma mark PaymentProduct selection target

- (void)didSelectPaymentItem:(NSObject <ICBasicPaymentItem> *)paymentItem accountOnFile:(ICAccountOnFile *)accountOnFile;
{
    [SVProgressHUD showWithStatus:NSLocalizedStringFromTableInBundle(@"gc.app.general.loading.body", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil)];
    
    // ***************************************************************************
    //
    // After selecting a payment product or an account on file associated to a
    // payment product in the payment product selection screen, the ICSession
    // object is used to retrieve all information for this payment product.
    //
    // Afterwards, a screen is shown that allows the user to fill in all
    // relevant information, unless the payment product has no fields.
    // This screen is also not part of the SDK and is offered for demonstration
    // purposes only.
    //
    // If the payment product has no fields, the merchant is responsible for
    // fetching the URL for a redirect to a third party and show the corresponding
    // website.
    //
    // ***************************************************************************
    
    if ([paymentItem isKindOfClass:[ICBasicPaymentProduct class]]) {
        [self.session paymentProductWithId:paymentItem.identifier context:self.context success:^(ICPaymentProduct *paymentProduct) {
            if ([paymentItem.identifier isEqualToString:kICApplePayIdentifier]) {
                [self showApplePayPaymentItem:paymentProduct];
            } else {
                [SVProgressHUD dismiss];
                if (paymentProduct.fields.paymentProductFields.count > 0) {
                    [self showPaymentItem:paymentProduct accountOnFile:accountOnFile];
                } else {
                    ICPaymentRequest *request = [[ICPaymentRequest alloc] init];
                    request.paymentProduct = paymentProduct;
                    request.accountOnFile = accountOnFile;
                    request.tokenize = NO;
                    [self didSubmitPaymentRequest:request];
                }
            }
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"PaymentProductErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
    else if ([paymentItem isKindOfClass:[ICBasicPaymentProductGroup class]]) {
        [self.session paymentProductGroupWithId:paymentItem.identifier context:self.context success:^(ICPaymentProductGroup *paymentProductGroup) {
            [SVProgressHUD dismiss];
            [self showPaymentItem:paymentProductGroup accountOnFile:accountOnFile];
        }                               failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"PaymentProductErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)showPaymentItem:(NSObject <ICPaymentItem> *)paymentItem accountOnFile:(ICAccountOnFile *)accountOnFile {
    ICPaymentProductViewController *paymentProductForm = [[ICPaymentProductViewController alloc] init];
    paymentProductForm.paymentRequestTarget = self;
    paymentProductForm.paymentItem = paymentItem;
    paymentProductForm.accountOnFile = accountOnFile;
    paymentProductForm.context = self.context;
    paymentProductForm.viewFactory = self.viewFactory;
    paymentProductForm.amount = self.context.amountOfMoney.totalAmount;
    paymentProductForm.session = self.session;
    [self.navigationController pushViewController:paymentProductForm animated:YES];
}
#pragma mark ApplePay selection handling

- (void)showApplePayPaymentItem:(ICPaymentProduct *)paymentProduct {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && [PKPaymentAuthorizationViewController canMakePayments]) {
        [SVProgressHUD showWithStatus:NSLocalizedStringFromTableInBundle(@"gc.app.general.loading.body", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil)];
        
        // ***************************************************************************
        //
        // If the payment product is Apple Pay, the supported networks are retrieved.
        //
        // A view controller for Apple Pay will be shown when these networks have been
        // retrieved.
        //
        // ***************************************************************************
        
        [self.session paymentProductNetworksForProductId:kICApplePayIdentifier context:self.context success:^(ICPaymentProductNetworks *paymentProductNetworks) {
            [self showApplePaySheetForPaymentProduct:paymentProduct withAvailableNetworks:paymentProductNetworks];
            [SVProgressHUD dismiss];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"PaymentProductNetworksErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)showApplePaySheetForPaymentProduct:(ICPaymentProduct *)paymentProduct withAvailableNetworks:(ICPaymentProductNetworks *)paymentProductNetworks {
    
    // This merchant should be the merchant id specified in the merchants developer portal.
    NSString *merchantId = [StandardUserDefaults objectForKey:kICMerchantId];
    if (merchantId == nil) {
        return;
    }
    
    [self generateSummaryItems];
    
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    [paymentRequest setCountryCode:self.context.countryCode];
    [paymentRequest setCurrencyCode:self.context.amountOfMoney.currencyCode];
    [paymentRequest setSupportedNetworks:paymentProductNetworks.paymentProductNetworks];
    [paymentRequest setPaymentSummaryItems:self.summaryItems];
    
    // These capabilities should always be set to this value unless the merchant specifically does not want either Debit or Credit
    [paymentRequest setMerchantCapabilities:PKMerchantCapability3DS | PKMerchantCapabilityDebit | PKMerchantCapabilityCredit];
    
    // This merchant id is set in the merchants apple developer portal and is linked to a certificate
    [paymentRequest setMerchantIdentifier:merchantId];
    
    // These shipping and billing address fields are optional and can be chosen by the merchant
    [paymentRequest setRequiredShippingAddressFields: PKAddressFieldAll];
    [paymentRequest setRequiredBillingAddressFields:PKAddressFieldAll];
    
    self.authorizationViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    
    [self.authorizationViewController setDelegate:self];
    
    // The authorizationViewController will be nil if the paymentRequest was incomplete or not created correctly
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:paymentProductNetworks.paymentProductNetworks] && self.authorizationViewController != nil) {
        self.applePayPaymentProduct = paymentProduct;
        [self.navigationController.topViewController presentViewController:self.authorizationViewController animated:YES completion:nil];
    }
}

- (void)generateSummaryItems {
    
    // ***************************************************************************
    //
    // The summaryItems for the paymentRequest is a list of values with the last
    // value being the total and having the name of the merchant as label.
    //
    // A list of subtotal, shipping cost, and total is created below as example.
    // The values are specified in cents and converted to a NSDecimalNumber with
    // a exponent of -2.
    //
    // ***************************************************************************
    
    long subtotal = self.context.amountOfMoney.totalAmount;
    long shippingCost = 200;
    long total = subtotal + shippingCost;
    
    NSMutableArray *summaryItems = [[NSMutableArray alloc] init];
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:NSLocalizedStringFromTableInBundle(@"gc.app.general.shoppingCart.subtotal", kICSDKLocalizable, self.sdkBundle, @"subtotal summary item title") amount:[NSDecimalNumber decimalNumberWithMantissa:subtotal exponent:-2 isNegative:NO]]];
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:NSLocalizedStringFromTableInBundle(@"gc.app.general.shoppingCart.shippingCost", kICSDKLocalizable, self.sdkBundle, @"shipping cost summary item title") amount:[NSDecimalNumber decimalNumberWithMantissa:shippingCost exponent:-2 isNegative:NO]]];
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:@"Merchant Name" amount:[NSDecimalNumber decimalNumberWithMantissa:total exponent:-2 isNegative:NO] type:PKPaymentSummaryItemTypeFinal]];
    
    self.summaryItems = summaryItems;
}

#pragma mark -
#pragma mark Payment request target;

- (void)didSubmitPaymentRequest:(ICPaymentRequest *)paymentRequest
{
    [self didSubmitPaymentRequest:paymentRequest success:nil failure:nil];
}

- (void)didSubmitPaymentRequest:(ICPaymentRequest *)paymentRequest success:(void (^)())succes failure:(void (^)())failure
{
    [SVProgressHUD showWithStatus:NSLocalizedStringFromTableInBundle(@"gc.app.general.loading.body", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil)];
    [self.session preparePaymentRequest:paymentRequest success:^(ICPreparedPaymentRequest *preparedPaymentRequest) {
        [SVProgressHUD dismiss];
        
        // ***************************************************************************
        //
        // The information contained in preparedPaymentRequest is stored in such a way
        // that it can be sent to the IngenicoConnect platform via your server.
        //
        // ***************************************************************************
        
        [self.paymentFinishedTarget didFinishPayment];
        
        if (succes != nil) {
            succes();
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"SubmitErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        if (failure != nil) {
            failure();
        }
    }];
}

- (void)didCancelPaymentRequest
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark PKPaymentAuthorizationViewControllerDelegate


// Sent to the delegate after the user has acted on the payment request.  The application
// should inspect the payment to determine whether the payment request was authorized.
//
// If the application requested a shipping address then the full addresses is now part of the payment.
//
// The delegate must call completion with an appropriate authorization status, as may be determined
// by submitting the payment credential to a processing gateway for payment authorization.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // ***************************************************************************
        //
        // The information contained in preparedPaymentRequest is stored in such a way
        // that it can be sent to the IngenicoConnect platform via your server.
        //
        // ***************************************************************************
        
        ICPaymentRequest *request = [[ICPaymentRequest alloc] init];
        request.paymentProduct = self.applePayPaymentProduct;
        request.tokenize = NO;
        [request setValue:[[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding] forField:@"encryptedPaymentData"];
        [request setValue:payment.token.transactionIdentifier forField:@"transactionId"];
        [self didSubmitPaymentRequest:request success:^{
            completion(PKPaymentAuthorizationStatusSuccess);
        } failure:^{
            completion(PKPaymentAuthorizationStatusFailure);
        }];
        
        
    });
}


// Sent to the delegate when payment authorization is finished.  This may occur when
// the user cancels the request, or after the PKPaymentAuthorizationStatus parameter of the
// paymentAuthorizationViewController:didAuthorizePayment:completion: has been shown to the user.
//
// The delegate is responsible for dismissing the view controller in this method.
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    self.applePayPaymentProduct = nil;
    [self.authorizationViewController dismissViewControllerAnimated:YES completion:nil];
}


// Sent when the user has selected a new payment card.  Use this delegate callback if you need to
// update the summary items in response to the card type changing (for example, applying credit card surcharges)
//
// The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
// until it has invoked the completion block.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                    didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod
                                completion:(void (^)(NSArray<PKPaymentSummaryItem *> *summaryItems))completion NS_AVAILABLE_IOS(9_0)
{
    completion(self.summaryItems);
}


#pragma mark -

@end
