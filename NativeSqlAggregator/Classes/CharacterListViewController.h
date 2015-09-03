//
//  CharacterListViewController.h
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 8/10/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import <SalesforceRestAPI/SFRestAPI.h>

#import "Util.h"

@interface CharacterListViewController : UITableViewController <SFRestDelegate>


@property (nonatomic, strong) NSMutableArray *charactarListArray;
@property (nonatomic,strong) NSMutableArray * charactersInfoWithImageArray;

@property (nonatomic, retain) NSDictionary *data;

-(void)getMarvelCharactersList;

@end
