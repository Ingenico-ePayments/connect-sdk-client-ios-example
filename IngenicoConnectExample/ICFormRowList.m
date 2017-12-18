//
//  ICFormRowList.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowList.h>

@implementation ICFormRowList


- (instancetype _Nonnull)initWithPaymentProductField: (nonnull ICPaymentProductField *)paymentProductField {
    self = [super init];
    
    if (self) {
        self.items = [[NSMutableArray alloc]init];
        self.paymentProductField = paymentProductField;
    }
    
    return self;
}

@end
