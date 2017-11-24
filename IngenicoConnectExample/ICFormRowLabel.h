//
//  ICFormRowLabel.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRow.h>
#import <IngenicoConnectExample/ICLabel.h>

@interface ICFormRowLabel : ICFormRow

- (instancetype _Nonnull)initWithText:(nonnull NSString *)text;

@property (strong, nonatomic) NSString * _Nonnull text;

@property (assign, nonatomic, getter=isBold) BOOL bold;

@end
