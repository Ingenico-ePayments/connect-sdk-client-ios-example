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
#import <IngenicoConnectExample/ICPaymentProductInputData.h>
#import <IngenicoConnectExample/ICFormRowCurrency.h>
#import <IngenicoConnectSDK/ICIINDetailsResponse.h>
#import <IngenicoConnectExample/ICFormRowLabel.h>
#import <IngenicoConnectExample/ICFormRowErrorMessage.h>
#import <IngenicoConnectSDK/ICValidationError.h>
#import <IngenicoConnectSDK/ICValidationErrorLength.h>
#import <IngenicoConnectSDK/ICValidationErrorRange.h>
#import <IngenicoConnectSDK/ICValidationErrorExpirationDate.h>
#import <IngenicoConnectSDK/ICValidationErrorFixedList.h>
#import <IngenicoConnectSDK/ICValidationErrorLuhn.h>
#import <IngenicoConnectSDK/ICValidationErrorRegularExpression.h>
#import <IngenicoConnectSDK/ICValidationErrorIsRequired.h>
#import <IngenicoConnectSDK/ICValueMappingItem.h>
#import <IngenicoConnectSDK/ICValidationErrorAllowed.h>

@interface ICFormRowsConverter ()

@property (strong, nonatomic) NSBundle *sdkBundle;

@end

@implementation ICFormRowsConverter

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        self.sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    }
    return self;
}

- (NSMutableArray *)formRowsFromInputData:(ICPaymentProductInputData *)inputData iinDetailsResponse:(ICIINDetailsResponse *)iinDetailsResponse validation:(BOOL)validation viewFactory:(ICViewFactory *)viewFactory confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts {
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
        if (validation == YES) {
            if (field.errors.count > 0) {
                row = [self errorFormRowWithError:field.errors.firstObject forCurrency:field.displayHints.formElement.type == ICCurrencyType];
                [rows addObject:row];
            } else if (iinDetailsResponse != nil && [field.identifier isEqualToString:@"cardNumber"]) {
                ICValidationError *iinLookupError = [self errorWithIINDetails:iinDetailsResponse];
                if (iinLookupError != nil) {
                    row = [self errorFormRowWithError:iinLookupError forCurrency:field.displayHints.formElement.type == ICCurrencyType];
                    [rows addObject:row];
                }
            }
        }
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

- (ICFormRowErrorMessage *)errorFormRowWithError:(ICValidationError *)error forCurrency:(BOOL)forCurrency
{
    ICFormRowErrorMessage *row = [[ICFormRowErrorMessage alloc] init];
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
        NSString *errorMessageValueWithPlaceholder = [errorMessageValueWithPlaceholders stringByReplacingOccurrencesOfString:@"{minValue}" withString:@"\%@"];
        errorMessageValue = [errorMessageValueWithPlaceholder stringByReplacingOccurrencesOfString:@"{maxValue}" withString:@"\%@"];
        NSString *minString;
        NSString *maxString;
        if (forCurrency == YES) {
            minString = [NSString stringWithFormat:@"%.2f", (double)rangeError.minValue / 100];
            maxString = [NSString stringWithFormat:@"%.2f", (double)rangeError.maxValue / 100];
        } else {
            minString = [NSString stringWithFormat:@"%ld", (long)rangeError.minValue];
            maxString = [NSString stringWithFormat:@"%ld", (long)rangeError.maxValue];
        }
        errorMessage = [NSString stringWithFormat:errorMessageValue, minString, maxString];
    } else if (errorClass == [ICValidationErrorExpirationDate class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"expirationDate"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorFixedList class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"fixedList"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorLuhn class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"luhn"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorAllowed class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"allowedInContext"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorRegularExpression class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"regularExpression"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        errorMessage = errorMessageValue;
    } else if (errorClass == [ICValidationErrorIsRequired class]) {
        errorMessageKey = [NSString stringWithFormat:errorMessageFormat, @"required"];
        errorMessageValue = NSLocalizedStringFromTableInBundle(errorMessageKey, kICSDKLocalizable, self.sdkBundle, nil);
        errorMessage = errorMessageValue;
    } else {
        [NSException raise:@"Invalid validation error" format:@"Validation error %@ is invalid", error];
    }
    row.errorMessage = errorMessage;
    return row;
}

- (ICFormRowTextField *)textFieldFormRowFromField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem value:(NSString *)value isEnabled:(BOOL)isEnabled confirmedPaymentProducts:(NSSet *)confirmedPaymentProducts viewFactory:(ICViewFactory *)viewFactory
{
    ICFormRowTextField *row = [[ICFormRowTextField alloc] init];
    row.textField = (ICTextField *)[viewFactory textFieldWithType:ICTextFieldType];
    NSString *placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.placeholder", paymentItem.identifier, field.identifier];
    NSString *placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, self.sdkBundle, nil);
    if ([placeholderKey isEqualToString:placeholderValue] == YES) {
        placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.placeholder", field.identifier];
        placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, self.sdkBundle, nil);
    }
    row.textField.placeholder = placeholderValue;
    if (field.displayHints.preferredInputType == ICIntegerKeyboard) {
        row.textField.keyboardType = UIKeyboardTypeNumberPad;
    } else if (field.displayHints.preferredInputType == ICEmailAddressKeyboard) {
        row.textField.keyboardType = UIKeyboardTypeEmailAddress;
    } else if (field.displayHints.preferredInputType == ICPhoneNumberKeyboard) {
        row.textField.keyboardType = UIKeyboardTypePhonePad;
    }
    row.textField.secureTextEntry = field.displayHints.obfuscate;
    row.textField.text = value;
    [row.textField setEnabled:isEnabled];
    row.textField.rightViewMode = UITextFieldViewModeAlways;
    row.paymentProductField = field;

    if ([field.identifier isEqualToString:@"cardNumber"] == YES) {
        if ([confirmedPaymentProducts member:paymentItem.identifier] != nil) {
            row.logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            row.logo.contentMode = UIViewContentModeScaleAspectFit;
            row.logo.image = paymentItem.displayHints.logoImage;
            row.textField.rightView = row.logo;
        }
        else {
            row.logo = nil;
            row.textField.rightView = nil;
        }
    }

    [self setTooltipForFormRow:row withField:field paymentItem:paymentItem];

    return row;
}

- (ICFormRowCurrency *)currencyFormRowFromField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem value:(NSString *)value isEnabled:(BOOL)isEnabled viewFactory:(ICViewFactory *)viewFactory
{
    ICFormRowCurrency *row = [[ICFormRowCurrency alloc] init];
    row.integerTextField = (ICIntegerTextField *)[viewFactory textFieldWithType:ICIntegerTextFieldType];
    row.fractionalTextField = (ICFractionalTextField *)[viewFactory textFieldWithType:ICFractionalTextFieldType];
    NSString *placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.placeholder", paymentItem.identifier, field.identifier];
    NSString *placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, self.sdkBundle, nil);
    if ([placeholderKey isEqualToString:placeholderValue] == YES) {
        placeholderKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.placeholder", field.identifier];
        placeholderValue = NSLocalizedStringFromTableInBundle(placeholderKey, kICSDKLocalizable, self.sdkBundle, nil);
    }
    row.integerTextField.placeholder = placeholderValue;
    if (field.displayHints.preferredInputType == ICIntegerKeyboard) {
        row.integerTextField.keyboardType = UIKeyboardTypeNumberPad;
        row.fractionalTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else if (field.displayHints.preferredInputType == ICEmailAddressKeyboard) {
        row.integerTextField.keyboardType = UIKeyboardTypeEmailAddress;
        row.fractionalTextField.keyboardType = UIKeyboardTypeEmailAddress;
    } else if (field.displayHints.preferredInputType == ICPhoneNumberKeyboard) {
        row.integerTextField.keyboardType = UIKeyboardTypePhonePad;
        row.fractionalTextField.keyboardType = UIKeyboardTypePhonePad;
    }
    
    long long integerPart = [value longLongValue] / 100;
    int fractionalPart = (int) llabs([value longLongValue] % 100);
    row.integerTextField.secureTextEntry = field.displayHints.obfuscate;
    row.integerTextField.text = [NSString stringWithFormat:@"%lld", integerPart];
    [row.integerTextField setEnabled:isEnabled];
    row.integerTextField.rightViewMode = UITextFieldViewModeNever;
    row.fractionalTextField.secureTextEntry = field.displayHints.obfuscate;
    row.fractionalTextField.text = [NSString stringWithFormat:@"%02d", fractionalPart];
    [row.fractionalTextField setEnabled:isEnabled];
    row.fractionalTextField.rightViewMode = UITextFieldViewModeNever;
    row.paymentProductField = field;

    [self setTooltipForFormRow:row withField:field paymentItem:paymentItem];
    
    return row;
}

- (void)setTooltipForFormRow:(ICFormRowWithInfoButton *)row withField:(ICPaymentProductField *)field paymentItem:(NSObject<ICPaymentItem> *)paymentItem
{
    if (field.displayHints.tooltip.imagePath != nil) {
        row.showInfoButton = YES;
        NSString *tooltipTextKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.tooltipText", paymentItem.identifier, field.identifier];
        NSString *tooltipTextValue = NSLocalizedStringFromTableInBundle(tooltipTextKey, kICSDKLocalizable, self.sdkBundle, nil);
        if ([tooltipTextKey isEqualToString:tooltipTextValue] == YES) {
            tooltipTextKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.tooltipText", field.identifier];
            tooltipTextValue = NSLocalizedStringFromTableInBundle(tooltipTextKey, kICSDKLocalizable, self.sdkBundle, nil);
        }
        row.tooltipText = tooltipTextValue;
        row.tooltipImage = field.displayHints.tooltip.image;
        row.tooltipIdentifier = field.identifier;
    }
}

- (ICFormRowList *)listFormRowFromField:(ICPaymentProductField *)field value:(NSString *)value isEnabled:(BOOL)isEnabled viewFactory:(ICViewFactory *)viewFactory
{
    ICFormRowList *row = [[ICFormRowList alloc] init];
    ICPickerView *pickerView = (ICPickerView *)[viewFactory pickerViewWithType:ICPickerViewType];
    [pickerView setUserInteractionEnabled:isEnabled];
    row.pickerView = pickerView;
    
    NSInteger rowIndex = 0;
    NSMutableDictionary *nameToIdentifierMapping = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *identifierToRowMapping = [[NSMutableDictionary alloc] init];
    NSMutableArray *displayNames = [[NSMutableArray alloc] init];
    for (ICValueMappingItem *item in field.displayHints.formElement.valueMapping) {
        [nameToIdentifierMapping setObject:item.value forKey:item.displayName];
        [identifierToRowMapping setObject:[NSString stringWithFormat:@"%ld", (long)rowIndex] forKey:item.value];
        [displayNames addObject:item.displayName];
        ++rowIndex;
    }

    pickerView.content = displayNames;
    row.nameToIdentifierMapping = nameToIdentifierMapping;
    row.identifierToRowMapping = identifierToRowMapping;
    row.selectedRow = [[identifierToRowMapping objectForKey:value] integerValue];
    row.paymentProductFieldIdentifier = field.identifier;
    return row;
}

- (ICFormRowLabel *)labelFormRowFromField:(ICPaymentProductField *)field paymentProduct:(NSString *)paymentProductId viewFactory:(ICViewFactory *)viewFactory
{
    ICFormRowLabel *row = [[ICFormRowLabel alloc] init];
    ICLabel *label = (ICLabel *)[viewFactory labelWithType:ICLabelType];
    NSString *labelKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.paymentProductFields.%@.label", paymentProductId, field.identifier];
    NSString *labelValue = NSLocalizedStringFromTableInBundle(labelKey, kICSDKLocalizable, self.sdkBundle, nil);
    if ([labelKey isEqualToString:labelValue] == YES) {
        labelKey = [NSString stringWithFormat:@"gc.general.paymentProductFields.%@.label", field.identifier];
        labelValue = NSLocalizedStringFromTableInBundle(labelKey, kICSDKLocalizable, self.sdkBundle, nil);
    }
    label.text = labelValue;
    row.label = label;
    
    return row;
}

@end
