//
//  ICFormRowQRCode.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICFormRowImage.h"

@interface ICFormRowQRCode : ICFormRowImage
- (instancetype)initWithString:(NSString *)base64EncodedString;
- (instancetype)initWithData:(NSData *)data;
@end
