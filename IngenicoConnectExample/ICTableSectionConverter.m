//
//  ICTableSectionConverter.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectExample/ICTableSectionConverter.h>
#import <IngenicoConnectExample/ICPaymentProductsTableRow.h>
#import <IngenicoConnectSDK/ICPaymentItems.h>
#import <IngenicoConnectSDK/ICBasicPaymentProductGroup.h>

@implementation ICTableSectionConverter

+ (ICPaymentProductsTableSection *)paymentProductsTableSectionFromAccountsOnFile:(NSArray *)accountsOnFile paymentItems:(ICPaymentItems *)paymentItems
{
    ICPaymentProductsTableSection *section = [[ICPaymentProductsTableSection alloc] init];
    section.type = ICAccountOnFileType;
    for (ICAccountOnFile *accountOnFile in accountsOnFile) {
        id<ICBasicPaymentItem> product = [paymentItems paymentItemWithIdentifier:accountOnFile.paymentProductIdentifier];
        ICPaymentProductsTableRow *row = [[ICPaymentProductsTableRow alloc] init];
        NSString *displayName = [accountOnFile label];
        row.name = displayName;
        row.accountOnFileIdentifier = accountOnFile.identifier;
        row.paymentProductIdentifier = accountOnFile.paymentProductIdentifier;
        row.logo = product.displayHints.logoImage;
        [section.rows addObject:row];
    }
    return section;
}

+ (ICPaymentProductsTableSection *)paymentProductsTableSectionFromPaymentItems:(ICPaymentItems *)paymentItems
{
    NSBundle *sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    
    ICPaymentProductsTableSection *section = [[ICPaymentProductsTableSection alloc] init];
    for (NSObject<ICPaymentItem> *paymentItem in paymentItems.paymentItems) {
        section.type = ICPaymentProductType;
        ICPaymentProductsTableRow *row = [[ICPaymentProductsTableRow alloc] init];
        NSString *paymentProductKey = [self localizationKeyWithPaymentItem:paymentItem];
        NSString *paymentProductValue = NSLocalizedStringFromTableInBundle(paymentProductKey, kICSDKLocalizable, sdkBundle, nil);
        row.name = paymentProductValue;
        row.accountOnFileIdentifier = @"";
        row.paymentProductIdentifier = paymentItem.identifier;
        row.logo = paymentItem.displayHints.logoImage;
        [section.rows addObject:row];
    }
    return section;
}

+ (NSString *)localizationKeyWithPaymentItem:(NSObject<ICBasicPaymentItem> *)paymentItem {
    if ([paymentItem isKindOfClass:[ICBasicPaymentProduct class]]) {
        return [NSString stringWithFormat:@"gc.general.paymentProducts.%@.name", paymentItem.identifier];
    }
    else if ([paymentItem isKindOfClass:[ICBasicPaymentProductGroup class]]) {
        return [NSString stringWithFormat:@"gc.general.paymentProductGroups.%@.name", paymentItem.identifier];
    }
    else {
        return @"";
    }
}

@end
