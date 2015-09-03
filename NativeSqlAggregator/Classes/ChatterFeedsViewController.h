//
//  ChatterFeedsViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 01/09/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"

@interface ChatterFeedsViewController : UITableViewController<IconDownloaderDelegate>

@property (nonatomic, retain) NSMutableArray *chatterFeedsArray;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;


@end
