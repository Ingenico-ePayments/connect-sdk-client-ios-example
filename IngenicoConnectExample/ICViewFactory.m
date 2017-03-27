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
#import "UIButton+ICPrimaryButton.h"
#import "UIButton+ICSecondaryButton.h"
#import <IngenicoConnectExample/ICPickerViewTableViewCell.h>
#import <IngenicoConnectExample/ICSummaryTableHeaderView.h>
#import <IngenicoConnectExample/ICIntegerTextField.h>
#import <IngenicoConnectExample/ICFractionalTextField.h>
#import <IngenicoConnectExample/ICCurrencyTableViewCell.h>
#import <IngenicoConnectExample/ICCoBrandsSelectionTableViewCell.h>
#import <IngenicoConnectExample/ICCOBrandsExplanationTableViewCell.h>

@implementation ICViewFactory

- (ICTableViewCell *)tableViewCellWithType:(ICViewType)type reuseIdentifier:(NSString *)reuseIdentifier
{
    ICTableViewCell *cell;
    switch (type) {
        case ICSwitchTableViewCellType:
            cell = [[ICSwitchTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICErrorMessageTableViewCellType:
            cell = [[ICErrorMessageTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICTooltipTableViewCellType:
            cell = [[ICTooltipTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICPaymentProductTableViewCellType:
            cell = [[ICPaymentProductTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICTextFieldTableViewCellType:
            cell = [[ICTextFieldTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICCurrencyTableViewCellType:
            cell = [[ICCurrencyTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICPickerViewTableViewCellType:
            cell = [[ICPickerViewTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICButtonTableViewCellType:
            cell = [[ICButtonTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICLabelTableViewCellType:
            cell = [[ICLabelTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICCoBrandsSelectionTableViewCellType:
            cell = [[ICCoBrandsSelectionTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        case ICCoBrandsExplanationTableViewCellType:
            cell = [[ICCOBrandsExplanationTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
            break;
        default:
            [NSException raise:@"Invalid type of table view cell" format:@"Table view cell type %u is invalid", type];
            break;
    }
    return cell;
}

- (UIButton *)buttonWithType:(ICViewType)type
{
    UIButton *button;
    switch (type) {
        case ICPrimaryButtonType:
            button = [UIButton primaryButton];
            break;
        case ICSecondaryButtonType:
            button = [UIButton secondaryButton];
            break;
        default:
            [NSException raise:@"Invalid type of button" format:@"Button type %u is invalid", type];
            break;
    }
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
