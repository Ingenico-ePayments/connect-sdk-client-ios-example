//
//  ICSwitchTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>
@class ICSwitchTableViewCell;
@class ICSwitch;
@protocol ICSwitchTableViewCellDelegate
-(void)switchChanged:(ICSwitch *)aSwitch;
@end
@interface ICSwitchTableViewCell : ICTableViewCell
@property (weak, nonatomic) NSObject<ICSwitchTableViewCellDelegate> *delegate;
@property (strong, nonatomic) NSString *errorMessage;
@property (assign, nonatomic, getter=isOn) BOOL on;
+ (NSString *)reuseIdentifier;

- (NSAttributedString *)attributedTitle;
- (void)setAttributedTitle:(NSAttributedString *)attributedTitle;

- (void)setSwitchTarget:(id)target action:(SEL)action;


@end
