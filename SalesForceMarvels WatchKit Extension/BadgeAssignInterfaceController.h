//
//  BadgeAssignInterfaceController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 27/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface BadgeAssignInterfaceController : WKInterfaceController

@property (nonatomic,weak) IBOutlet WKInterfaceLabel *badgeNameLabel;
@property (nonatomic,weak) IBOutlet WKInterfaceImage *badgeImage;
@end
