//
//  ICCurrencyTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICCurrencyTableViewCell.h>

@interface ICCurrencyTableViewCell ()

@property (strong, nonatomic) UILabel *separatorlabel;
@property (strong, nonatomic) UILabel *currencyCodeLabel;
@property (strong, nonatomic) ICIntegerTextField *integerTextField;
@property (strong, nonatomic) ICFractionalTextField *fractionalTextField;

@end

@implementation ICCurrencyTableViewCell

+ (NSString *)reuseIdentifier {
    return @"currency-text-field-cell";
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self != nil) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];

        self.separatorlabel = [[UILabel alloc] init];
        self.separatorlabel.text = [formatter decimalSeparator];
        [self.contentView addSubview:self.separatorlabel];
        
        self.currencyCodeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.currencyCodeLabel];
        
        self.clipsToBounds = YES;
    }
    return self;
}
-(BOOL)readonly {
    return self->_readonly;
}
-(void)setReadonly:(BOOL)readonly {
    self->_integerTextField.enabled = !readonly;
    self->_fractionalTextField.enabled = !readonly;
    self->_readonly = readonly;
}
- (void)layoutSubviews {
    [super layoutSubviews];

    float width = self.contentView.frame.size.width;
    int padding = 10;
    int currencyCodeWidth = 36;
    int fractionalWidth = 50;
    int separatorWidth = 8;
    
    int currencyCodeX = padding;
    int integerX = currencyCodeX + currencyCodeWidth + padding;
    int separatorX = width - padding - fractionalWidth - padding - separatorWidth;
    int fractionalX = width - padding - fractionalWidth;
    int integerWidth = separatorX - padding - integerX;
    
    self.separatorlabel.frame = CGRectMake(separatorX, 7, separatorWidth, 30);
    self.currencyCodeLabel.frame = CGRectMake(currencyCodeX, 7, currencyCodeWidth, 30);
    if (self.integerTextField != nil) {
        self.integerTextField.frame = CGRectMake(integerX, 4, integerWidth, 36);
    }
    if (self.fractionalTextField != nil) {
        self.fractionalTextField.frame = CGRectMake(fractionalX, 4, fractionalWidth, 36);
    }
}

- (void)setIntegerField:(ICFormRowField *)integerField
{
    _integerField = integerField;
    self.integerTextField.text = integerField.text;
    self.integerTextField.placeholder = integerField.placeholder;
    self.integerTextField.keyboardType = integerField.keyboardType;
    self.integerTextField.secureTextEntry = integerField.isSecure;
    self.integerTextField.textAlignment = NSTextAlignmentRight;
}

- (void)setFractionalField:(ICFormRowField *)fractionalField
{
    _fractionalField = fractionalField;
    self.fractionalTextField.text = fractionalField.text;
    self.fractionalTextField.placeholder = fractionalField.placeholder;
    self.fractionalTextField.keyboardType = fractionalField.keyboardType;
    self.fractionalTextField.secureTextEntry = fractionalField.isSecure;
}

- (void)setCurrencyCode:(NSString *)currencyCode
{
    _currencyCode = currencyCode;
    self.currencyCodeLabel.text = currencyCode;
}

- (void)dealloc
{
    [self.integerTextField endEditing:YES];
    [self.fractionalTextField endEditing:YES];
}

@end
