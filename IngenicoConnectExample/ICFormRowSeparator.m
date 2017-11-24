//
//  ICFormRowSeparator.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICFormRowSeparator.h"

@implementation ICFormRowSeparator
- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        _text = text;
    }
    return self;
}
@end
