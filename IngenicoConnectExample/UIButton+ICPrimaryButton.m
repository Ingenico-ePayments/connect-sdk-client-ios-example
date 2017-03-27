//
//  UIButton+ICPrimaryButton.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import "UIButton+ICPrimaryButton.h"
#import <IngenicoConnectExample/ICAppConstants.h>

@implementation UIButton (ICPrimaryButton)

+ (UIButton *)primaryButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = kICPrimaryColor;
    button.tintColor = [UIColor whiteColor];
    return button;
}

@end
