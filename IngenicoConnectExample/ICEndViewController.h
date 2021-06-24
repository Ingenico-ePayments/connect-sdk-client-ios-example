//
//  ICEndViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <IngenicoConnectExample/ICContinueShoppingTarget.h>
#import <IngenicoConnectExample/ICViewFactory.h>
#import <IngenicoConnectSDK/ICPreparedPaymentRequest.h>

@interface ICEndViewController : UIViewController

@property (weak, nonatomic) id <ICContinueShoppingTarget> target;
@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (strong, nonatomic) ICPreparedPaymentRequest *preparedPaymentRequest;
@property (strong, nonatomic) UIButton *resultButton;
@property (strong, nonatomic) UITextView *encryptedText;

@end
