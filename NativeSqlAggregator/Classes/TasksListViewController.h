//
//  TasksListViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 20/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SalesforceRestAPI/SFRestAPI.h>
#import <SalesforceSDKCore/SFUserAccountManager.h>
#import "SVProgressHUD.h"

@interface TasksListViewController : UITableViewController<SFRestDelegate>

@property (nonatomic, strong) NSArray *taskResultDataSet;

@end
