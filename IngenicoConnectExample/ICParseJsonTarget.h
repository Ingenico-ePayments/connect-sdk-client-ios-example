//
// Created by Sjors de Haas on 22/04/2021.
// Copyright (c) 2021 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICStartPaymentParsedJsonData;

@protocol ICParseJsonTarget <NSObject>
- (void)success:(ICStartPaymentParsedJsonData *) sessionData;
@end