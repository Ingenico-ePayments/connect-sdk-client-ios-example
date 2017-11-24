//
//  ICBancontactViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICPaymentProductViewController.h"

@interface ICBancontactProductViewController : ICPaymentProductViewController
@property (nonatomic, strong) NSDictionary<NSString *, NSObject *>* customServerJSON;
@end
