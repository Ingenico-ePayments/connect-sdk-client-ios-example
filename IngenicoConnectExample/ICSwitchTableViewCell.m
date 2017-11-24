//
//  ICSwitchTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICSwitchTableViewCell.h>

@interface ICSwitchTableViewCell ()

@property (strong, nonatomic) UISwitch *switchControl;

@end

@implementation ICSwitchTableViewCell

+ (NSString *)reuseIdentifier {
    return @"switch-cell";
}

- (NSString *)title {
    return self.textLabel.text;
}
- (void)setTitle:(NSString *)title {
    self.textLabel.text = title;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.switchControl = [[UISwitch alloc] init];
        [self addSubview:self.switchControl];
        self.clipsToBounds = YES;
        
        self.textLabel.font = [UIFont systemFontOfSize:12.0f];
        self.textLabel.numberOfLines = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = self.contentView.frame.size.height;
    CGFloat width = [self accessoryAndMarginCompatibleWidth];
    CGFloat leftMargin = [self accessoryCompatibleLeftMargin];
    CGFloat switchWidth = self.switchControl.frame.size.width;
    
    self.switchControl.frame = CGRectMake(leftMargin, 7, 0, 0);
    self.textLabel.frame = CGRectMake(leftMargin + 16 + switchWidth, -1, width - switchWidth, height);
}

- (void)setSwitchTarget:(id)target action:(SEL)action {
    [self.switchControl removeTarget: nil action: nil forControlEvents:UIControlEventAllEvents];
    [self.switchControl addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)prepareForReuse {
    self.title = nil;
    [self.switchControl removeTarget: nil action: nil forControlEvents:UIControlEventAllEvents];
}

@end
