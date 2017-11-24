//
//  ICFormRowQRCode.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICFormRowQRCode.h"
#import <CoreImage/CIFilter.h>
#import <ICBase64.h>
@implementation ICFormRowQRCode
- (instancetype)initWithString:(NSString *)base64EncodedString
{
    ICBase64 *converter = [[ICBase64 alloc]init];
    NSData *data = [converter decode:base64EncodedString];
    return [self initWithData:data];
}

- (instancetype)initWithData:(NSData *)data
{
    return [super initWithImage:[UIImage imageWithData:data]];
}
@end
