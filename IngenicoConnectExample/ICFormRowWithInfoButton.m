//
//  ICFormRowWithInfoButton.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRowWithInfoButton.h>

@implementation ICFormRowWithInfoButton

- (BOOL)showInfoButton {
    return self.tooltip != nil;
}


@end
