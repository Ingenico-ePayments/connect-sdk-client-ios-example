//
//  ICSwitchTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>

@interface ICSwitchTableViewCell : ICTableViewCell

+ (NSString *)reuseIdentifier;

- (NSString *)title;
- (void)setTitle:(NSString *)title;

- (void)setSwitchTarget:(id)target action:(SEL)action;

@end
