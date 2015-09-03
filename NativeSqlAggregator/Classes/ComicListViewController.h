//
//  ComicListViewController.h
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 8/11/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import <SalesforceRestAPI/SFRestAPI.h>
#import "Util.h"

@interface ComicListViewController : UITableViewController <SFRestDelegate>

@property (nonatomic, strong) NSMutableArray *comicListArray;
@property (nonatomic,strong) NSString * characterID;

-(void)getMarvelComicList;

@end
