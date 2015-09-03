//
//  CharacterDetailViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 11/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface CharacterDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSString *characterId;
@property (nonatomic, strong) NSDictionary *characterDetailDict;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *characterImage;
@property (weak, nonatomic) IBOutlet UILabel *NameLbl;
@property (weak, nonatomic) IBOutlet UILabel *storyLbl;
@property (weak, nonatomic) IBOutlet UITableView *storyListView;
@property (nonatomic, strong) NSMutableArray *storyDataArray;
@property (weak, nonatomic) IBOutlet UILabel *storyNotAvailableLbl;

@end
