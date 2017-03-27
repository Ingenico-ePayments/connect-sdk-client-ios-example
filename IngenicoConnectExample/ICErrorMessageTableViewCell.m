//
//  ICErrorMessageTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICErrorMessageTableViewCell.h>

@implementation ICErrorMessageTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:12.0f];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textColor = [UIColor redColor];
    }
    return self;
}

@end
