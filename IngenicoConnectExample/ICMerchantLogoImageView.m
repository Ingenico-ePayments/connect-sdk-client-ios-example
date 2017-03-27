//
//  ICMerchantLogoImageView.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICMerchantLogoImageView.h>

@implementation ICMerchantLogoImageView

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 20, 20)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *logo = [UIImage imageNamed:@"MerchantLogo"];
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.image = logo;
    }
    return self;
}

@end
