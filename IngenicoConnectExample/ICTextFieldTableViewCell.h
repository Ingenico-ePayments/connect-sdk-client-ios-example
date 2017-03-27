//
//  ICTextFieldTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICTextField.h>

@interface ICTextFieldTableViewCell : ICTableViewCell

@property (strong, nonatomic) ICTextField *textField;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
