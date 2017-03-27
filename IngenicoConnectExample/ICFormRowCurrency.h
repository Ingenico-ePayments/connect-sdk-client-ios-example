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

@interface ICFormRowCurrency : ICFormRowWithInfoButton

@property (strong, nonatomic) ICIntegerTextField *integerTextField;
@property (strong, nonatomic) ICFractionalTextField *fractionalTextField;
@property (strong, nonatomic) ICPaymentProductField *paymentProductField;

@end
