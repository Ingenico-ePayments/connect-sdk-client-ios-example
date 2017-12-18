//
//  ICFormRowDate.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 09/10/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICFormRow.h"
#import <IngenicoConnectSDK/ICPaymentProductField.h>
@interface ICFormRowDate : ICFormRow
@property (strong, nonatomic) ICPaymentProductField * _Nonnull paymentProductField;
@end
