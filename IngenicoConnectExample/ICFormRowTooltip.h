//
//  ICFormRowTooltip.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRow.h>
#import <IngenicoConnectSDK/ICPaymentProductField.h>

@interface ICFormRowTooltip : ICFormRow

@property (strong, nonatomic) ICPaymentProductField *paymentProductField;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *text;

@end
