//
//  ComicDetailViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 12/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface ComicDetailViewController : UIViewController

@property (nonatomic, strong) NSString *comicId;
@property (nonatomic, strong) NSDictionary *comicDetailDict;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *characterImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UILabel *pagesLbl;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;
@property (weak, nonatomic) IBOutlet UITextView *charactersTextView;

@end
