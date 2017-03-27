//
//  ICFormRowTextField.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowWithInfoButton.h>
#import <IngenicoConnectExample/ICTextField.h>
#import <IngenicoConnectSDK/ICPaymentProductField.h>

@interface ICFormRowTextField : ICFormRowWithInfoButton

@property (strong, nonatomic) ICTextField *textField;
@property (strong, nonatomic) ICPaymentProductField *paymentProductField;
@property (strong, nonatomic) UIImageView *logo;

@end
