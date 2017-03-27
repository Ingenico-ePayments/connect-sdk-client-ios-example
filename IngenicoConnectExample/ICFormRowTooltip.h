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
@property (nonatomic, strong) NSString *tooltipIdentifier;
@property (strong, nonatomic) UIImage *tooltipImage;
@property (strong, nonatomic) NSString *tooltipText;

@end
