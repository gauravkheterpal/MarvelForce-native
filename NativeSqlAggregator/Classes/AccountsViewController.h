//
//  AccountsViewController.h
//  SocialForce
//
//  Created by Ritika on 10/05/13.
//  Copyright (c) 2013 Metacube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "SFRestAPI.h"
@interface AccountsViewController : UIViewController <SFRestDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate> {
    IBOutlet UITableView *accTable;
    UIPopoverController *popOverCtrl;
}
@property (nonatomic,retain) NSMutableArray *SFAccountsArr;
@property (nonatomic,retain) NSArray *filteredAccountArr;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;


@end
