//
//  ICStartViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <PassKit/PassKit.h>
#import <UIKit/UIKit.h>

#import <IngenicoConnectExample/ICPaymentProductSelectionTarget.h>
#import <IngenicoConnectExample/ICPaymentRequestTarget.h>
#import <IngenicoConnectExample/ICContinueShoppingTarget.h>
#import <IngenicoConnectExample/ICPaymentFinishedTarget.h>
#import <IngenicoConnectExample/ICParseJsonTarget.h>

@interface ICStartViewController : UIViewController <ICContinueShoppingTarget, ICPaymentFinishedTarget, ICParseJsonTarget>

@end
