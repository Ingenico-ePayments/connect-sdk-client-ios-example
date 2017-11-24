//
//  ICButton.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 11/05/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    ICButtonTypePrimary = 0,
    ICButtonTypeSecondary = 1
} ICButtonType;

@interface ICButton : UIButton

@property (assign, nonatomic) ICButtonType type;

@end
