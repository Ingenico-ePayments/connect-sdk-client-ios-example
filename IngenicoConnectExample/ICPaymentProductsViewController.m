//
//  ICPaymentProductsViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICAppConstants.h>
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectExample/ICPaymentProductsViewController.h>
#import <IngenicoConnectExample/ICPaymentProductTableViewCell.h>
#import <IngenicoConnectExample/ICPaymentProductsTableSection.h>
#import <IngenicoConnectExample/ICPaymentProductsTableRow.h>
#import <IngenicoConnectExample/ICTableSectionConverter.h>
#import <IngenicoConnectExample/ICSummaryTableHeaderView.h>
#import <IngenicoConnectSDK/ICPaymentItems.h>
#import <IngenicoConnectExample/ICMerchantLogoImageView.h>

@interface ICPaymentProductsViewController ()

@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) ICSummaryTableHeaderView *header;
@property (strong, nonatomic) NSBundle *sdkBundle;

@end

@implementation ICPaymentProductsViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.titleView = [[ICMerchantLogoImageView alloc] init];
    
    [self initializeHeader];
    
    self.sections = [[NSMutableArray alloc] init];
    //TODO: Accounts on file
    if ([self.paymentItems hasAccountsOnFile] == YES) {
        ICPaymentProductsTableSection *accountsSection =
        [ICTableSectionConverter paymentProductsTableSectionFromAccountsOnFile:[self.paymentItems accountsOnFile] paymentItems:self.paymentItems];
        accountsSection.title = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductSelection.accountsOnFileTitle", kICSDKLocalizable, self.sdkBundle, @"Title of the section that displays stored payment products.");
        [self.sections addObject:accountsSection];
    }
    ICPaymentProductsTableSection *productsSection = [ICTableSectionConverter paymentProductsTableSectionFromPaymentItems:self.paymentItems];
    productsSection.title = NSLocalizedStringFromTableInBundle(@"gc.app.paymentProductSelection.pageTitle", kICSDKLocalizable, self.sdkBundle, @"Title of the section that shows all available payment products.");
    [self.sections addObject:productsSection];
}

- (void)initializeHeader
{
    self.header = (ICSummaryTableHeaderView *)[self.viewFactory tableHeaderViewWithType:ICSummaryTableHeaderViewType frame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
    self.header.summary = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTableInBundle(@"gc.app.general.shoppingCart.total", kICSDKLocalizable, self.sdkBundle, @"Description of the amount header.")];
    NSNumber *amountAsNumber = [[NSNumber alloc] initWithFloat:self.amount / 100.0];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencyCode:self.currencyCode];
    NSString *amountAsString = [numberFormatter stringFromNumber:amountAsNumber];
    self.header.amount = amountAsString;
    self.header.securePayment = NSLocalizedStringFromTableInBundle(@"gc.app.general.securePaymentText", kICSDKLocalizable, self.sdkBundle, @"Text indicating that a secure payment method is used.");
    self.tableView.tableHeaderView = self.header;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ICPaymentProductsTableSection *tableSection = self.sections[section];
    return tableSection.rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ICPaymentProductsTableSection *tableSection = self.sections[section];
    return tableSection.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cell";
    ICPaymentProductTableViewCell *cell = (ICPaymentProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = (ICPaymentProductTableViewCell *)[self.viewFactory tableViewCellWithType:ICPaymentProductTableViewCellType reuseIdentifier:reuseIdentifier];
    }
    
    ICPaymentProductsTableSection *section = self.sections[indexPath.section];
    ICPaymentProductsTableRow *row = section.rows[indexPath.row];
    cell.name = row.name;
    cell.logo = row.logo;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICPaymentProductsTableSection *section = self.sections[indexPath.section];
    ICPaymentProductsTableRow *row = section.rows[indexPath.row];
    NSObject<ICBasicPaymentItem> *paymentItem = [self.paymentItems paymentItemWithIdentifier:row.paymentProductIdentifier];
    if (section.type == ICAccountOnFileType) {
        ICBasicPaymentProduct *product = (ICBasicPaymentProduct *) paymentItem;
        ICAccountOnFile *accountOnFile = [product accountOnFileWithIdentifier:row.accountOnFileIdentifier];
        [self.target didSelectPaymentItem:product accountOnFile:accountOnFile];
    }
    else {
        [self.target didSelectPaymentItem:paymentItem accountOnFile:nil];
    }
}

@end
