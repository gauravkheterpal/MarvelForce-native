//
//  ContactDetailViewController.h
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 7/17/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import <SalesforceRestAPI/SFRestAPI.h>
#import "SVProgressHUD.h"

#import <SalesforceRestAPI/SFRestAPI.h>
#import <SalesforceRestAPI/SFRestRequest.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import "Util.h"

@interface ContactDetailViewController : UIViewController<SFRestDelegate>

@property (nonatomic,retain) NSMutableDictionary *recordDict;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *NameLbl;
@property (weak, nonatomic) IBOutlet UILabel *departmentLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;



@end
