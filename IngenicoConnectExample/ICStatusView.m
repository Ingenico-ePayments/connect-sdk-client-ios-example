//
//  ICStatusView.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICStatusView.h"
#import "ICCheckMarkView.h"

@interface ICStatusView()
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) ICCheckMarkView *checkMarkView;
-(void)showCheckMarkWithColor:(UIColor *)color;
-(void)showActivityIndicator;
@end
@implementation ICStatusView
-(instancetype)initWithFrame:(CGRect)frame andStatus:(ICStatusViewStatus)status {
    self = [super initWithFrame:frame];
    if (self) {
        self.checkMarkView = [[ICCheckMarkView alloc]initWithFrame:CGRectMake(10.0, 10.0, self.frame.size.width - 20.0, self.frame.size.height - 20.0)];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:self.bounds];
        self.checkMarkView.backgroundColor = self.backgroundColor;
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.checkMarkView.opaque = NO;
        _status = status;
    }
    return self;

}
-(void)setStatus:(ICStatusViewStatus)status {
    _status = status;
    switch (_status) {
        case ICStatusViewStatusWaiting:
            [self showCheckMarkWithColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]];
            break;
        case ICStatusViewStatusProgress:
             [self showActivityIndicator];
            break;
        case ICStatusViewStatusFinished:
            [self showCheckMarkWithColor:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0]];
            break;
        default:
            break;
    }
}
-(void)showActivityIndicator {
    if ([self.checkMarkView isDescendantOfView:self]) {
        [self.checkMarkView removeFromSuperview];
    }
    [self.activityIndicatorView startAnimating];
    [self addSubview:self.activityIndicatorView];
}
-(void)showCheckMarkWithColor:(UIColor *)color {
    if ([self.activityIndicatorView isDescendantOfView:self]) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
    }
    [self.checkMarkView setCurrentColor:color];
    [self addSubview:_checkMarkView];
}

@end
