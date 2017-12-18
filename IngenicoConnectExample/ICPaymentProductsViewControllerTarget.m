//
//  ICPaymentProductSelectionDelegate.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <IngenicoConnectExample/ICPaymentProductsViewControllerTarget.h>
#import <IngenicoConnectSDK/ICPaymentProduct.h>
#import <IngenicoConnectSDK/ICPaymentProductGroup.h>
#import <IngenicoConnectSDK/ICBasicPaymentProductGroup.h>
#import <IngenicoConnectSDK/ICBasicPaymentProductGroups.h>
#import <IngenicoConnectExample/ICEndViewController.h>
#import <IngenicoConnectSDK/ICPaymentContext.h>
#import <IngenicoConnectSDK/ICPaymentAmountOfMoney.h>
#import "ICCardProductViewController.h"
#import "ICBoletoProductViewController.h"
#import <ICPaymentProductGroup.h>
#import "ICBancontactProductViewController.h"
#import "ICArvatoProductViewController.h"
@interface ICPaymentProductsViewControllerTarget ()

@property (strong, nonatomic) ICSession *session;
@property (strong, nonatomic) ICPaymentContext *context;
@property (weak, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) ICViewFactory *viewFactory;
@property (strong, nonatomic) ICPaymentProduct *applePayPaymentProduct;
@property (strong, nonatomic) NSArray *summaryItems;
@property (strong, nonatomic) PKPaymentAuthorizationViewController * authorizationViewController;
@property (strong, nonatomic) NSBundle *sdkBundle;

@end

@implementation ICPaymentProductsViewControllerTarget


- (instancetype)initWithNavigationController:(UINavigationController *)navigationController session:(ICSession *)session context:(ICPaymentContext *)context viewFactory:(ICViewFactory *)viewFactory {
    self = [super init];
    self.navigationController = navigationController;
    self.session = session;
    self.context = context;
    self.viewFactory = viewFactory;
    self.sdkBundle = [NSBundle bundleWithPath:kICSDKBundlePath];

    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class ICPaymentProductsViewControllerTarget"
                                 userInfo:nil];
    return nil;
}
-(void)bancontactJSONWithSuccess: (void (^) (NSDictionary<NSString *, NSObject *> *))success failure: (void (^) (NSError *)) failure{
    // *******************************************************************************
    //
    // To be able to show the Bancontact QR-Code and/or "open Bancontact app"-button,
    // a payment has to be created first. Create this payment with the S2S API from
    // your payment server.
    //
    // The PaymentResponse will contain QR-Code and button render information, which
    // you should send back to the app.
    //
    // As this is merely an example app, we create a payment response JSON here that
    // is similar to the payment response that you can expect to receive after having
    // created the payment via the server API.
    //
    // *******************************************************************************
    NSDictionary<NSString *, NSObject *> *json =
    @{
      @"creationOutput" : @{ },
      @"merchantAction" : @{
              @"actionType" : @"SHOW_FORM",
              @"formFields" :
                  @[
                      @{
                          @"dataRestrictions" : @{
                                  @"isRequired" : @YES,
                                  @"validators" : @{
                                          @"length" : @{
                                                  @"maxLength" : @19,
                                                  @"minLength" : @16
                                                  },
                                          @"luhn" : @{},
                                          @"regularExpression" : @{
                                                  @"regularExpression" : @"^[0-9]*$"
                                                  }
                                          }
                                  },
                          @"displayHints" : @{
                                  @"alwaysShow" : @NO,
                                  @"displayOrder" : @0,
                                  @"formElement" : @{ @"type" : @"text" },
                                  @"label" : @"Card number",
                                  @"mask" : @"{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                                  @"obfuscate" : @NO,
                                  @"placeholderLabel" : @"**** **** **** ****",
                                  @"preferredInputType" : @"IntegerKeyboard"
                                  },
                          @"id" : @"cardNumber",
                          @"type" : @"numericstring"
                          },
                      @{
                          @"dataRestrictions" : @{
                                  @"isRequired" : @YES,
                                  @"validators" : @{
                                          @"length" : @{
                                                  @"maxLength" : @35,
                                                  @"minLength" : @0
                                                  },
                                          @"regularExpression" : @{
                                                  @"regularExpression" : @"^[a-zA-ZàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßŠšŽžŸÿęĘ0-9 +_.=,:\\-\\[\\]\\/\\(\\)]*$"
                                                  }
                                          }
                                  },
                          @"displayHints" : @{
                                  @"alwaysShow" : @NO,
                                  @"displayOrder" : @1,
                                  @"formElement" : @{
                                          @"type" : @"text"
                                          },
                                  @"label" : @"Cardholder name",
                                  @"obfuscate" : @NO,
                                  @"placeholderLabel" : @"John Doe",
                                  @"preferredInputType" : @"StringKeyboard"
                                  },
                          @"id" : @"cardholderName",
                          @"type" : @"string"
                          },
                      @{
                          @"dataRestrictions" : @{
                                  @"isRequired" : @YES,
                                  @"validators" : @{
                                          @"expirationDate" : @{ },
                                          @"regularExpression" : @{
                                                  @"regularExpression" : @"^(0[1-9]|1[0-2])\\d\\d$"
                                                  }
                                          }
                                  },
                          @"displayHints" : @{
                                  @"alwaysShow" : @NO,
                                  @"displayOrder" : @2,
                                  @"formElement" : @{
                                          @"type" : @"text"
                                          },
                                  @"label" : @"Expiry date",
                                  @"mask" : @"{{99}}/{{99}}",
                                  @"obfuscate" : @NO,
                                  @"placeholderLabel" : @"MM/YY",
                                  @"preferredInputType" : @"IntegerKeyboard"
                                  },
                          @"id" : @"expiryDate",
                          @"type" : @"expirydate"
                          }
                      ],
              @"redirectData" : @{
                      @"RETURNMAC" : @"d9f0385f-10cf-4d59-adea-d7e20d5e7473"
                      },
              @"renderingData" : @"eyJjcmVhdGVkUGF5bWVudE91dHB1dCI6eyJwYXltZW50Ijp7ImlkIjoiMjczNzg2MF8wIiwic3RhdHVzIjoiUEVORElOR19QQVlNRU5UIn0sIm1lcmNoYW50QWN0aW9uIjp7ImFjdGlvblR5cGUiOiJTSE9XX0ZPUk0iLCJmb3JtRmllbGRzIjpbeyJkYXRhUmVzdHJpY3Rpb25zIjp7ImlzUmVxdWlyZWQiOnRydWUsInZhbGlkYXRvcnMiOnsibGVuZ3RoIjp7Im1heExlbmd0aCI6MTksIm1pbkxlbmd0aCI6MTZ9LCJsdWhuIjp7fSwicmVndWxhckV4cHJlc3Npb24iOnsicmVndWxhckV4cHJlc3Npb24iOiJeWzAtOV0qJCJ9fX0sImRpc3BsYXlIaW50cyI6eyJhbHdheXNTaG93IjpmYWxzZSwiZGlzcGxheU9yZGVyIjowLCJmb3JtRWxlbWVudCI6eyJ0eXBlIjoidGV4dCJ9LCJsYWJlbCI6IkNhcmQgbnVtYmVyIiwibWFzayI6Int7OTk5OX19IHt7OTk5OX19IHt7OTk5OX19IHt7OTk5OX19IHt7OTk5fX0iLCJvYmZ1c2NhdGUiOmZhbHNlLCJwbGFjZWhvbGRlckxhYmVsIjoiKioqKiAqKioqICoqKiogKioqKiIsInByZWZlcnJlZElucHV0VHlwZSI6IkludGVnZXJLZXlib2FyZCJ9LCJpZCI6ImNhcmROdW1iZXIiLCJ0eXBlIjoibnVtZXJpY3N0cmluZyJ9LHsiZGF0YVJlc3RyaWN0aW9ucyI6eyJpc1JlcXVpcmVkIjp0cnVlLCJ2YWxpZGF0b3JzIjp7Imxlbmd0aCI6eyJtYXhMZW5ndGgiOjM1LCJtaW5MZW5ndGgiOjB9LCJyZWd1bGFyRXhwcmVzc2lvbiI6eyJyZWd1bGFyRXhwcmVzc2lvbiI6Il5bYS16QS1aw6DDocOiw6PDpMOlw6bDp8Oow6nDqsOrw6zDrcOuw6/DsMOxw7LDs8O0w7XDtsO4w7nDusO7w7zDvcO+w7/DgMOBw4LDg8OEw4XDhsOHw4jDicOKw4vDjMONw47Dj8OQw5HDksOTw5TDlcOWw5jDmcOaw5vDnMOdw57Dn8WgxaHFvcW+xbjDv8SZxJgwLTkgK18uPSw6XFwtXFxbXFxdXFwvXFwoXFwpXSokIn19fSwiZGlzcGxheUhpbnRzIjp7ImFsd2F5c1Nob3ciOmZhbHNlLCJkaXNwbGF5T3JkZXIiOjEsImZvcm1FbGVtZW50Ijp7InR5cGUiOiJ0ZXh0In0sImxhYmVsIjoiQ2FyZGhvbGRlciBuYW1lIiwib2JmdXNjYXRlIjpmYWxzZSwicGxhY2Vob2xkZXJMYWJlbCI6IkpvaG4gRG9lIiwicHJlZmVycmVkSW5wdXRUeXBlIjoiU3RyaW5nS2V5Ym9hcmQifSwiaWQiOiJjYXJkaG9sZGVyTmFtZSIsInR5cGUiOiJzdHJpbmcifSx7ImRhdGFSZXN0cmljdGlvbnMiOnsiaXNSZXF1aXJlZCI6dHJ1ZSwidmFsaWRhdG9ycyI6eyJleHBpcmF0aW9uRGF0ZSI6e30sInJlZ3VsYXJFeHByZXNzaW9uIjp7InJlZ3VsYXJFeHByZXNzaW9uIjoiXigwWzEtOV18MVswLTJdKVxcZFxcZCQifX19LCJkaXNwbGF5SGludHMiOnsiYWx3YXlzU2hvdyI6ZmFsc2UsImRpc3BsYXlPcmRlciI6MiwiZm9ybUVsZW1lbnQiOnsidHlwZSI6InRleHQifSwibGFiZWwiOiJFeHBpcnkgZGF0ZSIsIm1hc2siOiJ7ezk5fX0ve3s5OX19Iiwib2JmdXNjYXRlIjpmYWxzZSwicGxhY2Vob2xkZXJMYWJlbCI6Ik1NL1lZIiwicHJlZmVycmVkSW5wdXRUeXBlIjoiSW50ZWdlcktleWJvYXJkIn0sImlkIjoiZXhwaXJ5RGF0ZSIsInR5cGUiOiJleHBpcnlkYXRlIn1dLCJyZWRpcmVjdERhdGEiOnsiUkVUVVJOTUFDIjoiZDlmMDM4NWYtMTBjZi00ZDU5LWFkZWEtZDdlMjBkNWU3NDczIn0sInNob3dEYXRhIjpbeyJrZXkiOiJVUkxJTlRFTlQiLCJ2YWx1ZSI6IkJFUEdlbkFwcDovL0RvVHg/VHJhbnNJZD0xZXhhbXBsZS5jb20qUC0yNzM3ODYwJDdPTElGQ0JVUzVUVEhCQTdGTTdZU043QyZDYWxsYmFjaz1odHRwJTNBJTJGJTJGcnBwLmdjLWNpLWRldi5pc2FhYy5sb2NhbCUzQTcwMDMlMkZyZWRpcmVjdG9yJTJGcmV0dXJuJTJGYTBmNDVhZmQtZGQxNi00Yjk5LTkwNzUtYjdjNzZiMjUxMTcxIn0seyJrZXkiOiJRUkNPREUiLCJ2YWx1ZSI6ImlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFNZ0FBQURJQVFBQUFBQ0ZJNU16QUFBQndFbEVRVlI0MnUyWU1hNkRNQkJFQjdtZzVBamNCQzZHaENVdUZtN2lJMUJTSVBiUExDSEpqNVIyK2ZvS1JSVDhVbGk3cytOeFlKOGVmTWxmSnhsQVk4VnV6UWE3SVJXK3AxQXltZTFOaHUxY1hQc2xGZk8xU0ZMUU5jSVlXblFZeTRybUFySzEzTmFBQzBuR1dyRlR4RmNROVdjNldvUGU3SzF6QWNRMVN0S2RINy9WRzBEOG1VcTlxMG5Wa3Q0bU9JRGt0dDR4bXN2RVptOFhYeU1KdjFLZUhKRG12a3ROYkRTQjlnWnZqYXQxaVNVdXlnMm9PQ0R5VGRPb0JCTlhadTJ6TWZNM1QrMkVrZHBZamxwdVNhRk90bmJubEFRUkZvYmlLUFdzdlpsSzFOLzNGa1hvRDVYbTlLWTVsVWx3cTJNc01aN1dvN0JaUGRNeUg5VUpKUE1DK0R2bENiZUxVTEpwRVMzOHpJSUN6UDVRU0F6SjJveWYyMUI2b21lY2N4cEZ0dGI5UVNWcXVaalVwRmhpRW1XaVJsa2l4a2ozNjFpU1FYOWdpZFNwMDdDbVVPS3RHVldkcEVYYTk3TnVNVVFtZ1lIUlRZVmlpVHpLaEJKL3NzUXg0UERyL2pYVkJKQWp2NWt5TE9zazg4UkRJVEhFTXl4UGE1VkZHcFZocFZoU2pqTkxpenk0c2pMRUJlUkliU3JNZ05mOEZrYzBHK1ozV3VoU0YwejhMaU9QSEhCY0l1WXpPUVFSMTJqMkZLMnJIR1A5bVJ5aXlQZGZuSDlHZmdDZGJCRGpxS0lUOHdBQUFBQkpSVTVFcmtKZ2dnPT0ifV19fSwicGFydGlhbFBheW1lbnRJbnB1dCI6eyJhbW91bnQiOjI5ODAsImNvdW50cnlDb2RlIjoiVVMiLCJjdXJyZW5jeUNvZGUiOiJFVVIiLCJpc1JlY3VycmluZyI6ZmFsc2UsIm1lcmNoYW50SWQiOiI5OTkxOTk5OSIsInBheW1lbnRQcm9kdWN0SWQiOjMwMTJ9LCJycHBTcGVjaWZpY0lucHV0Ijp7ImNhcnQiOnsiY3VycmVuY3lTeW1ib2wiOiLigqwiLCJsaW5lSXRlbXMiOlt7ImRlc2NyaXB0aW9uIjoiQUNNRSBTdXBlciBPdXRmaXQiLCJuck9mSXRlbXMiOiIxIiwicHJpY2VQZXJJdGVtIjoyNTAwLCJ0b3RhbFByaWNlIjoyNTAwfSx7ImRlc2NyaXB0aW9uIjoiQXNwZXJpbiIsIm5yT2ZJdGVtcyI6IjEyIiwicHJpY2VQZXJJdGVtIjo0MCwidG90YWxQcmljZSI6NDgwfV0sInRvdGFsUHJpY2UiOjI5ODB9fX0=",
              @"showData" : @[
                      @{
                          @"key" : @"URLINTENT",
                          @"value" : @"BEPGenApp://DoTx?TransId=1example.com*P-2737860$7OLIFCBUS5TTHBA7FM7YSN7C&Callback=http%3A%2F%2Frpp.gc-ci-dev.isaac.local%3A7003%2Fredirector%2Freturn%2Fa0f45afd-dd16-4b99-9075-b7c76b251171"
                          }, @{
                          @"key" : @"QRCODE",
                          @"value" : @"iVBORw0KGgoAAAANSUhEUgAAAMgAAADIAQAAAACFI5MzAAABwElEQVR42u2YMa6DMBBEB7mg5AjcBC6GhCUuFm7iI1BSIPbPLCHJj5R2+foKRRT8Uli7s+NxYJ8efMlfJxlAY8VuzQa7IRW+p1Ayme1Nhu1cXPslFfO1SFLQNcIYWnQYy4rmArK13NaAC0nGWrFTxFcQ9Wc6WoPe7K1zAcQ1StKdH7/VG0D8mUq9q0nVkt4mOIDktt4xmsvEZm8XXyMJv1KeHJDmvktNbDSB9gZvjat1iSUuyg2oOCDyTdOoBBNXZu2zMfM3T+2EkdpYjlpuSaFOtnbnlAQRFobiKPWsvZlK1N/3FkXoD5Xm9KY5lUlwq2MsMZ7Wo7BZPdMyH9UJJPMC+DvlCbeLULJpES38zIICzP5QSAzJ2oyf21B6omeccxpFttb9QSVquZjUpFhiEmWiRlkixkj361iSQX9gidSp07CmUOKtGVWdpEXa97NuMUQmgYHRTYViiTzKhBJ/ssQx4PDr/jXVBJAjv5kyLOsk88RDITHEMyxPa5VFGpVhpVhSjjNLizy4sjLEBeRIbSrMgNf8Fkc0G+Z3WuhSF0z8LiOPHHBcIuYzOQQR12j2FK2rHGP9mRyiyPdfnH9GfgCdbBDjqKIT8wAAAABJRU5ErkJggg=="
                          }
                      ]
              },
      @"payment" : @{
              @"id" : @"2737860_0",
              @"paymentOutput" : @{
                      @"amountOfMoney" : @{
                              @"amount" : @2980,
                              @"currencyCode" : @"EUR"
                              },
                      @"references" : @{
                              @"merchantReference" : @"AcmeOrder0001"
                              },
                      @"paymentMethod" : @"card",
                      @"cardPaymentMethodSpecificOutput" : @{
                              @"paymentProductId" : @3012,
                              @"card" : @{
                                      }
                              }
                      },
              @"status" : @"PENDING_PAYMENT",
              @"statusOutput" : @{
                      @"isCancellable" : @NO,
                      @"statusCategory" : @"PENDING_PAYMENT",
                      @"statusCode" : @0,
                      @"isAuthorized" : @NO,
                      @"isRefundable" : @NO
                      }
              }
      };
    
    success(json);
}


#pragma mark PaymentProduct selection target

- (void)didSelectPaymentItem:(NSObject <ICBasicPaymentItem> *)paymentItem accountOnFile:(ICAccountOnFile *)accountOnFile;
{
    [SVProgressHUD showWithStatus:NSLocalizedStringFromTableInBundle(@"gc.app.general.loading.body", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil)];
    
    // ***************************************************************************
    //
    // After selecting a payment product or an account on file associated to a
    // payment product in the payment product selection screen, the ICSession
    // object is used to retrieve all information for this payment product.
    //
    // Afterwards, a screen is shown that allows the user to fill in all
    // relevant information, unless the payment product has no fields.
    // This screen is also not part of the SDK and is offered for demonstration
    // purposes only.
    //
    // If the payment product has no fields, the merchant is responsible for
    // fetching the URL for a redirect to a third party and show the corresponding
    // website.
    //
    // ***************************************************************************
    
    if ([paymentItem isKindOfClass:[ICBasicPaymentProduct class]]) {
        [self.session paymentProductWithId:paymentItem.identifier context:self.context success:^(ICPaymentProduct *paymentProduct) {
            if ([paymentItem.identifier isEqualToString:kICApplePayIdentifier]) {
                [self showApplePayPaymentItem:paymentProduct];
            } else {
                [SVProgressHUD dismiss];
                if ([paymentProduct.identifier isEqualToString:kICBancontactId]) {
                    [self bancontactJSONWithSuccess:  ^ void (NSDictionary<NSString *, NSObject *> *json) {
                        ICBancontactProductViewController *vc = [[ICBancontactProductViewController alloc]init];
                        vc.paymentItem = paymentProduct;
                        vc.session = self.session;
                        vc.context = self.context;
                        vc.viewFactory = self.viewFactory;
                        vc.accountOnFile = accountOnFile;
                        vc.customServerJSON = json;
                        vc.paymentRequestTarget = self;
                        [self.navigationController pushViewController:vc animated:YES];
                    } failure:  ^ void (NSError *error) {  }];
                    return;
                }
                if (paymentProduct.fields.paymentProductFields.count > 0) {
                    [self showPaymentItem:paymentProduct accountOnFile:accountOnFile];
                } else {
                    ICPaymentRequest *request = [[ICPaymentRequest alloc] init];
                    request.paymentProduct = paymentProduct;
                    request.accountOnFile = accountOnFile;
                    request.tokenize = NO;
                    [self didSubmitPaymentRequest:request];
                }
            }
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"PaymentProductErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
    else if ([paymentItem isKindOfClass:[ICBasicPaymentProductGroup class]]) {
        [self.session paymentProductGroupWithId:paymentItem.identifier context:self.context success:^(ICPaymentProductGroup *paymentProductGroup) {
            [SVProgressHUD dismiss];
            [self showPaymentItem:paymentProductGroup accountOnFile:accountOnFile];
        }                               failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"PaymentProductErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)showPaymentItem:(NSObject <ICPaymentItem> *)paymentItem accountOnFile:(ICAccountOnFile *)accountOnFile {
    ICPaymentProductViewController *paymentProductForm = nil;
    
    if (([paymentItem isKindOfClass:[ICPaymentProductGroup class]] && [paymentItem.identifier isEqualToString:@"cards"]) || ([paymentItem isKindOfClass:[ICPaymentProduct class]] && [((ICPaymentProduct *)paymentItem).paymentMethod isEqualToString:@"card"])) {
        paymentProductForm = [[ICCardProductViewController alloc] init];

    }
    else if ([kICArvatoIds containsObject:paymentItem.identifier])
    {
        paymentProductForm = [[ICArvatoProductViewController alloc]initWithPaymentItem:paymentItem Session:self.session context:self.context viewFactory:self.viewFactory accountOnFile:accountOnFile];
    }
    else if ([paymentItem.identifier isEqualToString:kICBoletoBancarioId]){
        paymentProductForm = [[ICBoletoProductViewController alloc]init];
    }
    else {
        paymentProductForm = [[ICPaymentProductViewController alloc] init];
    }
    paymentProductForm.paymentItem = paymentItem;
    paymentProductForm.session = self.session;
    paymentProductForm.context = self.context;
    paymentProductForm.viewFactory = self.viewFactory;
    paymentProductForm.accountOnFile = accountOnFile;

    // TODO: not in Swift
    paymentProductForm.amount = self.context.amountOfMoney.totalAmount;
    
    paymentProductForm.paymentRequestTarget = self;
    [self.navigationController pushViewController:paymentProductForm animated:YES];
}
#pragma mark ApplePay selection handling

- (void)showApplePayPaymentItem:(ICPaymentProduct *)paymentProduct {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && [PKPaymentAuthorizationViewController canMakePayments]) {
        [SVProgressHUD showWithStatus:NSLocalizedStringFromTableInBundle(@"gc.app.general.loading.body", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil)];
        
        // ***************************************************************************
        //
        // If the payment product is Apple Pay, the supported networks are retrieved.
        //
        // A view controller for Apple Pay will be shown when these networks have been
        // retrieved.
        //
        // ***************************************************************************
        
        [self.session paymentProductNetworksForProductId:kICApplePayIdentifier context:self.context success:^(ICPaymentProductNetworks *paymentProductNetworks) {
            [self showApplePaySheetForPaymentProduct:paymentProduct withAvailableNetworks:paymentProductNetworks];
            [SVProgressHUD dismiss];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"PaymentProductNetworksErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)showApplePaySheetForPaymentProduct:(ICPaymentProduct *)paymentProduct withAvailableNetworks:(ICPaymentProductNetworks *)paymentProductNetworks {
    
    // This merchant should be the merchant id specified in the merchants developer portal.
    NSString *merchantId = [StandardUserDefaults objectForKey:kICMerchantId];
    if (merchantId == nil) {
        return;
    }
    
    [self generateSummaryItems];
    
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    [paymentRequest setCountryCode:self.context.countryCode];
    [paymentRequest setCurrencyCode:self.context.amountOfMoney.currencyCode];
    [paymentRequest setSupportedNetworks:paymentProductNetworks.paymentProductNetworks];
    [paymentRequest setPaymentSummaryItems:self.summaryItems];
    
    // These capabilities should always be set to this value unless the merchant specifically does not want either Debit or Credit
    [paymentRequest setMerchantCapabilities:PKMerchantCapability3DS | PKMerchantCapabilityDebit | PKMerchantCapabilityCredit];
    
    // This merchant id is set in the merchants apple developer portal and is linked to a certificate
    [paymentRequest setMerchantIdentifier:merchantId];
    
    // These shipping and billing address fields are optional and can be chosen by the merchant
    [paymentRequest setRequiredShippingAddressFields: PKAddressFieldAll];
    [paymentRequest setRequiredBillingAddressFields:PKAddressFieldAll];
    
    self.authorizationViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    
    [self.authorizationViewController setDelegate:self];
    
    // The authorizationViewController will be nil if the paymentRequest was incomplete or not created correctly
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:paymentProductNetworks.paymentProductNetworks] && self.authorizationViewController != nil) {
        self.applePayPaymentProduct = paymentProduct;
        [self.navigationController.topViewController presentViewController:self.authorizationViewController animated:YES completion:nil];
    }
}

- (void)generateSummaryItems {
    
    // ***************************************************************************
    //
    // The summaryItems for the paymentRequest is a list of values with the last
    // value being the total and having the name of the merchant as label.
    //
    // A list of subtotal, shipping cost, and total is created below as example.
    // The values are specified in cents and converted to a NSDecimalNumber with
    // a exponent of -2.
    //
    // ***************************************************************************
    
    long subtotal = self.context.amountOfMoney.totalAmount;
    long shippingCost = 200;
    long total = subtotal + shippingCost;
    
    NSMutableArray *summaryItems = [[NSMutableArray alloc] init];
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:NSLocalizedStringFromTableInBundle(@"gc.app.general.shoppingCart.subtotal", kICSDKLocalizable, self.sdkBundle, @"subtotal summary item title") amount:[NSDecimalNumber decimalNumberWithMantissa:subtotal exponent:-2 isNegative:NO]]];
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:NSLocalizedStringFromTableInBundle(@"gc.app.general.shoppingCart.shippingCost", kICSDKLocalizable, self.sdkBundle, @"shipping cost summary item title") amount:[NSDecimalNumber decimalNumberWithMantissa:shippingCost exponent:-2 isNegative:NO]]];
    [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:@"Merchant Name" amount:[NSDecimalNumber decimalNumberWithMantissa:total exponent:-2 isNegative:NO] type:PKPaymentSummaryItemTypeFinal]];
    
    self.summaryItems = summaryItems;
}

#pragma mark -
#pragma mark Payment request target;

- (void)didSubmitPaymentRequest:(ICPaymentRequest *)paymentRequest
{
    [self didSubmitPaymentRequest:paymentRequest success:nil failure:nil];
}

- (void)didSubmitPaymentRequest:(ICPaymentRequest *)paymentRequest success:(void (^)())succes failure:(void (^)())failure
{
    [SVProgressHUD showWithStatus:NSLocalizedStringFromTableInBundle(@"gc.app.general.loading.body", kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], nil)];
    [self.session preparePaymentRequest:paymentRequest success:^(ICPreparedPaymentRequest *preparedPaymentRequest) {
        [SVProgressHUD dismiss];
        
        // ***************************************************************************
        //
        // The information contained in preparedPaymentRequest is stored in such a way
        // that it can be sent to the IngenicoConnect platform via your server.
        //
        // ***************************************************************************
        
        [self.paymentFinishedTarget didFinishPayment];
        
        if (succes != nil) {
            succes();
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ConnectionErrorTitle", kICAppLocalizable, @"Title of the connection error dialog.") message:NSLocalizedStringFromTable(@"SubmitErrorExplanation", kICAppLocalizable, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        if (failure != nil) {
            failure();
        }
    }];
}

- (void)didCancelPaymentRequest
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark PKPaymentAuthorizationViewControllerDelegate


// Sent to the delegate after the user has acted on the payment request.  The application
// should inspect the payment to determine whether the payment request was authorized.
//
// If the application requested a shipping address then the full addresses is now part of the payment.
//
// The delegate must call completion with an appropriate authorization status, as may be determined
// by submitting the payment credential to a processing gateway for payment authorization.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // ***************************************************************************
        //
        // The information contained in preparedPaymentRequest is stored in such a way
        // that it can be sent to the IngenicoConnect platform via your server.
        //
        // ***************************************************************************
        
        ICPaymentRequest *request = [[ICPaymentRequest alloc] init];
        request.paymentProduct = self.applePayPaymentProduct;
        request.tokenize = NO;
        [request setValue:[[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding] forField:@"encryptedPaymentData"];
        [request setValue:payment.token.transactionIdentifier forField:@"transactionId"];
        [self didSubmitPaymentRequest:request success:^{
            completion(PKPaymentAuthorizationStatusSuccess);
        } failure:^{
            completion(PKPaymentAuthorizationStatusFailure);
        }];
        
        
    });
}


// Sent to the delegate when payment authorization is finished.  This may occur when
// the user cancels the request, or after the PKPaymentAuthorizationStatus parameter of the
// paymentAuthorizationViewController:didAuthorizePayment:completion: has been shown to the user.
//
// The delegate is responsible for dismissing the view controller in this method.
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    self.applePayPaymentProduct = nil;
    [self.authorizationViewController dismissViewControllerAnimated:YES completion:nil];
}


// Sent when the user has selected a new payment card.  Use this delegate callback if you need to
// update the summary items in response to the card type changing (for example, applying credit card surcharges)
//
// The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
// until it has invoked the completion block.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                    didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod
                                completion:(void (^)(NSArray<PKPaymentSummaryItem *> *summaryItems))completion NS_AVAILABLE_IOS(9_0)
{
    completion(self.summaryItems);
}


#pragma mark -

@end
