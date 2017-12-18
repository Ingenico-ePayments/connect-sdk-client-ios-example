//
//  ICReadonlyReviewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 30/08/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICReadonlyReviewTableViewCell.h"
#import <IngenicoConnectSDK/ICSDKConstants.h>
@interface ICReadonlyReviewTableViewCell()
@property (nonatomic, strong) UITextView *labelView;
@property (nonatomic, assign) BOOL labelNeedsUpdate;
@end
@implementation ICReadonlyReviewTableViewCell
@synthesize data=_data;
+ (NSString *)reuseIdentifier {
    return @"readonly-review-cell";
}

- (void)setData:(NSDictionary<NSString *,NSString *> *)data {
    _data = data;
    [self updateLabel];
}
-(void)updateLabel {
    NSAttributedString *combiString = [ICReadonlyReviewTableViewCell labelAttributedStringForData:self.data inWidth:self.frame.size.width];
    self.labelView.attributedText = combiString;
    [self.labelView sizeToFit];
    self.labelNeedsUpdate = NO;
    [self setNeedsLayout];
}
+(NSAttributedString *)labelAttributedStringForData:(NSDictionary<NSString *, NSString *> *)data inWidth:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.tabStops = @[[[NSTextTab alloc]initWithTextAlignment:NSTextAlignmentRight location:width - 30 options:@{}]];
    NSString *successStringKey = [NSString stringWithFormat:@"gc.app.paymentProductDetails.searchConsumer.result.success.summary"];
    NSString *successString = NSLocalizedStringWithDefaultValue(successStringKey, kICSDKLocalizable,
                                                            [NSBundle bundleWithPath:kICSDKBundlePath],
                                                            successStringKey, @"");
    successString = [successString stringByReplacingOccurrencesOfString:@"{br}" withString:@"\n"];
    for (NSString *key in data) {
        successString = [successString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:data[key]];
//        NSString *value = self.data[key];
//        NSAttributedString *ats = [self attributedStringFromPropertyKey:key andValue:value];
//        if (combiString.length > 0) {
//            [combiString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
//
//        }
//        [combiString appendAttributedString:ats];
//        
    }
//    [combiString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, combiString.length)];
    NSMutableAttributedString *combiString = [[NSMutableAttributedString alloc]initWithString:successString];
    return combiString;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.labelView = [[UITextView alloc]init];
        [self addSubview:self.labelView];
        self.clipsToBounds = YES;
        self.labelView.editable = NO;
        self.labelView.scrollEnabled = NO;
        // We need to populate the textView, but we need the width for it,
        // and the width is only known after -layoutSubViews is called
        self.labelNeedsUpdate = YES;
        [self setNeedsLayout];
    }
    
    return self;
}
+(CGFloat)cellHeightForData:(NSDictionary<NSString *, NSString *> *)data inWidth:(CGFloat)width {
    UITextView *label = [[UITextView alloc]init];
    label.editable = NO;
    label.scrollEnabled = NO;
    [label setAttributedText:[self labelAttributedStringForData:data inWidth:width]];
    CGFloat height = [label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    return height;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = [self accessoryAndMarginCompatibleWidth];
    CGFloat leftMargin = [self accessoryCompatibleLeftMargin];
    
    CGRect labelFrame = CGRectMake(leftMargin, 10, width, 180);
    labelFrame.size.height = [self.labelView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    self.labelView.frame = labelFrame;
    
    if (self.labelNeedsUpdate) {
        [self updateLabel];
    }
}
@end
