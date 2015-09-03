//
//  TaskRow.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 26/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface TaskRow : NSObject

@property (nonatomic,weak) IBOutlet WKInterfaceLabel *taskSubject;
@property (nonatomic,weak) IBOutlet WKInterfaceLabel *taskStatus;

@end
