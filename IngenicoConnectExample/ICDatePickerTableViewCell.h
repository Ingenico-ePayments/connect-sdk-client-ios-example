//
//  ICDatePickerTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 09/10/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICTableViewCell.h"
@protocol ICDatePickerTableViewCellDelegate
-(void)datePicker:(UIDatePicker *)datePicker selectedNewDate:(NSDate *)newDate;
@end
@interface ICDatePickerTableViewCell : ICTableViewCell {
    NSDate *_date;
}
+(NSString *)reuseIdentifier;
@property (nonatomic, weak) NSObject<ICDatePickerTableViewCellDelegate> *delegate;
+(NSUInteger)pickerHeight;
@property (nonatomic, assign) BOOL readonly;
@property (nonatomic, strong) NSDate *date;
@end
