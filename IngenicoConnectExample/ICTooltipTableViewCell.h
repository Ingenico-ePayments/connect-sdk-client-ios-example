//
//  ICTooltipTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>

@interface ICTooltipTableViewCell : ICTableViewCell

@property (strong, nonatomic) UILabel *tooltipLabel;
@property (strong, nonatomic) UIImage *tooltipImage;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
