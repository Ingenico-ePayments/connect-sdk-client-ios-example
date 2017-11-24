//
//  ICFormRowCurrency.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowCurrency.h>

@implementation ICFormRowCurrency
- (instancetype)initWithPaymentProductField:(ICPaymentProductField *)paymentProductField andIntegerField:(ICFormRowField *)integerField andFractionalField:(ICFormRowField *)fractionalField
{
    self = [super init];
    if (self) {
        self.paymentProductField = paymentProductField;
        self.integerField = integerField;
        self.fractionalField = fractionalField;
    }
    return self;
}
@end
