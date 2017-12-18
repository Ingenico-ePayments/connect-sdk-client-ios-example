//
//  ICPickerViewTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTableViewCell.h>
#import <IngenicoConnectExample/ICPickerView.h>
#import <IngenicoConnectSDK/ICValueMappingItem.h>
#import <IngenicoConnectSDK/ICPaymentProductField.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIPickerView.h>

@interface ICPickerViewTableViewCell : ICTableViewCell

+ (NSString *)reuseIdentifier;

@property (strong, nonatomic) NSArray<ICValueMappingItem *> *items;
@property (strong, nonatomic) NSObject<UIPickerViewDelegate> *delegate;
@property (strong, nonatomic) NSObject<UIPickerViewDataSource> *dataSource;
@property (assign, nonatomic) NSInteger selectedRow;
+(NSUInteger)pickerHeight;
@end
