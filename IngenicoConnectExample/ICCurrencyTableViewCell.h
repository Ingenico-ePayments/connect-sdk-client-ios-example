//
//  ICCurrencyTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICIntegerTextField.h>
#import <IngenicoConnectExample/ICFractionalTextField.h>

@interface ICCurrencyTableViewCell : ICTableViewCell

@property (strong, nonatomic) ICIntegerTextField *integerTextField;
@property (strong, nonatomic) ICFractionalTextField *fractionalTextField;
@property (strong, nonatomic) NSString *currencyCode;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
