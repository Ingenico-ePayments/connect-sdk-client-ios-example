//
//  ICFormRowCurrency.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowWithInfoButton.h>
#import <IngenicoConnectExample/ICIntegerTextField.h>
#import <IngenicoConnectExample/ICFractionalTextField.h>
#import <IngenicoConnectSDK/ICPaymentProductField.h>
#import "ICFormRowField.h"
@interface ICFormRowCurrency : ICFormRowWithInfoButton

@property (strong, nonatomic) ICFormRowField *integerField;
@property (strong, nonatomic) ICFormRowField *fractionalField;
@property (strong, nonatomic) ICPaymentProductField *paymentProductField;
- (instancetype)initWithPaymentProductField:(ICPaymentProductField *)paymentProductField andIntegerField:(ICFormRowField *)integerField andFractionalField:(ICFormRowField *)fractionalField;
@end
