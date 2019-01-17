//
//  ICSwitchTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICSwitchTableViewCell.h>

@interface ICSwitchTableViewCell ()

@property (strong, nonatomic) UISwitch *switchControl;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) ICLabel *errorLabel;
@end

@implementation ICSwitchTableViewCell

+ (NSString *)reuseIdentifier {
    return @"switch-cell";
}
-(BOOL)readonly {
    return !self.switchControl.isEnabled;
}
-(void)setReadonly:(BOOL)readonly {
    self.switchControl.enabled = !readonly;
}
-(NSAttributedString *)attributedTitle {
    return self.textView.attributedText;
}
- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    self.textView.attributedText = attributedTitle;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.switchControl = [[UISwitch alloc] init];
        [self addSubview:self.switchControl];
        self.clipsToBounds = YES;
        self.textView = [[UITextView alloc]init];
        // To center the text in the textView
        [self.textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        [self addSubview:self.textView];
        self.textView.editable = NO;
        self.textView.scrollEnabled = NO;

        self.textView.font = [UIFont systemFontOfSize:12.0f];
        self.errorLabel = [[ICLabel alloc]init];
        self.errorLabel.font = [UIFont systemFontOfSize:12];
        self.errorLabel.numberOfLines = 0;
        self.errorLabel.textColor = [UIColor redColor];
        [self addSubview:self.errorLabel];

        [self setSwitchTarget:nil action:nil];
    }
    return self;
}
- (void)setOn:(BOOL)on {
    self.switchControl.on = on;
}
- (BOOL)isOn {
    return self.switchControl.on;
}
- (NSString *)errorMessage {
    return self.errorLabel.text;
}
- (void)setErrorMessage:(NSString *)error {
    self.errorLabel.text = error;
    [self setNeedsLayout];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat topCorrect = ([(UITextView *)object bounds].size.height - [(UITextView *)object contentSize].height * [(UITextView *)object zoomScale])/2.0;
    if (topCorrect < 0) {
        topCorrect = 0;
    }
    ((UITextView *)object).contentOffset = CGPointMake(0, -topCorrect);
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = [self accessoryAndMarginCompatibleWidth];
    CGFloat leftMargin = [self accessoryCompatibleLeftMargin];
    CGFloat switchWidth = self.switchControl.frame.size.width;
    
    self.textView.frame = CGRectMake(leftMargin + 16 + switchWidth, 10, width - switchWidth, 44);
    self.switchControl.frame = CGRectMake(leftMargin, 7, 0, 0);
    self.switchControl.center = CGPointMake(leftMargin + switchWidth/2, CGRectGetMidY(self.textView.frame));
    self.errorLabel.frame = CGRectMake(leftMargin, 64, width, 20);
    self.errorLabel.preferredMaxLayoutWidth = width - 20;
    [self.errorLabel sizeToFit];
    self.errorLabel.frame = CGRectMake(leftMargin, self.textView.frame.origin.y + self.textView.frame.size.height + 5, width, self.errorLabel.frame.size.height);
}

- (void)setSwitchTarget:(id)target action:(SEL)action {
    if (target == nil) {
        target = self;
    }
    if (action == nil) {
        action = @selector(didSwitch:);
    }
    [self.switchControl removeTarget: nil action: nil forControlEvents:UIControlEventAllEvents];
    [self.switchControl addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)didSwitch:(ICSwitch *)sender {
    if (self.delegate) {
        [self.delegate switchChanged: sender];
    }
}
- (void)prepareForReuse {
    self.delegate = nil;
    self.attributedTitle = nil;
    self.errorMessage = nil;
    [self setSwitchTarget:nil action:nil];
}

@end
