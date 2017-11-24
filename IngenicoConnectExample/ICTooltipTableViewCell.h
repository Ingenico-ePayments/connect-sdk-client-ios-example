//
//  ICTooltipTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>

@interface ICTooltipTableViewCell : ICTableViewCell

+ (NSString *)reuseIdentifier;

@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) UIImage *tooltipImage;

@end
