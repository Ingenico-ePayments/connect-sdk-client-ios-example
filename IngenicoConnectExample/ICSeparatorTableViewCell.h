//
//  ICICSeparatorTableViewCell.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICTableViewCell.h"
@class ICSeparatorView;
@interface ICSeparatorTableViewCell : ICTableViewCell
+ (NSString *)reuseIdentifier;
@property (nonatomic, strong) NSString *separatorText;
@property (nonatomic, strong) ICSeparatorView *view;
@end
