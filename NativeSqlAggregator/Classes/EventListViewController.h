//
//  EventListViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 17/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import <SalesforceRestAPI/SFRestAPI.h>
#import "Util.h"

@interface EventListViewController : UITableViewController<SFRestDelegate>

@property (nonatomic, strong) NSMutableArray *eventListArray;
@property (nonatomic,strong) NSString * comicID;

-(void)getMarvelComicEventList;

@end
