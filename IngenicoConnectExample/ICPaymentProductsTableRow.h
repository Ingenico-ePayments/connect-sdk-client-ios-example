//
//  ICPaymentProductsTableRow.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICPaymentProductsTableRow : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSString *accountOnFileIdentifier;
@property (nonatomic) NSString *paymentProductIdentifier;
@property (strong, nonatomic) UIImage *logo;

@end
