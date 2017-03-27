//
//  ICPaymentProductsTableSection.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICPaymentProductsTableSection.h>

@implementation ICPaymentProductsTableSection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rows = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
