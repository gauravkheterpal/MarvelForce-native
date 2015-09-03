//
//  TaskDetailInterfaceController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 26/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>


@interface TaskDetailInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subject;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *status;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dueDate;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *type;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *userName;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *markAsCompleteBtn;
@property (retain, nonatomic) NSString* taskID;
@property (retain, nonatomic) NSString* badgeID;
@property (retain, nonatomic) NSDictionary* badgeDetail;

@end
