//
//  ICTextFieldTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTextFieldTableViewCell.h>

@implementation ICTextFieldTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.textField != nil) {
        float width = self.contentView.frame.size.width;
        self.textField.frame = CGRectMake(10, 4, width - 20, 36);
    }
}

- (void)setTextField:(ICTextField *)textField
{
    [self.textField removeFromSuperview];
    _textField = textField;
    [self.contentView addSubview:textField];
}

- (void)dealloc
{
    [self.textField endEditing:YES];
}

@end
