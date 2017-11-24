//
//  ICTooltipTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTooltipTableViewCell.h>

@interface ICTooltipTableViewCell ()

@property (strong, nonatomic) UILabel *tooltipLabel;
@property (strong, nonatomic) UIImageView *tooltipImageContainer;

@end

@implementation ICTooltipTableViewCell

+ (NSString *)reuseIdentifier {
    return @"info-cell";
}

- (NSString *)label {
    return self.tooltipLabel.text;
}

- (void)setLabel:(NSString *)label {
    self.tooltipLabel.text = label;
}

- (UIImage *)tooltipImage {
    return self.tooltipImageContainer.image;
}

- (void)setTooltipImage:(UIImage *)tooltipImage {
    self.tooltipImageContainer.image = tooltipImage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        
        self.tooltipImageContainer = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.tooltipImageContainer.contentMode = UIViewContentModeScaleAspectFit;
        self.tooltipLabel = [[UILabel alloc] init];
        self.tooltipLabel.font = [UIFont systemFontOfSize:10.0f];
        self.tooltipLabel.numberOfLines = 0;
        self.clipsToBounds = YES;
        
        [self.contentView addSubview:self.tooltipImageContainer];
        [self.contentView addSubview:self.tooltipLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = [self accessoryAndMarginCompatibleWidth];
    CGFloat leftMargin = [self accessoryCompatibleLeftMargin];
    self.tooltipLabel.frame = CGRectMake(15, 0, width - 30, 40);
    
    if (self.tooltipImage == nil) {
        self.tooltipImageContainer.frame = CGRectMake(leftMargin, 40, 0, 0);
    }
    else {
        CGFloat ratio = self.tooltipImage.size.width / self.tooltipImage.size.height;

        self.tooltipImageContainer.frame = CGRectMake(leftMargin, 40, 100 * ratio, 100);
    }
}
-(void)prepareForReuse {
    self.label = nil;
    self.tooltipImage = nil;
}
@end
