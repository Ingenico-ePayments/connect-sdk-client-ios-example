//
//  ICTableSectionConverterTestCase.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ICBasicPaymentProducts.h"
#import "ICBasicPaymentProductsConverter.h"
#import "ICPaymentProductsTableSection.h"
#import "ICPaymentProductsTableRow.h"
#import "ICTableSectionConverter.h"
#import "ICStringFormatter.h"
#import "ICAccountOnFile.h"

@interface ICTableSectionConverterTestCase : XCTestCase

@property (strong, nonatomic) ICBasicPaymentProductsConverter *paymentProductsConverter;
@property (strong, nonatomic) ICStringFormatter *stringFormatter;

@end

@implementation ICTableSectionConverterTestCase

- (void)setUp
{
    [super setUp];
    self.paymentProductsConverter = [[ICBasicPaymentProductsConverter alloc] init];
    self.stringFormatter = [[ICStringFormatter alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testPaymentProductsTableSectionFromAccountsOnFile
{
    NSString *paymentProductsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"paymentProducts" ofType:@"json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *paymentProductsData = [fileManager contentsAtPath:paymentProductsPath];
    NSDictionary *paymentProductsJSON = [NSJSONSerialization JSONObjectWithData:paymentProductsData options:0 error:NULL];
    ICBasicPaymentProducts *paymentProducts = [self.paymentProductsConverter paymentProductsFromJSON:[paymentProductsJSON objectForKey:@"paymentProducts"]];
    NSArray *accountsOnFile = [paymentProducts accountsOnFile];
    for (ICAccountOnFile *accountOnFile in accountsOnFile) {
        accountOnFile.stringFormatter = self.stringFormatter;
    }
    ICPaymentProductsTableSection *tableSection = [ICTableSectionConverter paymentProductsTableSectionFromAccountsOnFile:accountsOnFile paymentProducts:paymentProducts];
    ICPaymentProductsTableRow *row = tableSection.rows[0];
    XCTAssertTrue([row.name isEqualToString:@"**** **** **** 7988 Rob"] == YES, @"Unexpected title of table section");
}

@end
