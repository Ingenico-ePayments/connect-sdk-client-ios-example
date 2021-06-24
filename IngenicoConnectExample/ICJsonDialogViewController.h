//
// Created by Sjors de Haas on 22/04/2021.
// Copyright (c) 2021 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICParseJsonTarget;


@interface ICJsonDialogViewController : UIViewController
@property (weak, nonatomic) id <ICParseJsonTarget> callback;
@end