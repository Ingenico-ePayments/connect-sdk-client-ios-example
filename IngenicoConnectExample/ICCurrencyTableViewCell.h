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
#import "ICFormRowField.h"
@interface ICCurrencyTableViewCell : ICTableViewCell

+ (NSString *)reuseIdentifier;

@property (strong, nonatomic) ICFormRowField * integerField;
@property (strong, nonatomic) ICFormRowField * fractionalField;
@property (strong, nonatomic) NSString * currencyCode;
@property(nonatomic,weak) id<UITextFieldDelegate> delegate;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setIntegerField:(ICFormRowField *)integerField;
- (void)setFractionalField:(ICFormRowField *)fractionalField;
@end
