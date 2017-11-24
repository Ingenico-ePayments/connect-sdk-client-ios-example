//
//  ICFormRowSwitch.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowSwitch.h>

@implementation ICFormRowSwitch

-(instancetype)initWithTitle: (nonnull NSString*) title isOn: (BOOL)isOn target: (nonnull id)target action: (nonnull SEL)action {
    self = [super init];
    
    if (self) {
        self.title = title;
        self.isOn = isOn;
        self.target = target;
        self.action = action;
    }
    
    return self;
}

@end
