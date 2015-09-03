//
//  LeadsViewController.h
//  SocialForce
//
//  Created by Ritika on 10/05/13.
//  Copyright (c) 2013 Metacube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "SFRestAPI.h"
@interface LeadsViewController : UIViewController <SFRestDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate> {
    
    IBOutlet UITableView *leadsTable;
    UIPopoverController *popOverCtrl;
}
@property (nonatomic,retain) NSArray *filteredLeadsArr;
@property (nonatomic,retain) NSMutableArray *SFLeadsArr;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@end
