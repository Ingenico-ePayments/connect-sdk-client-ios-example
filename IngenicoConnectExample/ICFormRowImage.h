//
//  ICFormRowImage.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICFormRow.h"
@interface ICFormRowImage : ICFormRow
@property (nonatomic, retain) UIImage *image;
-(instancetype)initWithImage:(UIImage *)image;
@end
