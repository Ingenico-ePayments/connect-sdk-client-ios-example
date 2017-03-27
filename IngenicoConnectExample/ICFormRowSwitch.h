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

@property (strong, nonatomic) ICSwitch* switchControl;
@property (strong, nonatomic) NSString *text;

@end
