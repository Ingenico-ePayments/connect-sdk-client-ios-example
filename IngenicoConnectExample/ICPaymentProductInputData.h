//
//  ICPaymentProductInputData.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICPaymentItem;
@class ICAccountOnFile;
@class ICPaymentRequest;

@interface ICPaymentProductInputData : NSObject

@property (strong, nonatomic) NSObject<ICPaymentItem> *paymentItem;
@property (strong, nonatomic) ICAccountOnFile *accountOnFile;
@property (nonatomic) BOOL tokenize;
@property (strong, nonatomic) NSMutableArray *errors;

- (ICPaymentRequest *)paymentRequest;

- (BOOL)fieldIsPartOfAccountOnFile:(NSString *)paymentProductFieldId;
- (BOOL)fieldIsReadOnly:(NSString *)paymentProductFieldId;

- (void)setValue:(NSString *)value forField:(NSString *)paymentProductFieldId;
- (NSString *)maskedValueForField:(NSString *)paymentProductFieldId;
- (NSString *)maskedValueForField:(NSString *)paymentProductFieldId cursorPosition:(NSInteger *)cursorPosition;
- (NSString *)unmaskedValueForField:(NSString *)paymentProductFieldId;
- (void)validate;

@end
