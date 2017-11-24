//
//  ICFormRowLabel.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowLabel.h>

@implementation ICFormRowLabel

- (instancetype _Nonnull)initWithText:(nonnull NSString *)text {
    self = [super init];
    
    if (self) {
        self.text = text;
    }
    
    return self;
}

@end
