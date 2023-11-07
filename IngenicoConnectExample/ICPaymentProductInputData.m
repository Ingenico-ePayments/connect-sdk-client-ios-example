//
//  ICPaymentProductInputData.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICPaymentProductInputData.h>
#import <IngenicoConnectSDK/ICPaymentItem.h>
#import <IngenicoConnectSDK/ICAccountOnFile.h>
#import <IngenicoConnectSDK/ICPaymentProductField.h>
#import <IngenicoConnectSDK/ICAccountOnFileAttribute.h>
#import <IngenicoConnectSDK/ICValidator.h>
#import <IngenicoConnectSDK/ICValidatorFixedList.h>
#import <IngenicoConnectSDK/ICPaymentProductFields.h>
#import <IngenicoConnectSDK/ICPaymentRequest.h>

@interface ICPaymentProductInputData ()

@property (strong, nonatomic) NSMutableDictionary *fieldValues;
@property (strong, nonatomic) ICStringFormatter *formatter;

@end

@implementation ICPaymentProductInputData
- (NSArray<NSString *> *)fields {
    return self.fieldValues.allKeys;
}
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.formatter = [[ICStringFormatter alloc] init];
        self.fieldValues = [[NSMutableDictionary alloc] init];
        self.errors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (ICPaymentRequest *)paymentRequest {
    ICPaymentRequest *paymentRequest = [[ICPaymentRequest alloc] init];

    if ([self.paymentItem isKindOfClass:[ICPaymentProduct class]]) {
        paymentRequest.paymentProduct = (ICPaymentProduct *) self.paymentItem;
    }
    else {
        paymentRequest.paymentProduct = [[ICPaymentProduct alloc] init];
    }
    paymentRequest.accountOnFile = self.accountOnFile;
    paymentRequest.tokenize = self.tokenize;
    NSDictionary *unmaskedValues = [self unmaskedFieldValues];
    for (NSString *key in unmaskedValues.allKeys) {
        // Check that the value in the field is not the same as in the Account on file.
        // If it is the same, it should not be added to the Payment Request.
        if (self.accountOnFile != nil && [[self.accountOnFile.attributes valueForField:key] isEqualToString:unmaskedValues[key]]) {
            continue;
        }
        NSString *value = unmaskedValues[key];
        [paymentRequest setValue:value forField:key];
    }

    return paymentRequest;
}

- (void)setValue:(NSString *)value forField:(NSString *)paymentProductFieldId {
    [self.fieldValues setObject:value forKey:paymentProductFieldId];
}

- (NSString *)valueForField:(NSString *)paymentProductFieldId {
    NSString *value = [self.fieldValues objectForKey:paymentProductFieldId];
    if (value == nil) {
        value = @"";
    }
    return value;
}

- (NSString *)maskedValueForField:(NSString *)paymentProductFieldId {
    NSInteger cursorPosition = 0;
    return [self maskedValueForField:paymentProductFieldId cursorPosition:&cursorPosition];
}

- (NSString *)maskedValueForField:(NSString *)paymentProductFieldId cursorPosition:(NSInteger *)cursorPosition {
    NSString *value = [self valueForField:paymentProductFieldId];
    NSString *mask = [self maskForField:paymentProductFieldId];
    if (mask == nil) {
        return value;
    } else {
        return [self.formatter formatString:value withMask:mask cursorPosition:cursorPosition];
    }
}

- (NSString *)unmaskedValueForField:(NSString *)paymentProductFieldId {
    NSString *value = [self valueForField:paymentProductFieldId];
    NSString *mask = [self maskForField:paymentProductFieldId];
    if (mask == nil) {
        return value;
    } else {
        NSString *unformattedString = [self.formatter unformatString:value withMask:mask];
        return unformattedString;
    }
}

- (BOOL)fieldIsPartOfAccountOnFile:(NSString *)paymentProductFieldId {
    return [self.accountOnFile hasValueForField:paymentProductFieldId];
}

- (BOOL)fieldIsReadOnly:(NSString *)paymentProductFieldId {
    if ([self fieldIsPartOfAccountOnFile:paymentProductFieldId] == NO) {
        return NO;
    } else {
        return [self.accountOnFile fieldIsReadOnly:paymentProductFieldId];
    }
}

- (void)removeAllFieldValues {
    [self.fieldValues removeAllObjects];
}

- (NSString *)maskForField:(NSString *)paymentProductFieldId {
    ICPaymentProductField *field = [self.paymentItem paymentProductFieldWithId:paymentProductFieldId];
    NSString *mask = field.displayHints.mask;
    return mask;
}

- (NSDictionary *)unmaskedFieldValues {
    NSMutableDictionary *unmaskedFieldValues = [@{} mutableCopy];
    for (ICPaymentProductField *field in self.paymentItem.fields.paymentProductFields) {
        NSString *fieldId = field.identifier;
        if ([self fieldIsReadOnly:fieldId] == NO) {
            NSString *unmaskedValue = [self unmaskedValueForField:fieldId];
            [unmaskedFieldValues setObject:unmaskedValue forKey:fieldId];
        }
    }
    return unmaskedFieldValues;
}

- (void)validateExceptFields:(NSSet *)exceptionFields
{
    [self.errors removeAllObjects];
    ICPaymentRequest *request = self.paymentRequest;
    for (ICPaymentProductField *field in self.paymentItem.fields.paymentProductFields) {
        if (![self fieldIsPartOfAccountOnFile:field.identifier]) {
            if ([[self unmaskedValueForField:field.identifier] isEqualToString:@""]) {
                BOOL hasFixedValidator = NO;
                for (ICValidator *validator in field.dataRestrictions.validators.validators) {
                    if ([validator isKindOfClass:[ICValidatorFixedList class]]) {
                        // It's not possible to choose an empty string with a picker
                        // Except if it is on the accountOnFile
                        hasFixedValidator = true;
                        ICValidatorFixedList *fixedListValidator = (ICValidatorFixedList *) validator;
                        NSString *value = fixedListValidator.allowedValues[0];
                        [self setValue:value forField:field.identifier];
                    }
                }
                // It's not possible to choose an empty string with a date picker
                // If not set, we assume the first is chosen
                // Except if it is on the accountOnFile
                if (!hasFixedValidator && field.type == ICDateString) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMdd";
                    [self setValue: [formatter stringFromDate: [NSDate date]] forField: field.identifier];
                }
                // It's not possible to choose an empty boolean with a switch
                // If not set, we assume false is chosen
                // Except if it is on the accountOnFile
                if (!hasFixedValidator && field.type == ICBooleanString) {
                    [self setValue: @"false" forField: field.identifier];
                }
            }
            if ([exceptionFields containsObject:field.identifier]) {
                continue;
            }
            NSString *fieldValue = [self unmaskedValueForField:field.identifier];
            [field validateValue:fieldValue forPaymentRequest:request];
            [self.errors addObjectsFromArray:field.errors];
            
        }
    }
}

- (void)validate
{
    [self validateExceptFields:[NSSet set]];
}

@end
