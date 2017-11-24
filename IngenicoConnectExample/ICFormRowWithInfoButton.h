//
//  ICFormRowWithInfoButton.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRow.h>
#import <IngenicoConnectExample/ICFormRowTooltip.h>

@interface ICFormRowWithInfoButton : ICFormRow

- (BOOL)showInfoButton;
@property (nonatomic, strong) ICFormRowTooltip *tooltip;

@end
