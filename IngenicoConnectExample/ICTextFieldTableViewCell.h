//
//  ICTextFieldTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//
#import <UIKit/UIKit.h>

#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICTextField.h>
#import <IngenicoConnectExample/ICFormRowField.h>

@interface ICTextFieldTableViewCell : ICTableViewCell

+ (NSString *)reuseIdentifier;

- (UIView *)rightView;
- (void)setRightView:(UIView *)view;

- (NSString *)error;
- (void)setError:(NSString *)error;

- (NSObject<UITextFieldDelegate> *)delegate;
- (void)setDelegate:(NSObject<UITextFieldDelegate> *)delegate;

@property (strong, nonatomic) ICFormRowField *field;

@end
