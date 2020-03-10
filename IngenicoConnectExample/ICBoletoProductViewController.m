//
//  ICBoletoProductViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 01/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICBoletoProductViewController.h"
#import "ICFormRowLabel.h"
#import <ICValidatorBoletoBancarioRequiredness.h>
typedef enum {
    ICFiscalNumberTypePersonal,
    ICFiscalNumberTypeCompany
} ICFiscalNumberType;

@interface ICBoletoProductViewController ()
@property ICFiscalNumberType fiscalNumberType;
@property NSUInteger switchLength;
-(ICValidatorBoletoBancarioRequiredness *)firstBoletoBancarioRequirednessValidatorForFieldRow:(ICFormRowTextField *)row;
@end

@implementation ICBoletoProductViewController
-(instancetype)init
{
    if ((self = [super init]))
    {
        self.fiscalNumberType = ICFiscalNumberTypePersonal;
        self.switchLength = 14;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (ICFormRow *row in self.formRows) {
        if ([row isKindOfClass:[ICFormRowTextField class]]) {
            ICFormRowTextField *fieldRow = (ICFormRowTextField *)row;
            ICValidatorBoletoBancarioRequiredness *validator = [self firstBoletoBancarioRequirednessValidatorForFieldRow:fieldRow];
            if (validator != nil) {
                if (validator.fiscalNumberLength < self.switchLength) {
                    row.isEnabled = self.fiscalNumberType == ICFiscalNumberTypePersonal;
                }
                else {
                    row.isEnabled = self.fiscalNumberType == ICFiscalNumberTypeCompany;
                }
            }

        }
    }
}
-(ICValidatorBoletoBancarioRequiredness *)firstBoletoBancarioRequirednessValidatorForFieldRow:(ICFormRowTextField *)row {
    return [row.paymentProductField.dataRestrictions.validators.validators filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<NSObject>  _Nullable validator, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [validator isKindOfClass:[ICValidatorBoletoBancarioRequiredness class]];
    }]].firstObject;
}
-(void)formatAndUpdateCharactersFromTextField:(UITextField *)textField cursorPosition:(NSInteger *)position indexPath:(NSIndexPath *)indexPath
{
    [super formatAndUpdateCharactersFromTextField:textField cursorPosition:position indexPath:indexPath];
    ICFormRow *row = [self.formRows objectAtIndex:indexPath.row];
    if ([row isKindOfClass:[ICFormRowTextField class]]) {
        ICFormRowTextField *textRow = (ICFormRowTextField *)row;
        if ([[[textRow paymentProductField] identifier]isEqualToString:@"fiscalNumber"])
        {
            switch (self.fiscalNumberType) {
                case ICFiscalNumberTypePersonal:
                    if (textRow.field.text.length >= self.switchLength) {
                        self.fiscalNumberType = ICFiscalNumberTypeCompany;
                        [self updateFormRows];
                    }
                    break;
                case ICFiscalNumberTypeCompany:
                    if (textRow.field.text.length < self.switchLength) {
                        self.fiscalNumberType = ICFiscalNumberTypePersonal;
                        [self updateFormRows];
                    }

                default:
                    break;
            }
        }
    }
}

-(void)updateTextFieldCell:(ICTextFieldTableViewCell *)cell row:(ICFormRowTextField *)row {
    [super updateTextFieldCell:cell row:row];
    ICValidatorBoletoBancarioRequiredness *validator = [self firstBoletoBancarioRequirednessValidatorForFieldRow: row];
    if (validator != nil) {
        if (validator.fiscalNumberLength < self.switchLength) {
            row.isEnabled = self.fiscalNumberType == ICFiscalNumberTypePersonal;
            cell.readonly = !row.isEnabled;
        } else {
            row.isEnabled = self.fiscalNumberType == ICFiscalNumberTypeCompany;
            cell.readonly = !row.isEnabled;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICFormRow *row = [self.formRows objectAtIndex:indexPath.row];
    BOOL isTextField = [row isKindOfClass:[ICFormRowTextField class]];
    BOOL isLabel = [row isKindOfClass:[ICFormRowLabel class]];
    BOOL indexPathExists = indexPath.row + 1 < self.formRows.count;
    BOOL hasValidatorAbove = NO;
    BOOL isTextFieldAbove = NO;
    BOOL aboveNotEnabled = NO;
    if (indexPathExists)
    {
        isTextFieldAbove = [[self.formRows objectAtIndex:indexPath.row  + 1] isKindOfClass:[ICFormRowTextField class]];
        if (isTextFieldAbove) {
            hasValidatorAbove = [self firstBoletoBancarioRequirednessValidatorForFieldRow:[self.formRows objectAtIndex:indexPath.row + 1]] != nil;
        }
        aboveNotEnabled = ![[self.formRows objectAtIndex:indexPath.row  + 1] isEnabled];

    }
    BOOL hasValidator = false;
    if (isTextField){
        hasValidator = [self firstBoletoBancarioRequirednessValidatorForFieldRow:(ICFormRowTextField *)row] != nil;
    }
    BOOL notEnabled = ![row isEnabled];
    if (isTextField && hasValidator && notEnabled) {
        return 0;
    }
    else if (isLabel && indexPathExists && isTextFieldAbove && hasValidatorAbove && aboveNotEnabled) {
        return 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
