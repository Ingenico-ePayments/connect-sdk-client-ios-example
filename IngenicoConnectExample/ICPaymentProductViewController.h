//
//  ICPaymentProductViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <IngenicoConnectExample/ICViewFactory.h>
#import <IngenicoConnectSDK/ICPaymentProduct.h>
#import <IngenicoConnectSDK/ICAccountOnFile.h>
#import <IngenicoConnectExample/ICPaymentRequestTarget.h>
#import <IngenicoConnectSDK/ICSession.h>
#import <IngenicoConnectExample/ICCoBrandsSelectionTableViewCell.h>
#import "ICFormRowTextField.h"
#import "ICPaymentProductInputData.h"
@interface ICPaymentProductViewController : UITableViewController

@property (weak, nonatomic) id <ICPaymentRequestTarget> paymentRequestTarget;
@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (nonatomic) NSObject<ICPaymentItem> *paymentItem;
@property (strong, nonatomic) ICPaymentProduct *initialPaymentProduct;
@property (strong, nonatomic) ICAccountOnFile *accountOnFile;
@property (strong, nonatomic) ICPaymentContext *context;
@property (nonatomic) NSUInteger amount;
@property (strong, nonatomic) ICSession *session;
@property (strong, nonatomic) NSMutableSet *confirmedPaymentProducts;
@property (strong, nonatomic) NSMutableArray *formRows;
@property (strong, nonatomic) ICPaymentProductInputData *inputData;
@property (nonatomic) BOOL switching;
- (void) registerReuseIdentifiers;
- (void) updateTextFieldCell:(ICTextFieldTableViewCell *)cell row: (ICFormRowTextField *)row;
- (ICTextFieldTableViewCell *)cellForTextField:(ICFormRowTextField *)row tableView:(UITableView *)tableView;
- (ICTableViewCell *)formRowCellForRow:(ICFormRow *)row atIndexPath:(NSIndexPath *)indexPath;
-(void)switchToPaymentProduct:(NSString *)paymentProductId;
-(void)updateFormRows;
-(void)formatAndUpdateCharactersFromTextField:(UITextField *)texField cursorPosition:(NSInteger *)position indexPath:(NSIndexPath *)indexPath;
- (void)initializeFormRows;
@end
