//
//  ICExternalAppStatusViewController.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 14/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

#import "ICExternalAppStatusViewController.h"
#import <ICThirdPartyStatus.h>
#import "ICStatusView.h"
#import <IngenicoConnectSDK/ICSDKConstants.h>
#import "ICAppConstants.h"
@interface ICExternalAppStatusViewController ()
@property (nonatomic, strong) ICStatusView *startStatus;
@property (nonatomic, strong) ICStatusView *authorizedStatus;
@property (nonatomic, strong) ICStatusView *endStatus;
@property (nonatomic, strong) UILabel *descriptiveLabel;
@end

@implementation ICExternalAppStatusViewController
-(void)setExternalAppStatus:(ICThirdPartyStatus)thirdPartyStatus
{
    _externalAppStatus = thirdPartyStatus;
    switch (_externalAppStatus) {
        case ICThirdPartyStatusWaiting:
            [self.startStatus setStatus:ICStatusViewStatusProgress];
            [self.authorizedStatus setStatus:ICStatusViewStatusWaiting];
            [self.endStatus setStatus:ICStatusViewStatusWaiting];
            break;
        case ICThirdPartyStatusInitialized:
            [self.startStatus setStatus:ICStatusViewStatusFinished];
            [self.authorizedStatus setStatus:ICStatusViewStatusProgress];
            [self.endStatus setStatus:ICStatusViewStatusWaiting];
            break;
        case ICThirdPartyStatusAuthorized:
            [self.startStatus setStatus:ICStatusViewStatusFinished];
            [self.authorizedStatus setStatus:ICStatusViewStatusFinished];
            [self.endStatus setStatus:ICStatusViewStatusProgress];
            break;
        case ICThirdPartyStatusCompleted:
            [self.startStatus setStatus:ICStatusViewStatusFinished];
            [self.authorizedStatus setStatus:ICStatusViewStatusFinished];
            [self.endStatus setStatus:ICStatusViewStatusFinished];
            break;

        default:
            break;
    }
    
}
-(void)loadView {
    [super loadView];
    CGFloat inset = 20.0;
    
    // Label with description
    {
        self.descriptiveLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 320/2, inset, 320, 40)];
        NSString *key = @"gc.general.paymentProducts.3012.processing";
        self.descriptiveLabel.text = NSLocalizedStringFromTableInBundle(key, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], "");
        self.descriptiveLabel.numberOfLines = 0;
        CGRect bounds = self.descriptiveLabel.frame;
        bounds.size = [self.descriptiveLabel sizeThatFits:CGSizeMake(320, CGFLOAT_MAX)];

        self.descriptiveLabel.frame = bounds;
        [self.view addSubview:self.descriptiveLabel];
    }
    
    // Initialization Status
    {
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 320/2, inset + 40, 320, 40)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, containerView.frame.size.width - 40, 40)];
        NSString *key = @"gc.general.paymentProducts.3012.paymentStatus1";
        label.text = NSLocalizedStringFromTableInBundle(key, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], "");
        self.startStatus = [[ICStatusView alloc]initWithFrame:CGRectMake(0, 0, 40, 40) andStatus:ICStatusViewStatusProgress];
        [containerView addSubview: self.startStatus];
        [containerView addSubview:label];
        [self.view addSubview:containerView];
    }

    // Authorization Status
    {
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 320/2, inset + 80, 320, 40)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, containerView.frame.size.width - 40, 40)];
        NSString *key = @"gc.general.paymentProducts.3012.paymentStatus2";
        label.text = NSLocalizedStringFromTableInBundle(key, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], "");
        self.authorizedStatus = [[ICStatusView alloc]initWithFrame:CGRectMake(0, 0, 40, 40) andStatus:ICStatusViewStatusWaiting];
        [containerView addSubview: self.authorizedStatus];
        [containerView addSubview:label];
        [self.view addSubview:containerView];
    }
    
    // Finishing Status
    {
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 320/2, inset + 120, 320, 40)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, containerView.frame.size.width - 40, 40)];
        NSString *key = @"gc.general.paymentProducts.3012.paymentStatus3";
        label.text = NSLocalizedStringFromTableInBundle(key, kICSDKLocalizable, [NSBundle bundleWithPath:kICSDKBundlePath], "");
        self.endStatus = [[ICStatusView alloc]initWithFrame:CGRectMake(0, 0, 40, 40) andStatus:ICStatusViewStatusWaiting];
        [containerView addSubview: self.endStatus];
        [containerView addSubview:label];
        [self.view addSubview:containerView];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
