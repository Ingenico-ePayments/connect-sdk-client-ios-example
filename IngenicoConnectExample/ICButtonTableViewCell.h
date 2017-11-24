//
//  ICButtonTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICButton.h>

@interface ICButtonTableViewCell : ICTableViewCell

+ (NSString *)reuseIdentifier;

- (BOOL)isEnabled;
- (void)setIsEnabled:(BOOL)enabled;

- (ICButtonType)buttonType;
- (void)setButtonType:(ICButtonType)type;

- (NSString *)title;
- (void)setTitle:(NSString *)title;

- (void)setClickTarget:(id)target action:(SEL)action;

@end
