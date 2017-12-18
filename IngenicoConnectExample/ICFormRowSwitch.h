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
- (instancetype _Nonnull )initWithAttributedTitle: (nonnull NSAttributedString*) title isOn: (BOOL)isOn target: (nullable id)target action: (nullable SEL)action paymentProductField:(nullable ICPaymentProductField *)field;
@property (nonatomic, assign) BOOL isOn;
@property (strong, nonatomic) NSAttributedString * _Nonnull title;
@property (strong, nonatomic) id _Nullable target;
@property (assign, nonatomic) SEL _Nullable action;
@property (strong, nonatomic) ICPaymentProductField * _Nullable field;
@end
