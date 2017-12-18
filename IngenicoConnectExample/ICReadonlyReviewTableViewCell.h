//
//  ICReadonlyReviewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 30/08/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICTableViewCell.h"
@interface ICReadonlyReviewTableViewCell : ICTableViewCell
@property (nonatomic, retain) NSDictionary<NSString *, NSString *> *data;
+(NSString *)reuseIdentifier;
+(CGFloat)cellHeightForData:(NSDictionary<NSString *, NSString *> *)data inWidth:(CGFloat)width;
@end
