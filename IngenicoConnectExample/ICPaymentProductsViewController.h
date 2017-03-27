//
//  ICPaymentProductsViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <IngenicoConnectExample/ICPaymentProductSelectionTarget.h>
#import <IngenicoConnectExample/ICViewFactory.h>
#import <IngenicoConnectSDK/ICBasicPaymentProducts.h>

@class ICPaymentItems;

@interface ICPaymentProductsViewController : UITableViewController

@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (weak, nonatomic) id <ICPaymentProductSelectionTarget> target;
@property (strong, nonatomic) ICPaymentItems *paymentItems;
@property (nonatomic) NSUInteger amount;
@property (strong, nonatomic) NSString *currencyCode;

@end
