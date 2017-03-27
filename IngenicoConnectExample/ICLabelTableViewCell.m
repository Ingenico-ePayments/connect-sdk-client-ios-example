//
//  ICLabelTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICLabelTableViewCell.h>

@interface ICLabelTableViewCell ()

@property (strong, nonatomic) UIView *labelView;

@end

@implementation ICLabelTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.label != nil) {
        float width = self.contentView.frame.size.width;
        self.label.frame = CGRectMake(10, 4, width - 20, 36);
    }
}

- (void)setLabel:(ICLabel *)label
{
    [self.label removeFromSuperview];
    _label = label;
    [self.contentView addSubview:self.label];
}

@end
