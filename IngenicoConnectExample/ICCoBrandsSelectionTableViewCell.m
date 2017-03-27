//
//  ICCoBrandsSelectionTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICCoBrandsSelectionTableViewCell.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>

@implementation ICCoBrandsSelectionTableViewCell {

}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        UIFont *font = [UIFont systemFontOfSize:13];
        NSDictionary *underlineAttribute = @{
                NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                NSFontAttributeName: font
        };

        NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
        NSString *cobrandsKey = @"gc.general.cobrands.toggleCobrands";
        NSString *cobrandsString = NSLocalizedStringFromTableInBundle(cobrandsKey, kICSDKLocalizable, sdkBundle, nil);
        self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:cobrandsString
                                                                 attributes:underlineAttribute];
        self.textLabel.textAlignment = NSTextAlignmentRight;
    }

    return self;
}

@end
