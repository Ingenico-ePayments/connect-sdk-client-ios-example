//
//  ICExternalAppStatusViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IngenicoConnectSDK/ICThirdPartyStatus.h>

@interface ICExternalAppStatusViewController : UIViewController
@property (nonatomic, assign) ICThirdPartyStatus externalAppStatus;
@end
