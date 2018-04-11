//
//  ICFormRowsConverter.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectSDK/ICValidator.h>
#import <IngenicoConnectExample/ICFormRowsConverter.h>
#import <IngenicoConnectExample/ICFormRowList.h>
#import <IngenicoConnectExample/ICFormRowTextField.h>
#import <IngenicoConnectExample/ICFormRowSwitch.h>
#import <IngenicoConnectExample/ICPaymentProductInputData.h>
#import <IngenicoConnectExample/ICFormRowCurrency.h>
#import <IngenicoConnectSDK/ICIINDetailsResponse.h>
#import <IngenicoConnectExample/ICFormRowLabel.h>
#import <IngenicoConnectSDK/ICValidationErrorLength.h>
#import <IngenicoConnectSDK/ICValidationErrorIBAN.h>
#import <IngenicoConnectSDK/ICValidationErrorRange.h>
#import <IngenicoConnectSDK/ICValidationErrorExpirationDate.h>
#import <IngenicoConnectSDK/ICValidationErrorFixedList.h>
#import <IngenicoConnectSDK/ICValidationErrorLuhn.h>
#import <IngenicoConnectSDK/ICValidationErrorRegularExpression.h>
#import <IngenicoConnectSDK/ICValidationErrorIsRequired.h>
#import <IngenicoConnectSDK/ICValueMappingItem.h>
#import <IngenicoConnectSDK/ICValidationErrorAllowed.h>
#import <IngenicoConnectSDK/ICValidationErrorEmailAddress.h>
#import <IngenicoConnectSDK/ICValidationErrorTermsAndConditions.h>

#import "ICFormRowDate.h"
@interface ICFormRowsConverter ()

+ (NSBundle *)sdkBundle;

@end

@implementation ICFormRowsConverter

static NSBundle * _sdkBundle;
+ (NSBundle *)sdkBundle {
    if (_sdkBundle == nil) {
        _sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    }
    return _sdkBundle;
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (NSMutableArray *)formRowsFromInputData:(ICPaymentProductInputData *)inputData viewFactory:(ICViewFactory *)viewFactory confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts {
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    for (ICPaymentProductField* field in inputData.paymentItem.fields.paymentProductFields) {
        ICFormRow *row;
        BOOL isPartOfAccountOnFile = [inputData fieldIsPartOfAccountOnFile:field.identifier];
        NSString *value;
        BOOL isEnabled;
        if (isPartOfAccountOnFile == YES) {
            NSString *mask = field.displayHints.mask;
            value = [inputData.accountOnFile maskedValueForField:field.identifier mask:mask];
            isEnabled = [inputData fieldIsReadOnly:field.identifier] == NO;
        } else {
            value = [inputData maskedValueForField:field.identifier];
            isEnabled = YES;
        }
        row = [self labelFormRowFromField:field paymentProduct:inputData.paymentItem.identifier viewFactory:viewFactory];
        [rows addObject:row];
        switch (field.displayHints.formElement.type) {
            case ICListType: {
                row = [self listFormRowFromField:field value:value isEnabled:isEnabled viewFactory:viewFactory];
                break;
            }
            case ICTextType: {
                row = [self textFieldFormRowFromField:field paymentItem:inputData.paymentItem value:value isEnabled:isEnabled confirmedPaymentProducts:confirmedPaymentProducts viewFactory:viewFactory];
                break;
            }
            case ICBoolType: {
                [rows removeLastObject]; // Label is integrated into switch field
                row = [self switchFormRowFromField: field paymentItem: inputData.paymentItem value: value isEnabled: isEnabled viewFactory: viewFactory];
                break;
            }
            case ICDateType: {
                row = [self dateFormRowFromField: field paymentItem: inputData.paymentItem value: value isEnabled: isEnabled viewFactory: viewFactory];
                break;

            }
            case ICCurrencyType: {
                row = [self currencyFormRowFromField:field paymentItem:inputData.paymentItem value:value isEnabled:isEnabled viewFactory:viewFactory];
                break;
            }
            default: {
                [NSException raise:@"Invalid form element type" format:@"Form element type %d is invalid", field.displayHints.formElement.type];
                break;
            }
        }
        [rows addObject:row];
//        if (validation == YES) {
//            if (field.errors.count > 0) {
//                row = [self errorFormRowWithError:field.errors.firstObject forCurrency:field.displayHints.formElement.type == ICCurrencyType];
//                [rows addObject:row];
//            } else if (iinDetailsResponse != nil && [field.identifier isEqualToString:@"cardNumber"]) {
//                ICValidationError *iinLookupError = [self errorWithIINDetails:iinDetailsResponse];
//                if (iinLookupError != nil) {
//                    row = [self errorFormRowWithError:iinLookupError forCurrency:field.displayHints.formElement.type == ICCurrencyType];
//                    [rows addObject:row];
//                }
//            }
//        }
    }
    return rows;
}

- (ICValidationError *)errorWithIINDetails:(ICIINDetailsResponse *)iinDetailsResponse {
    //Validation error
    if (iinDetailsResponse.status == ICExistingButNotAllowed) {
        return [ICValidationErrorAllowed new];
    } else if (iinDetailsResponse.status == ICUnknown) {
        return [ICValidationErrorLuhn new];
    }
    return nil;
}

+ (NSString *)errorMessageForError:(ICValidationError *)error withCurrency:(BOOL)forCurrency
{
    Class errorClass = [error class];
    NSString *errorMessageFormat = @"gc.general.paymentProductFields.validationErrors.%@.label";
    NSString *errorMessageKey;
    NSString *errorMessageValue;
    NSString *errorMessage;
    if (errorClass == [ICValidationErrorLength class]) {
        ICValidationErrorLength *lengthError = (ICValidationErrorLength *)error;
        if (lengthError.minLength == lengthError.maxLength) {
            errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"length.exact"];
        } else if (lengthError.minLength == 0 && lengthError.maxLength > 0) {
            errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"length.max"];
        } else if (lengthError.minLength > 0 && lengthError.maxLength > 0) {
            errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"length.between"];
        }
        NSString *errorMessageValueWithPlaceholders = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        NSString *errorMessageValueWithPlaceholder = [errorMessageValueWithPlaceholders stringByReplacingOccurrencesOfString:@"{maxLength}" withString:[NSString stringWithFormat:@"%ld", lengthError.maxLength]];
        errorMessage = [errorMessageValueWithPlaceholder stringByReplacingOccurrencesOfString:@"{minLength}" withString:[NSString stringWithFormat:@"%ld", lengthError.minLength]];
    } else if (errorClass == [ICValidationErrorRange class]) {
        ICValidationErrorRange *rangeError = (ICValidationErrorRange *)error;
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"length.between"];
        NSString *errorMessageValueWithPlaceholders = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        NSString *minString;
        NSString *maxString;
        if (forCurrency == YES) {
            minString = [NSString stringWithFormat:@"%.2f", (double)rangeError.minValue / 100];
            maxString = [NSString stringWithFormat:@"%.2f", (double)rangeError.maxValue / 100];
        } else {
            minString = [NSString stringWithFormat:@"%ld", (long)rangeError.minValue];
            maxString = [NSString stringWithFormat:@"%ld", (long)rangeError.maxValue];
        }
        NSString *errorMessageValueWithPlaceholder = [errorMessageValueWithPlaceholders stringByReplacingOccurrencesOfString:@"{minValue}" withString:minString];
        errorMessageValue = [errorMessageValueWithPlaceholder stringByReplacingOccurrencesOfString:@"{maxValue}" withString:maxString];
    } else if (errorClass == [ICValidationErrorExpirationDate class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"expirationDate"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorFixedList class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"fixedList"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorLuhn class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"luhn"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorAllowed class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"allowedInContext"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorEmailAddress class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"emailAddress"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorIBAN class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"regularExpression"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorRegularExpression class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"regularExpression"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorTermsAndConditions class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"termsAndConditions"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorIsRequired class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"required"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        errorMessage = errorMessageValue;
    } else {
        [NSException raise:@"Invalid validation error" format:@"Validation error %@ is invalid", error];
    }
    return errorMessage;
}
- (ICFormRowTextField *)textFieldFormRowFromField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem value:(NSString *)value isEnabled:(BOOL)isEnabled confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts viewFactory:(ICViewFactory *)viewFactory
{
    NSString *placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.placeholder", paymentItem.identifier, field.identifier];
    NSString *placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
    if ([placeholderKey isEqualToString:placeholderValue] == YES) {
        placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.placeholder", field.identifier];
        placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
    }
    
    UIKeyboardType keyboardType = UIKeyboardTypeDefault;
    if (field.displayHints.preferredInputType == ICIntegerKeyboard) {
        keyboardType = UIKeyboardTypeNumberPad;
    } else if (field.displayHints.preferredInputType == ICEmailAddressKeyboard) {
        keyboardType = UIKeyboardTypeEmailAddress;
    } else if (field.displayHints.preferredInputType == ICPhoneNumberKeyboard) {
        keyboardType = UIKeyboardTypePhonePad;
    }
    
    ICFormRowField *formField = [[ICFormRowField alloc] initWithText:value placeholder:placeholderValue keyboardType:keyboardType isSecure:field.displayHints.obfuscate];
    ICFormRowTextField *row = [[ICFormRowTextField alloc] initWithPaymentProductField:field field:formField];
    row.isEnabled = isEnabled;
    
    if ([field.identifier isEqualToString:@"cardNumber"] == YES) {
        if ([confirmedPaymentProducts member:paymentItem.identifier] != nil) {
            row.logo = paymentItem.displayHints.logoImage;
        }
        else {
            row.logo = nil;
        }
    }
    
    [self setTooltipForFormRow:row withField:field paymentItem:paymentItem];
    
    return row;
}

- (ICFormRowSwitch *)switchFormRowFromField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem value:(NSString *)value isEnabled:(BOOL)isEnabled viewFactory:(ICViewFactory *)viewFactory
{
    NSString *descriptionKey = [NSString stringWithFormat: @"gc.general.paymentProducts.%@.paymentProductFields.%@.label", paymentItem.identifier, field.identifier];
    NSString *descriptionValue = NSLocalizedStringWithDefaultValue(descriptionKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil, @"Accept {link}");
    NSString *labelKey = [NSString stringWithFormat: @"gc.general.paymentProducts.%@.paymentProductFields.%@.link.label", paymentItem.identifier, field.identifier];
    NSString *labelValue = NSLocalizedStringWithDefaultValue(labelKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil, @"AfterPay");
    NSRange range = [descriptionValue rangeOfString:@"{link}"];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:descriptionValue];
    NSAttributedString *linkString = [[NSAttributedString alloc]initWithString:labelValue attributes:@{NSLinkAttributeName:field.displayHints.link.absoluteString}];
    [attrString replaceCharactersInRange:range withAttributedString:linkString];
    //NSString *labelString = [field.displayHints.label stringByReplacingOccurrencesOfString:@"{link}" withString:]]

    ICFormRowSwitch *row = [[ICFormRowSwitch alloc] initWithAttributedTitle:attrString isOn:[value isEqualToString:@"true"] target:nil action:NULL paymentProductField:field];
    row.isEnabled = isEnabled;

    return row;
}
- (ICFormRowDate *)dateFormRowFromField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem value:(NSString *)value isEnabled:(BOOL)isEnabled viewFactory:(ICViewFactory *)viewFactory
{
    ICFormRowDate *row = [[ICFormRowDate alloc] init];
    row.paymentProductField = field;
    row.isEnabled = isEnabled;
    
    return row;
}


- (ICFormRowCurrency *)currencyFormRowFromField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem value:(NSString *)value isEnabled:(BOOL)isEnabled viewFactory:(ICViewFactory *)viewFactory
{
    NSString *placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.placeholder", paymentItem.identifier, field.identifier];
    NSString *placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
    if ([placeholderKey isEqualToString:placeholderValue] == YES) {
        placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.placeholder", field.identifier];
        placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
    }
    
    ICFormRowCurrency *row = [[ICFormRowCurrency alloc] init];
    row.integerField = [[ICFormRowField alloc] init];
    row.fractionalField = [[ICFormRowField alloc] init];
    
    row.integerField.placeholder = placeholderValue;
    if (field.displayHints.preferredInputType == ICIntegerKeyboard) {
        row.integerField.keyboardType = UIKeyboardTypeNumberPad;
        row.fractionalField.keyboardType = UIKeyboardTypeNumberPad;
    } else if (field.displayHints.preferredInputType == ICEmailAddressKeyboard) {
        row.integerField.keyboardType = UIKeyboardTypeEmailAddress;
        row.fractionalField.keyboardType = UIKeyboardTypeEmailAddress;
    } else if (field.displayHints.preferredInputType == ICPhoneNumberKeyboard) {
        row.integerField.keyboardType = UIKeyboardTypePhonePad;
        row.fractionalField.keyboardType = UIKeyboardTypePhonePad;
    }
    
    long long integerPart = [value longLongValue] / 100;
    int fractionalPart = (int) llabs([value longLongValue] % 100);
    row.integerField.isSecure = field.displayHints.obfuscate;
    row.integerField.text = [NSString stringWithFormat:@"%lld", integerPart];
    row.fractionalField.isSecure = field.displayHints.obfuscate;
    row.fractionalField.text = [NSString stringWithFormat:@"%02d", fractionalPart];
    row.paymentProductField = field;

    row.isEnabled = isEnabled;
    [self setTooltipForFormRow:row withField:field paymentItem:paymentItem];
    
    return row;
}

- (void)setTooltipForFormRow:(ICFormRowWithInfoButton *)row withField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem
{
    if (field.displayHints.tooltip.imagePath != nil) {
        ICFormRowTooltip *tooltip = [ICFormRowTooltip new];
        NSString *tooltipTextKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.tooltipText", paymentItem.identifier, field.identifier];
        NSString *tooltipTextValue = NSLocalizedStringFromTableInBundle(tooltipTextKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        if ([tooltipTextKey isEqualToString:tooltipTextValue] == YES) {
            tooltipTextKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.tooltipText", field.identifier];
            tooltipTextValue = NSLocalizedStringFromTableInBundle(tooltipTextKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
        }
        tooltip.text = tooltipTextValue;
        tooltip.image = field.displayHints.tooltip.image;
        row.tooltip = tooltip;
    }
}

- (ICFormRowList *)listFormRowFromField:(ICPaymentProductField *)field value:(NSString *)value isEnabled:(BOOL)isEnabled viewFactory:(ICViewFactory *)viewFactory
{
    ICFormRowList *row = [[ICFormRowList alloc] initWithPaymentProductField:field];
    
    NSInteger rowIndex = 0;
    NSInteger selectedRow = 0;
    for (ICValueMappingItem *item in field.displayHints.formElement.valueMapping) {
        if (item.value != nil) {
            if ([item.value isEqualToString:value]) {
                selectedRow = rowIndex;
            }
            [row.items addObject:item];
        }
        ++rowIndex;
    }

    row.selectedRow = selectedRow;
    return row;
}
- (NSString *)labelStringFormRowFromField:(ICPaymentProductField *)field paymentProduct:(NSString *)paymentProductId {
    NSString *labelKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.label", paymentProductId, field.identifier];
    NSString *labelValue = NSLocalizedStringFromTableInBundle(labelKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
    if ([labelKey isEqualToString:labelValue] == YES) {
        labelKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.label", field.identifier];
        labelValue = NSLocalizedStringFromTableInBundle(labelKey, kICSDKLocalizable, [ICFormRowsConverter sdkBundle], nil);
    }
    return labelValue;
}
- (ICFormRowLabel *)labelFormRowFromField:(ICPaymentProductField *)field paymentProduct:(NSString *)paymentProductId viewFactory:(ICViewFactory *)viewFactory
{
    ICFormRowLabel *row = [[ICFormRowLabel alloc] init];
    NSString *labelValue = [self labelStringFormRowFromField:field paymentProduct:paymentProductId];
    row.text = labelValue;
    
    return row;
}

@end
