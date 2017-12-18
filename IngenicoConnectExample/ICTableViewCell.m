//
//  ICTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>

@implementation ICTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithReuseIdentifier:reuseIdentifier];
    return self;
}

- (CGFloat)accessoryAndMarginCompatibleWidth {
    if (self.accessoryType != UITableViewCellAccessoryNone) {
        if (self.contentView.frame.size.width > CGRectGetMidX(self.frame) - 320/2 + 320)
        {
            return 320;
        }
        else {
            return self.contentView.frame.size.width - 16;
        }
    }
    else {
        if(self.contentView.frame.size.width > CGRectGetMidX(self.frame) - 320/2 + 320 + 16 + 22 + 16) {
            return 320;
        }
        else {
            return self.contentView.frame.size.width - 16 - 16;
        }
    }
}

- (CGFloat)accessoryCompatibleLeftMargin {
    if (self.accessoryType != UITableViewCellAccessoryNone) {
        if (self.contentView.frame.size.width > CGRectGetMidX(self.frame) - 320/2 + 320)
        {
            return CGRectGetMidX(self.frame) - 320/2;
        }
        else {
            return 16;
        }
    }
    else {
        if (self.contentView.frame.size.width > CGRectGetMidX(self.frame) - 320/2 + 320 + 16 + 22 + 16) {
            return CGRectGetMidX(self.frame) - 320/2;
        }
        else {
            return 16;
        }
    }
}

@end
