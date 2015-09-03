//
//  BadgeAssignInterfaceController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 27/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "BadgeAssignInterfaceController.h"

@interface BadgeAssignInterfaceController ()

@end

@implementation BadgeAssignInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSLog(@"Context %@",context);
    if (context!= nil && [context isKindOfClass:[NSDictionary class]]) {
        NSDictionary *badgeDetail = (NSDictionary*)context;
        if ([badgeDetail objectForKey:@"badgeImage"] != nil) {
            
           [self.badgeImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[badgeDetail objectForKey:@"badgeImage"]]]];
            
        }
        if ([badgeDetail objectForKey:@"badgeName"]!=nil) {
            [self.badgeNameLabel setText:[badgeDetail objectForKey:@"badgeName"]];
        }
    }
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



