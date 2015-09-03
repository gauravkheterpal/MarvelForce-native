//
//  UserProfileViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 21/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SalesforceSDKCore/SFUserAccountManager.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "IconDownloader.h"

@interface UserProfileViewController : UIViewController<IconDownloaderDelegate,SFRestDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userProfile;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UICollectionView *badgesCollection;
@property (nonatomic, strong) NSMutableArray *userBadgeArray;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImgView;

@end
