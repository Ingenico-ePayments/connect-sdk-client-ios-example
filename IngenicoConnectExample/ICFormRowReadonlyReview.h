//
//  ICFormRowReadonlyReview.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 03/08/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICFormRow.h"

@interface ICFormRowReadonlyReview : ICFormRow
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *data;
@end
