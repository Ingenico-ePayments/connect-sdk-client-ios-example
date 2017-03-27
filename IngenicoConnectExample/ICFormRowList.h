//
//  ICFormRowList.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICFormRow.h>
#import <IngenicoConnectExample/ICPickerView.h>

@interface ICFormRowList : ICFormRow

@property (strong, nonatomic) ICPickerView *pickerView;
@property (strong, nonatomic) NSDictionary *nameToIdentifierMapping;
@property (strong, nonatomic) NSDictionary *identifierToRowMapping;
@property (strong, nonatomic) NSString *paymentProductFieldIdentifier;
@property (nonatomic) NSInteger selectedRow;

@end
