//
//  ICTableSectionConverter.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IngenicoConnectExample/ICPaymentProductsTableSection.h>
#import <IngenicoConnectSDK/ICBasicPaymentProducts.h>

@class ICPaymentItems;

@interface ICTableSectionConverter : NSObject

+ (ICPaymentProductsTableSection *)paymentProductsTableSectionFromAccountsOnFile:(NSArray *)accountsOnFile paymentItems:(ICPaymentItems *)paymentItems;
+ (ICPaymentProductsTableSection *)paymentProductsTableSectionFromPaymentItems:(ICPaymentItems *)paymentItems;

@end
