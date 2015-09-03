//
//  BadgeCollectionViewCell.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 21/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface BadgeCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *badgeImage;
@property (strong, nonatomic) IBOutlet UILabel *badgeName;

@end
