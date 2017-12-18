//
//  ICFormRowList.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRow.h>
#import <IngenicoConnectExample/ICPickerView.h>
#import <IngenicoConnectSDK/ICValueMappingItem.h>
#import <IngenicoConnectSDK/ICPaymentProductField.h>

@interface ICFormRowList : ICFormRow

- (instancetype _Nonnull)initWithPaymentProductField: (nonnull ICPaymentProductField *)paymentProductField;

@property (strong, nonatomic) NSMutableArray<ICValueMappingItem *> * _Nonnull items;
@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) ICPaymentProductField * _Nonnull paymentProductField;
@end
