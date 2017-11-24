//
//  ICTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICTableViewCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)accessoryAndMarginCompatibleWidth;
- (CGFloat)accessoryCompatibleLeftMargin;
@end

#import <IngenicoConnectExample/ICTooltipTableViewCell.h>
#import <IngenicoConnectExample/ICPaymentProductTableViewCell.h>
#import <IngenicoConnectExample/ICPickerViewTableViewCell.h>
#import <IngenicoConnectExample/ICSwitchTableViewCell.h>
#import <IngenicoConnectExample/ICTextFieldTableViewCell.h>
#import <IngenicoConnectExample/ICButtonTableViewCell.h>
#import <IngenicoConnectExample/ICErrorMessageTableViewCell.h>
#import <IngenicoConnectExample/ICLabelTableViewCell.h>
#import <IngenicoConnectExample/ICCurrencyTableViewCell.h>
#import <IngenicoConnectExample/ICCoBrandsSelectionTableViewCell.h>
#import <IngenicoConnectExample/ICCOBrandsExplanationTableViewCell.h>
