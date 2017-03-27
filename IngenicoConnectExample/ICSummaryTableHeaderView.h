//
//  ICSummaryTableHeaderView.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICSummaryTableHeaderView : UIView

@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSString *securePayment;

@end
