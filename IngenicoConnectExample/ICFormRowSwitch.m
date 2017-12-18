//
//  ICFormRowSwitch.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowSwitch.h>

@implementation ICFormRowSwitch
-(instancetype)initWithAttributedTitle: (nonnull NSAttributedString*) title isOn: (BOOL)isOn target: (nullable id)target action: (nullable SEL)action paymentProductField:(nullable ICPaymentProductField *)field{
    self = [super init];
    
    if (self) {
        self.title = title;
        self.isOn = isOn;
        self.target = target;
        self.action = action;
        self.field = field;
    }
    
    return self;

}

-(instancetype)initWithTitle: (nonnull NSString*) title isOn: (BOOL)isOn target: (nonnull id)target action: (nonnull SEL)action {
    return [self initWithAttributedTitle:[[NSAttributedString alloc] initWithString:title] isOn:isOn target:target action:action paymentProductField:nil];
}

@end
