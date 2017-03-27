//
//  ICPaymentProductSelectionTarget.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICPaymentType.h>
#import <IngenicoConnectSDK/ICBasicPaymentProduct.h>
#import <IngenicoConnectSDK/ICAccountOnFile.h>

@protocol ICPaymentItem;

@protocol ICPaymentProductSelectionTarget <NSObject>

- (void)didSelectPaymentItem:(NSObject <ICBasicPaymentItem> *)paymentItem accountOnFile:(ICAccountOnFile *)accountOnFile;

@end
