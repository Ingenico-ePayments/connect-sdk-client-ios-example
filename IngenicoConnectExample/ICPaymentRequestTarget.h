//
//  ICPaymentRequestTarget.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IngenicoConnectSDK/ICPaymentRequest.h>

@protocol ICPaymentRequestTarget <NSObject>

- (void)didSubmitPaymentRequest:(ICPaymentRequest *)paymentRequest;
- (void)didCancelPaymentRequest;

@end
