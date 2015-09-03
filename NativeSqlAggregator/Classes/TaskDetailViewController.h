//
//  TaskDetailViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 20/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SalesforceSDKCore/SFUserAccountManager.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "IconDownloader.h"
#import "CustomAlertViewController.h"



@interface TaskDetailViewController : UIViewController<IconDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *taskStatus;
@property (weak, nonatomic) IBOutlet UILabel *taskType;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (weak, nonatomic) IBOutlet UILabel *priority;
@property (weak, nonatomic) IBOutlet UITextView *comments;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImgView;
@property (nonatomic, strong) NSDictionary *taskDetailDict;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, strong) NSMutableArray *charactarListArray;
@property (nonatomic,strong) NSMutableArray * charactersList;
@property (nonatomic,strong) CustomAlertViewController *customVC;


@end
