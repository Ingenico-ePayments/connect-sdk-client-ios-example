//
//  ICViewFactory.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICViewFactory.h>
#import <IngenicoConnectExample/ICButtonTableViewCell.h>
#import <IngenicoConnectExample/ICSwitchTableViewCell.h>
#import <IngenicoConnectExample/ICErrorMessageTableViewCell.h>
#import <IngenicoConnectExample/ICLabelTableViewCell.h>
#import <IngenicoConnectExample/ICTooltipTableViewCell.h>
#import <IngenicoConnectExample/ICPaymentProductTableViewCell.h>
#import <IngenicoConnectExample/ICTextFieldTableViewCell.h>
#import <IngenicoConnectExample/ICPickerViewTableViewCell.h>
#import <IngenicoConnectExample/ICSummaryTableHeaderView.h>
#import <IngenicoConnectExample/ICIntegerTextField.h>
#import <IngenicoConnectExample/ICFractionalTextField.h>
#import <IngenicoConnectExample/ICCurrencyTableViewCell.h>
#import <IngenicoConnectExample/ICCoBrandsSelectionTableViewCell.h>
#import <IngenicoConnectExample/ICCOBrandsExplanationTableViewCell.h>

@implementation ICViewFactory

- (ICButton *)buttonWithType:(ICButtonType)type
{
    ICButton *button = [ICButton new];
    button.type = type;
    
    return button;
}

- (ICSwitch *)switchWithType:(ICViewType)type
{
    ICSwitch *switchControl;
    switch (type) {
        case ICSwitchType:
            switchControl = [[ICSwitch alloc] init];
            break;
        default:
            [NSException raise:@"Invalid switch type" format:@"Switch type %u is invalid", type];
            break;
    }
    return switchControl;
}

- (ICTextField *)textFieldWithType:(ICViewType)type
{
    ICTextField *textField;
    switch (type) {
        case ICTextFieldType:
            textField = [[ICTextField alloc] init];
            break;
        case ICIntegerTextFieldType:
            textField = [[ICIntegerTextField alloc] init];
            break;
        case ICFractionalTextFieldType:
            textField = [[ICFractionalTextField alloc] init];
            break;
        default:
            [NSException raise:@"Invalid text field type" format:@"Text field type %u is invalid", type];
            break;
    }
    return textField;
}

- (ICPickerView *)pickerViewWithType:(ICViewType)type
{
    ICPickerView *pickerView;
    switch (type) {
        case ICPickerViewType:
            pickerView = [[ICPickerView alloc] init];
            break;
        default:
            [NSException raise:@"Invalid picker view type" format:@"Picker view type %u is invalid", type];
            break;
    }
    return pickerView;
}

- (ICLabel *)labelWithType:(ICViewType)type
{
    ICLabel *label;
    switch (type) {
        case ICLabelType:
            label = [[ICLabel alloc] init];
            break;
        default:
            [NSException raise:@"Invalid label type" format:@"Label type %u is invalid", type];
            break;
    }
    return label;
}

- (UIView *)tableHeaderViewWithType:(ICViewType)type frame:(CGRect)frame
{
    UIView *view;
    switch (type) {
        case ICSummaryTableHeaderViewType:
            view = [[ICSummaryTableHeaderView alloc] initWithFrame:frame];
            break;
        default:
            [NSException raise:@"Invalid table header view type" format:@"Table header view type %u is invalid", type];
            break;
    }
    return view;
}

@end
