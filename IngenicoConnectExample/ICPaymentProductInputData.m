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

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.formatter = [[ICStringFormatter alloc] init];
        self.fieldValues = [[NSMutableDictionary alloc] init];
        self.errors = [NSMutableArray new];
    }
    return self;
}

- (ICPaymentRequest *)paymentRequest {
    ICPaymentRequest *paymentRequest = [ICPaymentRequest new];

    if ([self.paymentItem isKindOfClass:[ICPaymentProduct class]]) {
        paymentRequest.paymentProduct = (ICPaymentProduct *) self.paymentItem;
    }
    else {
        paymentRequest.paymentProduct = [ICPaymentProduct new];
    }

    paymentRequest.accountOnFile = self.accountOnFile;
    paymentRequest.tokenize = self.tokenize;
    for (NSString *key in self.fieldValues.allKeys) {
        NSString *value = self.fieldValues[key];
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
        ICPaymentProductField *field = [self.paymentItem paymentProductFieldWithId:paymentProductFieldId];
        for (ICValidator *validator in field.dataRestrictions.validators.validators) {
            if ([validator class] == [ICValidatorFixedList class]) {
                ICValidatorFixedList *fixedListValidator = (ICValidatorFixedList *) validator;
                value = fixedListValidator.allowedValues[0];
                [self setValue:value forField:paymentProductFieldId];
            }
        }
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

- (void)setAccountOnFile:(ICAccountOnFile *)accountOnFile {
    _accountOnFile = accountOnFile;
    for (ICAccountOnFileAttribute *attribute in accountOnFile.attributes.attributes) {
        [self.fieldValues setObject:attribute.value forKey:attribute.key];
    }
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

- (void)validate
{
    [self.errors removeAllObjects];
    for (ICPaymentProductField *field in self.paymentItem.fields.paymentProductFields) {
        if ([self fieldIsPartOfAccountOnFile:field.identifier] == NO) {
            NSString *fieldValue = [self unmaskedValueForField:field.identifier];
            [field validateValue:fieldValue];
            [self.errors addObjectsFromArray:field.errors];
        }
    }
}

@end
