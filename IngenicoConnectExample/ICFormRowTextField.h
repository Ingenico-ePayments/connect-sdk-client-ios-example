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
#import <IngenicoConnectExample/ICFormRowField.h>

@interface ICFormRowTextField : ICFormRowWithInfoButton

- (instancetype _Nonnull)initWithPaymentProductField: (nonnull ICPaymentProductField *)paymentProductField field: (nonnull ICFormRowField*)field;

@property (strong, nonatomic) ICPaymentProductField * _Nonnull paymentProductField;
@property (strong, nonatomic) UIImage * _Nullable logo;
@property (strong, nonatomic) ICFormRowField * _Nonnull field;

@end
