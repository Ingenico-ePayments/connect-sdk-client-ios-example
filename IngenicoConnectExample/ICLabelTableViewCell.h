//
//  ICLabelTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICLabel.h>
@class ICFormRowLabel;
@interface ICLabelTableViewCell : ICTableViewCell
@property (assign, nonatomic, getter=isBold) BOOL bold;

+ (CGSize)cellSizeForWidth:(CGFloat)width forFormRow:(ICFormRowLabel *)label;
+ (NSString *)reuseIdentifier;


- (NSString *)label;
- (void)setLabel:(NSString *)label;

@end
