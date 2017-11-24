//
//  ICCOBrandsExplanationTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICCOBrandsExplanationTableViewCell.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
@interface ICCOBrandsExplanationTableViewCell ()

@property (nonatomic, strong) UIView *limitedBackgroundView;

@end
@implementation ICCOBrandsExplanationTableViewCell

+ (NSString *)reuseIdentifier {
    return @"co-brand-explanation-cell";
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.limitedBackgroundView = [[UIView alloc]init];
        self.textLabel.attributedText = [ICCOBrandsExplanationTableViewCell cellString];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.clipsToBounds = YES;
        [self.limitedBackgroundView addSubview:self.textLabel];
        self.limitedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self.contentView addSubview:self.limitedBackgroundView];
    }

    return self;
}

+ (NSAttributedString *)cellString {
    UIFont *font = [UIFont systemFontOfSize:12];
    NSDictionary *fontAttribute = @{
            NSFontAttributeName: font
    };
    NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    NSString *cellKey = @"gc.general.cobrands.introText";
    NSString *cellString = NSLocalizedStringFromTableInBundle(cellKey, kICSDKLocalizable, sdkBundle, nil);
    NSAttributedString *cellStringWithFont = [[NSAttributedString alloc] initWithString:cellString
                                                                             attributes:fontAttribute];
    return cellStringWithFont;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = [super accessoryAndMarginCompatibleWidth];
    CGFloat leftMargin = [super accessoryCompatibleLeftMargin];
    self.limitedBackgroundView.frame = CGRectMake(leftMargin, 4, width, self.textLabel.frame.size.height);
    self.textLabel.frame = self.limitedBackgroundView.bounds;
}

@end
