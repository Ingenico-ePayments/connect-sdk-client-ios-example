//
//  ICPaymentProductSelectionDelegate.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>
#import <IngenicoConnectExample/ICPaymentProductSelectionTarget.h>
#import <IngenicoConnectExample/ICPaymentRequestTarget.h>
#import <IngenicoConnectSDK/ICSession.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectExample/ICAppConstants.h>
#import <IngenicoConnectExample/ICPaymentProductViewController.h>
#import <IngenicoConnectExample/ICCardProductViewController.h>
#import <IngenicoConnectExample/ICPaymentFinishedTarget.h>


@interface ICPaymentProductsViewControllerTarget : NSObject <ICPaymentProductSelectionTarget, ICPaymentRequestTarget, PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) id <ICPaymentFinishedTarget> paymentFinishedTarget;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController session:(ICSession *)session context:(ICPaymentContext *)context viewFactory:(ICViewFactory *)viewFactory;
- (void)didSubmitPaymentRequest:(ICPaymentRequest *)paymentRequest success:(void (^)())succes failure:(void (^)())failure;

- (void)showApplePaySheetForPaymentProduct:(ICPaymentProduct *)paymentProduct withAvailableNetworks:(ICPaymentProductNetworks *)paymentProductNetworks;

@end
