//
//  ICLabelTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICLabel.h>

@interface ICLabelTableViewCell : ICTableViewCell

@property (strong, nonatomic) ICLabel *label;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
