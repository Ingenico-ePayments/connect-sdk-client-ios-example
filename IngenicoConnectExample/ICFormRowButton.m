//
//  ICFormRowButton.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowButton.h>

@implementation ICFormRowButton


- (instancetype _Nonnull)initWithTitle: (nonnull NSString *) title target: (nonnull id)target action: (nonnull SEL)action {
    self = [super init];
    
    if (self) {
        self.buttonType = ICButtonTypePrimary;
        self.title = title;
        self.target = target;
        self.action = action;
    }
    
    return self;
}


@end
