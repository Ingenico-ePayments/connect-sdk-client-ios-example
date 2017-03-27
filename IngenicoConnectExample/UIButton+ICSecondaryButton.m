//
//  UIButton+ICSecondaryButton.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import "UIButton+ICSecondaryButton.h"

@implementation UIButton (ICSecondaryButton)

+ (UIButton *)secondaryButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = [UIColor grayColor];
    return button;
}

@end
