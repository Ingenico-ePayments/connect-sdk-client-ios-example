//
//  ICFormRowsConverter.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IngenicoConnectSDK/ICPaymentRequest.h>
#import <IngenicoConnectExample/ICViewFactory.h>
#import <IngenicoConnectExample/ICFormRowErrorMessage.h>
#import <IngenicoConnectSDK/ICValidationError.h>

@class ICIINDetailsResponse;
@class ICPaymentProductInputData;

@interface ICFormRowsConverter : NSObject

+ (NSString *)errorMessageForError:(ICValidationError *)error withCurrency:(BOOL)forCurrency;

- (NSMutableArray *)formRowsFromInputData:(ICPaymentProductInputData *)inputData viewFactory:(ICViewFactory *)viewFactory confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts;

@end
