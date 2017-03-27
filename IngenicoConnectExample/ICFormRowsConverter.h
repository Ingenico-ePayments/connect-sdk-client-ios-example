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

@class ICIINDetailsResponse;
@class ICPaymentProductInputData;

@interface ICFormRowsConverter : NSObject

- (NSMutableArray *)formRowsFromInputData:(ICPaymentProductInputData *)inputData iinDetailsResponse:(ICIINDetailsResponse *)iinDetailsResponse validation:(BOOL)validation viewFactory:(ICViewFactory *)viewFactory confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts;

@end
