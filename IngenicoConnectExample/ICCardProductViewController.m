//
//  ICCardProductViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 18/05/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICCardProductViewController.h"
#import "ICFormRowTextField.h"
#import "ICFormRowCoBrandsExplanation.h"
#import "ICPaymentProductsTableRow.h"
#import "ICFormRowCoBrandsSelection.h"
#import "ICPaymentProductGroup.h"
#import "ICPaymentProductInputData.h"
#import "ICIINDetail.h"
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import <IngenicoConnectSDK/ICAssetManager.h>

@interface ICCardProductViewController ()
@property (nonatomic, strong) UITextPosition *cursorPositionInCreditCardNumberTextField;
@property (nonatomic, strong) ICIINDetailsResponse *iinDetailsResponse;
@property (strong, nonatomic) NSBundle *sdkBundle;
@property (strong, nonatomic) NSArray<ICIINDetail *> *cobrands;
@end

@implementation ICCardProductViewController


- (void)viewDidLoad {
    self.sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];
    [super viewDidLoad];
    
}

- (void)registerReuseIdentifiers {
    [super registerReuseIdentifiers];
    [self.tableView registerClass:[ICCoBrandsSelectionTableViewCell class] forCellReuseIdentifier:ICCoBrandsSelectionTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[ICCOBrandsExplanationTableViewCell class] forCellReuseIdentifier:ICCOBrandsExplanationTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[ICPaymentProductTableViewCell class] forCellReuseIdentifier:ICPaymentProductTableViewCell.reuseIdentifier];
}
- (void) updateTextFieldCell:(ICTextFieldTableViewCell *)cell row: (ICFormRowTextField *)row {
    [super updateTextFieldCell:cell row:row];
    if ([row.paymentProductField.identifier isEqualToString:@"cardNumber"]) {
        if([self.confirmedPaymentProducts containsObject:self.paymentItem.identifier]) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            row.logo = self.paymentItem.displayHints.logoImage;
            imageView.image = row.logo;
            cell.rightView = imageView;
        }
        else {
            row.logo = nil;
            cell.rightView = [[UIView alloc]init];
        }
    }
}
-(ICTextFieldTableViewCell *)cellForTextField:(ICFormRowTextField *)row tableView:(UITableView *)tableView {
    ICTextFieldTableViewCell *cell = [super cellForTextField:row tableView:tableView];
    
    if ([row.paymentProductField.identifier isEqualToString:@"cardNumber"]) {
        if([self.confirmedPaymentProducts containsObject:self.paymentItem.identifier]) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = row.logo;
            cell.rightView = imageView;
        }

    }
    return cell;
}
- (ICCoBrandsSelectionTableViewCell *)cellForCoBrandsSelection:(ICFormRowCoBrandsSelection *)row tableView:(UITableView *)tableView {
    return [tableView dequeueReusableCellWithIdentifier:ICCoBrandsSelectionTableViewCell.reuseIdentifier];
}

- (ICCOBrandsExplanationTableViewCell *)cellForCoBrandsExplanation:(ICFormRowCoBrandsExplanation *)row tableView:(UITableView *)tableView {
    return [tableView dequeueReusableCellWithIdentifier:ICCOBrandsExplanationTableViewCell.reuseIdentifier];
}

- (ICPaymentProductTableViewCell *)cellForPaymentProduct:(ICPaymentProductsTableRow *)row tableView:(UITableView *)tableView {
    ICPaymentProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ICPaymentProductTableViewCell.reuseIdentifier];
    
    cell.name = row.name;
    cell.logo = row.logo;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.shouldHaveMaximalWidth = YES;
    cell.limitedBackgroundColor = [UIColor colorWithWhite: 0.9 alpha: 1];
    [cell setNeedsLayout];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    ICFormRow *row = [self.formRows objectAtIndex:indexPath.row];
    if ([row isKindOfClass:[ICPaymentProductsTableRow class]] && ((ICPaymentProductsTableRow *)row).paymentProductIdentifier != self.paymentItem.identifier) {
        [self switchToPaymentProduct:((ICPaymentProductsTableRow *)row).paymentProductIdentifier];
        return;
    }
    if ([row isKindOfClass:[ICFormRowCoBrandsSelection class]] || [row isKindOfClass:[ICPaymentProductsTableRow class]]) {
        for (ICFormRow *cell in self.formRows) {
            if ([cell isKindOfClass:[ICFormRowCoBrandsExplanation class]] || [cell isKindOfClass:[ICPaymentProductsTableRow class]]) {
                cell.isEnabled = !cell.isEnabled;
            }
        }
        [self updateFormRows];
    }
}

-(void)formatAndUpdateCharactersFromTextField:(UITextField *)texField cursorPosition:(NSInteger *)position indexPath:(NSIndexPath *)indexPath {
    [super formatAndUpdateCharactersFromTextField:texField cursorPosition:position indexPath:indexPath];
    ICFormRowTextField *row = [self.formRows objectAtIndex:indexPath.row];
    if ([row.paymentProductField.identifier isEqualToString:@"cardNumber"]) {
        NSString *unmasked = [self.inputData unmaskedValueForField:row.paymentProductField.identifier];
        if (unmasked.length >= 6 && *position <= 7) {
            unmasked = [unmasked substringToIndex:6];
            
            [self.session IINDetailsForPartialCreditCardNumber:unmasked context:self.context success:^(ICIINDetailsResponse *response) {
                self.iinDetailsResponse = response;
                if ([self.inputData unmaskedValueForField:row.paymentProductField.identifier].length < 6) {
                    return;
                }
                self.cobrands = response.coBrands;

                if (response.status == ICSupported) {
                    BOOL coBrandSelected = NO;
                    for (ICIINDetail *coBrand in response.coBrands) {
                        if ([coBrand.paymentProductId isEqualToString:self.paymentItem.identifier]) {
                            coBrandSelected = YES;
                        }
                    }
                    if (coBrandSelected == NO) {
                        [self switchToPaymentProduct:response.paymentProductId];
                    }
                    else {
                        [self switchToPaymentProduct:self.paymentItem.identifier];
                    }
                }
                else {
                    [self switchToPaymentProduct:self.initialPaymentProduct == nil ? nil : self.initialPaymentProduct.identifier];
                }
            } failure:^(NSError *error) {
                
            }];
        }
    }

}
-(void)initializeFormRows {
    [super initializeFormRows];
    NSArray<ICFormRow *> *newFormRows = [self coBrandFormsWithIINDetailsResponse:self.cobrands];
    [self.formRows insertObjects:newFormRows atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, newFormRows.count)]];
}

-(void)updateFormRows {
    if ([self switching]) {
        // We need to update the tableView to the new amount of rows. However, we cannot use tableView.reloadData(), because then
        // the current textfield losses focus. We also should not reload the cardNumber row with tableView.reloadRows([indexOfCardNumber, with: ...)
        // because that also makes the textfield lose focus.
        
        // Because the cardNumber field might move, we cannot just insert/delete the difference in rows in general, because if we
        // do, the index of the cardNumber field might change, and we cannot reload the new place.
        
        // So instead, we check the difference in rows before the cardNumber field between before the mutation and after the mutation,
        // and the difference in rows after the cardNumber field between before and after the mutations
        
        [self.tableView beginUpdates];
        NSArray<ICFormRow *> *oldFormRows = self.formRows;
        [self initializeFormRows];
        
        NSInteger oldCardNumberIndex = 0;
        for (ICFormRow *fr in oldFormRows) {
            if ([fr isKindOfClass:[ICFormRowTextField class]]) {
                if ([((ICFormRowTextField *)fr).paymentProductField.identifier isEqualToString:@"cardNumber"]) {
                    break;
                }
            }
            oldCardNumberIndex += 1;
        }
        NSInteger newCardNumberIndex = 0;
        for (ICFormRow *fr in self.formRows) {
            if ([fr isKindOfClass:[ICFormRowTextField class]]) {
                if ([((ICFormRowTextField *)fr).paymentProductField.identifier isEqualToString:@"cardNumber"]) {
                    break;
                }
            }
            newCardNumberIndex += 1;
        }
        if (newCardNumberIndex >= self.formRows.count) {
            newCardNumberIndex = 0;
        }
        if (oldCardNumberIndex >= self.formRows.count) {
            oldCardNumberIndex = 0;
        }
        NSInteger diffCardNumberIndex = newCardNumberIndex - oldCardNumberIndex;
        if (diffCardNumberIndex >= 0) {
            NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:diffCardNumberIndex];
            NSMutableArray *updateIndexPaths = [NSMutableArray arrayWithCapacity:oldCardNumberIndex];
            for (NSInteger i = 0; i < diffCardNumberIndex; i+=1) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:oldCardNumberIndex - 1 + i inSection:0]];
            }
            for (NSInteger i = 0; i < oldCardNumberIndex; i+=1) {
                [updateIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (diffCardNumberIndex < 0) {
            NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:-diffCardNumberIndex];
            NSMutableArray *updateIndexPaths = [NSMutableArray arrayWithCapacity:oldCardNumberIndex];
            for (NSInteger i = 0; i < -diffCardNumberIndex; i+=1) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            for (NSInteger i = 0; i < oldCardNumberIndex + diffCardNumberIndex; i+=1) {
                [updateIndexPaths addObject:[NSIndexPath indexPathForRow:oldCardNumberIndex - i inSection:0]];
            }
            
            [self.tableView deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        NSInteger oldAfterCardNumberCount = oldFormRows.count - oldCardNumberIndex - 1;
        NSInteger newAfterCardNumberCount = self.formRows.count - newCardNumberIndex - 1;
        
        NSInteger diffAfterCardNumberCount = newAfterCardNumberCount - oldAfterCardNumberCount;
        
        // We cannot not update the cardname field if it doesn't exist
        if (newAfterCardNumberCount < 0) {
            newAfterCardNumberCount = 0;
        }
        if (diffAfterCardNumberCount >= 0) {
            NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:diffAfterCardNumberCount];
            NSMutableArray *updateIndexPaths = [NSMutableArray arrayWithCapacity:oldAfterCardNumberCount];
            for (NSInteger i = 0; i < diffAfterCardNumberCount; i+=1) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:oldFormRows.count + i inSection:0]];
            }
            for (NSInteger i = 0; i < oldAfterCardNumberCount; i+=1) {
                [updateIndexPaths addObject:[NSIndexPath indexPathForRow:i + oldCardNumberIndex + 1 inSection:0]];
            }
            
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (diffAfterCardNumberCount < 0) {
            NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:-diffAfterCardNumberCount];
            NSMutableArray *updateIndexPaths = [NSMutableArray arrayWithCapacity:newAfterCardNumberCount];
            for (NSInteger i = 0; i < -diffAfterCardNumberCount; i+=1) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:oldFormRows.count - i - 1 inSection:0]];
            }
            for (NSInteger i = 0; i < newAfterCardNumberCount; i+=1) {
                [updateIndexPaths addObject:[NSIndexPath indexPathForRow:self.formRows.count - i - 1 - diffCardNumberIndex inSection:0]];
            }
            
            [self.tableView deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.tableView endUpdates];
    }
    [super updateFormRows];
}
-(NSArray *)coBrandFormsWithIINDetailsResponse: (NSArray<ICIINDetail *> *)inputBrands{
    NSMutableArray *coBrands = [[NSMutableArray alloc] init];
    for (ICIINDetail *coBrand in inputBrands) {
        if (coBrand.allowedInContext) {
            [coBrands addObject:coBrand.paymentProductId];
        }
    }
    NSMutableArray *formRows = [[NSMutableArray alloc] init];
    
    if (coBrands.count > 1) {
        // Add explanaton row
        ICFormRowCoBrandsExplanation *explanationRow = [[ICFormRowCoBrandsExplanation alloc]init];
        [formRows addObject:explanationRow];
        
        for (NSString *identifier in coBrands) {
            ICPaymentProductsTableRow *row = [[ICPaymentProductsTableRow alloc]init];
            row.paymentProductIdentifier = identifier;
            
            NSString *paymentProductKey = [NSString stringWithFormat:@"gc.general.paymentProducts.%@.name", identifier];
            NSString *paymentProductValue = NSLocalizedStringFromTableInBundle(paymentProductKey, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], "");
            row.name = paymentProductValue;
            
            ICAssetManager *assetManager = [[ICAssetManager alloc]init];
            UIImage *logo = [assetManager logoImageForPaymentItem:identifier];
            [row setLogo:logo];
            
            [formRows addObject:row];
        }
        ICFormRowCoBrandsSelection *toggleCoBrandRow = [[ICFormRowCoBrandsSelection alloc]init];
        [formRows addObject:toggleCoBrandRow];
    }
    
    return formRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ICFormRow *row = [self.formRows objectAtIndex:[indexPath row]];
    if (([row isKindOfClass:[ICFormRowCoBrandsExplanation class]] || [row isKindOfClass:[ICPaymentProductsTableRow class]]) && ![row isEnabled]) {
        return 0;
    }
    else if ([row isKindOfClass:[ICFormRowCoBrandsExplanation class]]) {
        NSAttributedString *cellString = ICCOBrandsExplanationTableViewCell.cellString;
        CGRect rect = [cellString boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return rect.size.height + 20;
    }
    else if ([row isKindOfClass:[ICFormRowCoBrandsSelection class]]) {
        return 30;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
