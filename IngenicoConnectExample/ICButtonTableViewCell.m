//
//  ICButtonTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICButtonTableViewCell.h>

@interface ICButtonTableViewCell ()

@property (strong, nonatomic) ICButton *button;

@end

@implementation ICButtonTableViewCell
+ (NSString *)reuseIdentifier {
    return @"button-cell";
}

- (ICButtonType)buttonType {
    return self.button.type;
}
- (void)setButtonType:(ICButtonType)type {
    self.button.type = type;
}

- (BOOL)isEnabled {
    return self.button.enabled;
}

- (void)setIsEnabled:(BOOL)enabled {
    self.button.enabled = enabled;
}

- (NSString *)title {
    return [self.button titleForState:UIControlStateNormal];
}
- (void)setTitle:(NSString *)title {
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.button = [[ICButton alloc] init];
        [self addSubview:self.button];
        self.buttonType = ICButtonTypePrimary;
        self.clipsToBounds = YES;
    }
    return self;
}


- (void)setClickTarget:(id)target action:(SEL)action {
    [self.button removeTarget: nil action: nil forControlEvents:UIControlEventAllEvents];
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = self.contentView.frame.size.height;
    CGFloat width = [self accessoryAndMarginCompatibleWidth];
    CGFloat leftMargin = [self accessoryCompatibleLeftMargin];
    
    self.button.frame = CGRectMake(leftMargin, self.buttonType == ICButtonTypePrimary ? 12 : 6, width, height - 12);
}

- (void)prepareForReuse {
    [self.button removeTarget: nil action: nil forControlEvents:UIControlEventAllEvents];
}

@end
