//
//  ICPaymentProductsTableSection.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICPaymentType.h"

@interface ICPaymentProductsTableSection : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSMutableArray *rows;
@property (nonatomic) ICPaymentType type;

@end
