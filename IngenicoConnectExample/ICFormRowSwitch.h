//
//  ICFormRowSwitch.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRow.h>
#import <IngenicoConnectExample/ICSwitch.h>
#import <IngenicoConnectExample/ICFormRowWithInfoButton.h>

@interface ICFormRowSwitch : ICFormRowWithInfoButton

- (instancetype _Nonnull)initWithTitle: (nonnull NSString *) title isOn: (BOOL)isOn target: (nonnull id)target action: (nonnull SEL)action;

@property (nonatomic) BOOL isOn;
@property (strong, nonatomic) NSString * _Nonnull title;
@property (strong, nonatomic) id _Nonnull target;
@property (assign, nonatomic) SEL _Nonnull action;

@end
