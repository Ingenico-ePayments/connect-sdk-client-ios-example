//
//  ICTooltipTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTooltipTableViewCell.h>

@interface ICTooltipTableViewCell ()

@property (strong, nonatomic) UIImageView *tooltipImageContainer;

@end

@implementation ICTooltipTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self != nil) {
        self.tooltipImageContainer = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.tooltipImageContainer.contentMode = UIViewContentModeScaleAspectFit;
        self.tooltipLabel = [[UILabel alloc] init];
        self.tooltipLabel.font = [UIFont systemFontOfSize:10.0f];
        self.tooltipLabel.numberOfLines = 0;
        [self.contentView addSubview:self.tooltipImageContainer];
        [self.contentView addSubview:self.tooltipLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float width = self.contentView.frame.size.width;
    
    self.tooltipLabel.frame = CGRectMake(15, 10, width - 30, 40);
    if (self.tooltipImage == nil) {
        self.tooltipImageContainer.frame = CGRectMake(10, 50, 0, 0);
    }
    else {
        self.tooltipImageContainer.frame = CGRectMake(10, 50, 200, 100);
    }
}

- (void)setTooltipImage:(UIImage *)tooltipImage
{
    _tooltipImage = tooltipImage;
    [self.tooltipImageContainer setImage:tooltipImage];
    [self layoutSubviews];
}

@end
