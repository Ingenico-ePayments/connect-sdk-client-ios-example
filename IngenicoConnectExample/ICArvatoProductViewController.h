//
//  ICArvatoProductViewController.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 19/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICPaymentProductViewController.h"
@interface ICArvatoProductViewController : ICPaymentProductViewController <UIPickerViewDelegate, UIPickerViewDataSource>
- (instancetype)initWithPaymentItem:(NSObject<ICPaymentItem> *)paymentItem Session:(ICSession *)session context:(ICPaymentContext *)context viewFactory:(ICViewFactory *)viewFactory accountOnFile:(ICAccountOnFile *)accountsOnFile;
@end
