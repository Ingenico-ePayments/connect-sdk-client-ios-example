//
//  ICFormRowField.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 11/05/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICFormRowField.h"

@implementation ICFormRowField

- (instancetype _Nonnull)initWithText: (nonnull NSString *)text placeholder: (nonnull NSString *)placeholder keyboardType: (UIKeyboardType)keyboardType isSecure: (BOOL)isSecure {
    self = [super init];
    
    if (self) {
        self.text = text;
        self.placeholder = placeholder;
        self.keyboardType = keyboardType;
        self.isSecure = isSecure;
    }
    
    return self;
}

@end
