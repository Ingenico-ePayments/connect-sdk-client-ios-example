//
//  ICDatePickerTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 09/10/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICDatePickerTableViewCell.h"
@interface ICDatePickerTableViewCell ()
@property (nonatomic, strong) UIDatePicker *datePicker;
@end
@implementation ICDatePickerTableViewCell
+(NSString *)reuseIdentifier {
    return @"date-picker-cell";
}
+(NSUInteger)pickerHeight {
    return 216;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.datePicker = [[UIDatePicker alloc]init];
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
        [self.datePicker addTarget:self action:@selector(didPickNewDate:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.datePicker];
        self.date = [NSDate date];
    }
    return self;
}
-(void)didPickNewDate:(UIDatePicker *)sender {
    if (self.delegate) {
        [self.delegate datePicker:sender selectedNewDate:sender.date];
    }
}
-(void)setDate:(NSDate *)date {
    self.datePicker.date = date;
    self->_date = date;
}
-(NSDate *)date {
    return self->_date;
}
-(BOOL)readonly {
    return !self.datePicker.isEnabled;
}
-(void)setReadonly:(BOOL)readonly {
    self.datePicker.enabled = !readonly;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.datePicker != nil) {
        CGFloat width = self.contentView.frame.size.width;
        CGRect frame = CGRectMake(10, 0, width - 20, [ICDatePickerTableViewCell pickerHeight]);
        frame.size = [self.datePicker sizeThatFits:frame.size];
        frame.origin.x = width/2 - frame.size.width/2;
        self.datePicker.frame = frame;
    }
}
-(void)prepareForReuse {
    self.delegate = nil;
}
@end
