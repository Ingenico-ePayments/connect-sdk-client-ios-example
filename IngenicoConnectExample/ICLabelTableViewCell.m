//
//  ICLabelTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICLabelTableViewCell.h>
#import "ICFormRowLabel.h"
@interface ICLabelTableViewCell ()

@property (strong, nonatomic) ICLabel *labelView;

@end

@implementation ICLabelTableViewCell
@synthesize bold=_bold;
+ (UIFont *)labelFontForBold:(BOOL)boldness {
    UIFont *font;
    if (boldness) {
        font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    }
    else {
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    return font;
}
+ (CGSize)labelSizeForWidth: (CGFloat)width forText:(NSString *)text bold: (BOOL)bold {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize constrainRect = CGSizeMake(width, CGFLOAT_MAX);
    UILabel *dummyLabel = [[UILabel alloc]init];
    dummyLabel.numberOfLines = 0;
    dummyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    dummyLabel.text = text;
    CGSize size = [dummyLabel sizeThatFits:constrainRect];
    return size;
    
    //CGRect boundingBox = [text boundingRectWithSize:constrainRect options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: [self labelFontForBold:bold], NSParagraphStyleAttributeName: style} context:nil];
    //boundingBox.size.height = ceil(boundingBox.size.height);
    //boundingBox.size.height += 30;
    //return boundingBox.size;
}
+ (CGSize)cellSizeForWidth:(CGFloat)width forFormRow:(ICFormRowLabel *)label {
    CGSize labelSize = [self labelSizeForWidth:width forText:label.text bold:label.bold];
    labelSize.height += 8;
    return labelSize;
}
- (CGSize)labelSizeForWidth: (CGFloat)width {
    return [[self class] labelSizeForWidth:width forText:self.label bold:self.bold];
}
+ (NSString *)reuseIdentifier {
    return @"label-cell";
}

- (NSString *)label {
    return self.labelView.text;
}
- (void)setLabel:(NSString *)label {
    self.labelView.text = label;
    self.labelView.numberOfLines = 0;
}
- (BOOL) isBold {
    return _bold;
}
- (void) setBold:(BOOL)bold {
    _bold = bold;
    UIFont *font = [[self class] labelFontForBold:bold];
    self.labelView.font = font;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.labelView = [[ICLabel alloc]init];
        [self addSubview:self.labelView];
        self.clipsToBounds = YES;
        self.labelView.numberOfLines = 0;
        self.labelView.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = [self accessoryAndMarginCompatibleWidth];
    CGFloat leftMargin = [self accessoryCompatibleLeftMargin];
    self.labelView.frame = CGRectMake(leftMargin, 4, width, [self labelSizeForWidth: width].height);
}
-(void)prepareForReuse {
    self.label = nil;
}
@end
