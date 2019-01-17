//
//  ICFormRowDate.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 09/10/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICFormRowDate.h"
@interface ICFormRowDate()
@end
@implementation ICFormRowDate
-(void)setValue:(NSString *)value {
    if ([value length] > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyyMMdd";
        self.date = [formatter dateFromString:value];
        if (self.date == NULL) {
            self.date = [NSDate date];
        }
    }
    else {
        self.date = [NSDate date];
    }
}
@end
