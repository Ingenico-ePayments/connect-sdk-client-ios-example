//
//  ICStatusView.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICStatusViewStatus.h"

@interface ICStatusView : UIView
@property (nonatomic, assign) ICStatusViewStatus status;
-(instancetype)initWithFrame:(CGRect)frame andStatus:(ICStatusViewStatus)status;
@end
