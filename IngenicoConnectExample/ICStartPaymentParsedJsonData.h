//
// Created by Sjors de Haas on 22/04/2021.
// Copyright (c) 2021 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ICStartPaymentParsedJsonData : NSObject

@property NSString *customerId;
@property NSString *clientSessionId;
@property NSString *clientApiUrl;
@property NSString *assetUrl;
@property NSArray *invalidTokens;
@property NSString *region;

- (instancetype)initWithJSONString:(NSString *)JSONString;

@end