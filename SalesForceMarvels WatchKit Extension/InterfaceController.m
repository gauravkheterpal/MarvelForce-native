//
//  InterfaceController.m
//  SalesForceMarvels WatchKit Extension
//
//  Created by Bhavna Gupta on 25/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "InterfaceController.h"
#import "TaskRow.h"


@interface InterfaceController()

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    self.dataObjects = [[NSMutableArray alloc]init];
    
    // Invoke Parent app to get latest Tasks data from the local store
    NSDictionary *request = @{@"request":@"getTasks"}; //set up request dictionary
    
    [InterfaceController openParentApplication:request reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
            NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.metacube.mobile.salesforcemarvel"];

            if ([shared valueForKey:@"Tasks"] != (id)[NSNull null] && [shared valueForKey:@"Tasks"] != nil) {
                
                self.dataObjects = (NSMutableArray*)[shared valueForKey:@"Tasks"];
            }else {
                
                self.dataObjects = [[NSMutableArray alloc]init];
            }
            [self configureTableWithData];
            
        } else {
            
            if([replyInfo objectForKey:@"records"]!=nil) {
                
                NSLog(@"Task Response %@", [replyInfo objectForKey:@"records"]);
                self.dataObjects = [replyInfo objectForKey:@"records"];
                [self configureTableWithData];
            }
            
        }
        
    }];

}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)configureTableWithData {
    
   [self.taskList setNumberOfRows:[self.dataObjects count] withRowType:@"taskRow"];
    
    for (NSInteger i = 0; i < self.taskList.numberOfRows; i++) {
       
        TaskRow* theRow = [self.taskList rowControllerAtIndex:i];
        
        if ([[self.dataObjects objectAtIndex:i]objectForKey:@"Subject"]!=nil && [[self.dataObjects objectAtIndex:i]objectForKey:@"Subject"]!=(id)[NSNull null] ) {
            [theRow.taskSubject setText:[[self.dataObjects objectAtIndex:i]objectForKey:@"Subject"]];
        }else {
            [theRow.taskSubject setText:@""];
        }
        
        if ([[self.dataObjects objectAtIndex:i]objectForKey:@"Status"]!=nil && [[self.dataObjects objectAtIndex:i]objectForKey:@"Status"]!=(id)[NSNull null]) {
            [theRow.taskStatus setText:[[self.dataObjects objectAtIndex:i]objectForKey:@"Status"]];
        }else {
            [theRow.taskStatus setText:@""];
        }
        
        
    }
}

- (void)table:(WKInterfaceTable *)tableView didSelectRowAtIndex:(NSInteger)rowIndex{
    
     NSDictionary *rowData = [self.dataObjects objectAtIndex:rowIndex];
    [self pushControllerWithName:@"TaskDetailInterfaceController" context:rowData];
    
}


@end



