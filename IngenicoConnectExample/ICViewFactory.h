//
//  ICViewFactory.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IngenicoConnectExample/ICViewType.h>
#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICSwitch.h>
#import <IngenicoConnectExample/ICTextField.h>
#import <IngenicoConnectExample/ICPickerView.h>
#import <IngenicoConnectExample/ICLabel.h>
#import <IngenicoConnectExample/ICButton.h>

@interface ICViewFactory : NSObject

- (ICButton *)buttonWithType:(ICButtonType)type;
- (ICSwitch *)switchWithType:(ICViewType)type;
- (ICTextField *)textFieldWithType:(ICViewType)type;
- (ICPickerView *)pickerViewWithType:(ICViewType)type;
- (ICLabel *)labelWithType:(ICViewType)type;
- (UIView *)tableHeaderViewWithType:(ICViewType)type frame:(CGRect)frame;

@end
