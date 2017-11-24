//
//  ICPaymentProductTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>

@interface ICPaymentProductTableViewCell : ICTableViewCell

+ (NSString *)reuseIdentifier;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *logo;
@property (assign, nonatomic) BOOL shouldHaveMaximalWidth;
@property (strong, nonatomic) UIColor *limitedBackgroundColor;

@end
