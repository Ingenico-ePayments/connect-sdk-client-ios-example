//
//  ICFormRowWithInfoButton.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRow.h>

@interface ICFormRowWithInfoButton : ICFormRow

@property (nonatomic) BOOL showInfoButton;
@property (nonatomic, strong) NSString *tooltipIdentifier;
@property (strong, nonatomic) UIImage *tooltipImage;
@property (strong, nonatomic) NSString *tooltipText;

@end
