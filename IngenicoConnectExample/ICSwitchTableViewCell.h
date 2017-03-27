//
//  ICSwitchTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>

@interface ICSwitchTableViewCell : ICTableViewCell

@property (strong, nonatomic) UISwitch *switchControl;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
