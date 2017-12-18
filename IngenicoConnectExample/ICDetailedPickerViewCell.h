//
//  ICDetailedPickerViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 03/08/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICPickerViewTableViewCell.h"
@interface ICDetailedPickerViewCell : ICPickerViewTableViewCell <UIPickerViewDelegate>
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;
@property (nonatomic, strong) NSString *fieldIdentifier;
@property (nonatomic, strong) NSString *errorMessage;
@end
