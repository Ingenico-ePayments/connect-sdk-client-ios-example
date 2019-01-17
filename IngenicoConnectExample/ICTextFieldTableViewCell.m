//
//  ICTextFieldTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICTextFieldTableViewCell.h>

@interface ICTextFieldTableViewCell ()

@property (strong, nonatomic) ICTextField *textField;
@property (strong, nonatomic) ICLabel *errorLabel;

@end

@implementation ICTextFieldTableViewCell
-(void)setReadonly:(BOOL)readonly {
    self.textField.enabled = !readonly;
}
-(BOOL)readonly {
    return !self.textField.enabled;
}
+ (NSString *)reuseIdentifier {
    return @"text-field-cell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textField = [[ICTextField alloc]init];
        self.clipsToBounds = YES;
        [self addSubview:self.textField];
        
        self.errorLabel = [[ICLabel alloc]init];
        self.errorLabel.font = [UIFont systemFontOfSize:12];
        self.errorLabel.numberOfLines = 0;
        self.errorLabel.textColor = [UIColor redColor];
        [self addSubview:self.errorLabel];
    }
    
    return self;
}

- (void)setField:(ICFormRowField *)field {
    _field = field;
    if (field != nil) {
        self.textField.text = field.text;
        self.textField.placeholder = field.placeholder;
        self.textField.keyboardType = field.keyboardType;
        self.textField.secureTextEntry = field.isSecure;
    } else {
        self.textField.text = nil;
        self.textField.placeholder = nil;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.secureTextEntry = false;
    }
}

- (UIView *)rightView {
    return self.textField.rightView;
}
- (void)setRightView:(UIView *)view {
    self.textField.rightViewMode = view != nil ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    self.textField.rightView = view;
}

- (NSString *)error {
    return self.errorLabel.text;
}
- (void)setError:(NSString *)error {
    self.errorLabel.text = error;
}

- (NSObject<UITextFieldDelegate> *)delegate {
    return self.textField.delegate;
}
- (void)setDelegate:(NSObject<UITextFieldDelegate> *)delegate {
    self.textField.delegate = delegate;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.textField != nil) {
        CGFloat width = [self accessoryAndMarginCompatibleWidth];
        CGFloat leftMargin = [self accessoryCompatibleLeftMargin];
        self.textField.frame =  CGRectMake(leftMargin, 4,  width, 36);
        self.errorLabel.frame = CGRectMake(leftMargin, 44, width, 20);
        self.errorLabel.preferredMaxLayoutWidth = width - 20;
        [self.errorLabel sizeToFit];
        self.errorLabel.frame = CGRectMake(leftMargin, 44, width, self.errorLabel.frame.size.height);
    }
}

- (void)prepareForReuse {
    self.field = nil;
    self.delegate = nil;
    self.rightView = nil;
    self.error = nil;
}

- (void)dealloc
{
    [self.textField endEditing:YES];
}

@end
