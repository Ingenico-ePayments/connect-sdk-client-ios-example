//
//  ICCOBrandsExplanationTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICCOBrandsExplanationTableViewCell.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>

@implementation ICCOBrandsExplanationTableViewCell {

}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.attributedText = [ICCOBrandsExplanationTableViewCell cellString];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
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

@end
