//
//  ICPaymentFinishedTarget.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//
#import <IngenicoConnectSDK/ICPreparedPaymentRequest.h>

#ifndef ICPaymentFinishedTarget_h
#define ICPaymentFinishedTarget_h

@protocol ICPaymentFinishedTarget <NSObject>

- (void)didFinishPayment:(ICPreparedPaymentRequest *)preparedPaymentRequest;

@end

#endif /* ICPaymentFinishedTarget_h */
