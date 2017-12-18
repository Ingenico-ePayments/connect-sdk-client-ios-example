//
//  ICButton.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 11/05/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICButton.h"
#import <IngenicoConnectExample/ICAppConstants.h>

@implementation ICButton

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.type = ICButtonTypePrimary;
        self.layer.cornerRadius = 5;
    }
    
    return self;
}


- (void)setType:(ICButtonType)type {
    _type = type;
    switch (type) {
        case ICButtonTypePrimary:
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
            self.backgroundColor = kICPrimaryColor;
            self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
            break;
        case ICButtonTypeSecondary:
            [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
            self.backgroundColor = [UIColor clearColor];
            self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
            break;
        case ICButtonTypeDestructive:
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
            self.backgroundColor = kICDestructiveColor;
            self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
            break;

    }
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    self.alpha = enabled ? 1 : 0.3;
}

@end
