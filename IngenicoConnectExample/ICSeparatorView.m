//
//  ICSeparatorView.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICSeparatorView.h"

@implementation ICSeparatorView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat textBufferSpace = (self.separatorString != nil) ? 20.0 : 0;
    CGSize drawSize = (self.separatorString != nil) ? [self.separatorString sizeWithAttributes:@{}] : CGSizeMake(0, 0);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat endX = (self.bounds.size.width/2 - drawSize.width/2) - textBufferSpace;
    CGPoint firstEndPont = CGPointMake(endX, CGRectGetMidY(self.bounds));
    CGPoint firstStartPoint = CGPointMake(0, CGRectGetMidY(self.bounds));
    CGPoint secondStartPoint = CGPointMake(self.bounds.size.width - endX, CGRectGetMidY(self.bounds));
    CGPoint secondEndPoint = CGPointMake(self.bounds.size.width, CGRectGetMidY(self.bounds));
    [path moveToPoint:firstStartPoint];
    [path addLineToPoint:firstEndPont];
    [path moveToPoint:secondStartPoint];
    [path addLineToPoint:secondEndPoint];
    [[UIColor darkGrayColor] setStroke];
    [path stroke];
    if (self.separatorString) {
        CGRect drawRect = CGRectMake(firstEndPont.x + textBufferSpace, CGRectGetMidY(self.bounds) - drawSize.height/2, drawSize.width, drawSize.height);
        [self.separatorString drawInRect:drawRect withAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    }
}


@end
