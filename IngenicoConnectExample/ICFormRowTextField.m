//
//  ICFormRowTextField.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowTextField.h>

@implementation ICFormRowTextField

- (instancetype _Nonnull)initWithPaymentProductField: (nonnull ICPaymentProductField *)paymentProductField field: (nonnull ICFormRowField*)field {
    self = [super init];
    
    if (self) {
        self.paymentProductField = paymentProductField;
        self.field = field;
    }
    
    return self;
}


@end
