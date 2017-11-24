//
//  ICLogoTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICLogoTableViewCell.h"
static CGFloat kICLogoTableViewCellWidth = 140;
@implementation ICLogoTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}
+(NSString *)reuseIdentifier {
    return @"logo-cell";
}
-(CGSize)cellSizeWithWidth:(CGFloat)width {
    return CGSizeMake(kICLogoTableViewCellWidth, [self sizeTransformedFrom:self.displayImageView.image.size toTargetWidth:kICLogoTableViewCellWidth].height);
}
-(void)layoutSubviews {
    CGFloat newWidth = kICLogoTableViewCellWidth;
    CGFloat newHeigh = [self sizeTransformedFrom:self.displayImage.size toTargetWidth:kICLogoTableViewCellWidth].height;
    
    self.displayImageView.frame = CGRectMake(CGRectGetMidX(self.frame) - newWidth/2, 0, newWidth, newHeigh);
}
@end
