//
//  ICPickerViewTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICPickerViewTableViewCell.h>

@implementation ICPickerViewTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.pickerView != nil) {
        float width = self.contentView.frame.size.width;
        self.pickerView.frame = CGRectMake(10, 0, width - 20, 162);
    }
}

- (void)setPickerView:(ICPickerView *)pickerView
{
    [self.pickerView removeFromSuperview];
    _pickerView = pickerView;
    [self.contentView addSubview:pickerView];
}

@end
