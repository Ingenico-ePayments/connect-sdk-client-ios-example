//
//  ICSwitch.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICSwitch.h>
#import <IngenicoConnectExample/ICAppConstants.h>

@implementation ICSwitch

- (instancetype)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.onTintColor = kICPrimaryColor;
    return self;
}

@end
