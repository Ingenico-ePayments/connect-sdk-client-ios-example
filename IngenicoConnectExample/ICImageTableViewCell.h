//
//  ICImageTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICTableViewCell.h"

@interface ICImageTableViewCell : ICTableViewCell
@property (nonatomic, retain) UIImageView *displayImageView;
@property (nonatomic, retain) UIImage *displayImage;
+(NSString *)reuseIdentifier;

-(CGSize)sizeTransformedFrom:(CGSize)size toTargetWidth:(CGFloat)width;
    
-(CGSize)sizeTransformedFrom:(CGSize)size toTargetHeight:(CGFloat)height;

-(CGSize)cellSizeWithWidth:(CGFloat)width;
@end
