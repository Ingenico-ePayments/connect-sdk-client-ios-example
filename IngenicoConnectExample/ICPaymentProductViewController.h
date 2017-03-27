//
//  ICPaymentProductViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <IngenicoConnectExample/ICViewFactory.h>
#import <IngenicoConnectSDK/ICPaymentProduct.h>
#import <IngenicoConnectSDK/ICAccountOnFile.h>
#import <IngenicoConnectExample/ICPaymentRequestTarget.h>
#import <IngenicoConnectSDK/ICSession.h>
#import <IngenicoConnectExample/ICCoBrandsSelectionTableViewCell.h>

@interface ICPaymentProductViewController : UITableViewController

@property (weak, nonatomic) id <ICPaymentRequestTarget> paymentRequestTarget;
@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (nonatomic) NSObject<ICPaymentItem> *paymentItem;
@property (strong, nonatomic) ICAccountOnFile *accountOnFile;
@property (strong, nonatomic) ICPaymentContext *context;
@property (nonatomic) NSUInteger amount;
@property (strong, nonatomic) ICSession *session;

@end
