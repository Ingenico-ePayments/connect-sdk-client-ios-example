//
//  ICCheckMarkView.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICCheckMarkView.h"

@implementation ICCheckMarkView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentColor = [UIColor greenColor];
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    CGPoint startPoint = CGPointMake(CGRectGetMaxX(bounds) - bounds.size.width * 0.2, CGRectGetMinY(bounds) + bounds.size.height * 0.4);
    CGPoint mirrorPoint = CGPointMake(CGRectGetMidX(bounds) - 0.1 * bounds.size.width, CGRectGetMaxY(bounds) - bounds.size.height * 0.1);
    CGPoint endPoint = CGPointMake(CGRectGetMinX(bounds) + bounds.size.width * 0.2, CGRectGetMidY(bounds) + bounds.size.height * 0.2);
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    path.lineWidth = ((bounds.size.width + bounds.size.height)/3)/6;
    [path moveToPoint:startPoint];
    [path addLineToPoint:mirrorPoint];
    [path addLineToPoint:endPoint];
    [self.currentColor setStroke];
    [path stroke];
}


@end
