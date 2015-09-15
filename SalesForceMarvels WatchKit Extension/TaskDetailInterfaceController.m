//
//  TaskDetailInterfaceController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 26/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "TaskDetailInterfaceController.h"

@interface TaskDetailInterfaceController ()

@end

@implementation TaskDetailInterfaceController


- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.taskID = [[NSString alloc]init];
    self.badgeID = [[NSString alloc]init];
    self.badgeDetail = [[NSDictionary alloc]init];
    
    NSLog(@"Context %@",context);
    if (context!= nil && [context isKindOfClass:[NSDictionary class]]) {
        NSDictionary *taskDetail = (NSDictionary*)context;
        
        // Access group storage
        
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.metacube.mobile.salesforcemarvel"];
        
        
        NSLog(@"Username :%@",[shared valueForKey:@"SFUserName"]);
        if ([shared valueForKey:@"SFUserName"] != (id)[NSNull null] && [shared valueForKey:@"SFUserName"] != nil) {
            [self.userName setText:[NSString stringWithFormat:@"%@",[shared valueForKey:@"SFUserName"]]];
        }else {
            [self.userName setText:@""];
        }
        
        if ([taskDetail objectForKey:@"Subject"]!=nil && [taskDetail objectForKey:@"Subject"]!=(id)[NSNull null]) {
            [self.subject setText:[taskDetail objectForKey:@"Subject"]];
        }else {
            [self.subject setText:@""];
        }
        
        if ([taskDetail objectForKey:@"Status"]!=nil && [taskDetail objectForKey:@"Status"]!=(id)[NSNull null]) {
            [self.status setText:[taskDetail objectForKey:@"Status"]];
        }else {
            [self.status setText:@""];
        }
        
        if ([taskDetail objectForKey:@"Type"]!=nil && [taskDetail objectForKey:@"Type"]!=(id)[NSNull null]) {
            [self.type setText:[taskDetail objectForKey:@"Type"]];
        }else {
            [self.type setText:@""];
        }
        
        if ([taskDetail objectForKey:@"ActivityDate"]!=nil && [taskDetail objectForKey:@"ActivityDate"]!=(id)[NSNull null]) {
            [self.dueDate setText:[taskDetail objectForKey:@"ActivityDate"]];
        }else {
            [self.dueDate setText:@""];
        }
        
        if ([taskDetail objectForKey:@"Id"]!=nil && [taskDetail objectForKey:@"Id"]!=(id)[NSNull null]) {
            self.taskID = [taskDetail objectForKey:@"Id"];
        }else {
            self.taskID = @"";
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

- (IBAction)updateTask {
    
    if (self.taskID != nil && ![self.taskID isEqualToString:@""] && self.taskID!=(id)[NSNull null]) {
        // Invoke Parent app to get latest Tasks data from the local store
        NSDictionary *userInfo = @{@"request" : @"markTaskAsComplete", @"taskID": self.taskID};//set up userInfo dictionary
        
        [TaskDetailInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error) {
            
            if (error) {
                NSLog(@"MarkTaskAsComplete Error %@", error);
                
            } else {
                
                NSLog(@"MarkTaskAsComplete ReplyInfo :%@",replyInfo);
                
                if ([replyInfo objectForKey:@"Success"]!=nil && [[replyInfo objectForKey:@"Success"] isEqualToString:@"Task Completed Successfully"]) {
                    
                    NSDictionary *getCharacterRequest = @{@"request" : @"getMarvelCharacter"};
                    
                    [TaskDetailInterfaceController openParentApplication:getCharacterRequest reply:^(NSDictionary *replyInfo, NSError *error) {
                        
                        if (error) {
                            NSLog(@"GET character request error :%@ ",error);
                            [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                            
                        }else {
                            
                            NSLog(@"ReplyInfo :%@",replyInfo);
                            
                            if ([replyInfo objectForKey:@"Success"]!=nil) {
                                
                                NSMutableArray *charactersList = [replyInfo objectForKey:@"Success"];
                                NSDictionary *badgeRequest = @{@"request" : @"checkUserBadgeRequest",@"charactersList":charactersList};
                                [self checkUserBadgeRequest:badgeRequest];
                                
                                
                            }else {
                                [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                            }
                        }
                    }];
                }else {
                    
                    NSLog(@"MarkTaskAsComplete Failed");
                }
                
            }
            
        }];
        
    }else {
        NSLog(@"Task can't be updated");
    }
    
}

-(void)checkUserBadgeRequest:(NSDictionary*)request {
    
    [TaskDetailInterfaceController openParentApplication:request reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            
            NSLog(@"checkUserBadgeRequest Error :%@",error);
            [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
            
        }else if ([replyInfo objectForKey:@"Error"]!=nil) {
            
            NSLog(@"checkUserBadgeRequest Error :%@",[replyInfo objectForKey:@"Error"]);
            [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
            
        }else if([replyInfo objectForKey:@"Success"]!=nil) {
            
            NSLog(@"checkUserBadgeRequest ReplyInfo :%@",replyInfo);
            
            if ([[replyInfo objectForKey:@"Success"] isEqualToString:@"Congratulations, You already have 10 badges"]) {
                
                NSDictionary *detailInfo = @{@"badgeName" : @"Congratulations, You already have 10 badges"};
                [self pushControllerWithName:@"BadgeAssignInterfaceController" context:detailInfo];
                
                NSLog(@"Already Have 10 badges");
                
            }else if ([[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge Exists True"]) {
                
                NSLog(@"Badge Exists True");
                [self checkUserBadgeRequest:request];
                
            }else if ([[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge Exists False"]) {
                
                
                if ([replyInfo objectForKey:@"BadgeDetail"] == nil && [replyInfo objectForKey:@"BadgeDetail"] == (id)[NSNull null]) {
                    
                    NSLog(@"checkUserBadgeRequest Failed");
                    [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                    
                    
                }else
                {
                    
                    NSDictionary *badgeDetailResponse = [replyInfo objectForKey:@"BadgeDetail"];
                    
                    NSDictionary *createNewBadgeRequest = @{@"request" : @"createNewBadgeRequest",@"BadgeDetail":badgeDetailResponse};
                    
                    [TaskDetailInterfaceController openParentApplication:createNewBadgeRequest reply:^(NSDictionary *replyInfo, NSError *error) {
                        
                        NSLog(@"ReplyInfo createNewBadgeRequest:%@",replyInfo);
                        if (error) {
                            
                            NSLog(@"createNewBadgeRequest Error :%@",error);
                            [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                            
                        }else if ([replyInfo objectForKey:@"Error"]!=nil) {
                            
                            NSLog(@"createNewBadgeRequest Error :%@",[replyInfo objectForKey:@"Error"]);
                            [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                            
                            
                        }else if ([replyInfo objectForKey:@"Success"]!=nil && [[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge Created Successfully"]) {
 
                            if ([replyInfo objectForKey:@"objectID"] != nil && [replyInfo objectForKey:@"objectID"] != (id)[NSNull null]) {
                                self.badgeID = [replyInfo objectForKey:@"objectID"];
                            }
                            
                            if ([replyInfo objectForKey:@"BadgeDetail"] != nil && [replyInfo objectForKey:@"BadgeDetail"] != (id)[NSNull null]) {
                                self.badgeDetail = [replyInfo objectForKey:@"BadgeDetail"];
                            }
                            
                            
                            NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.metacube.mobile.salesforcemarvel"];
                            
                            
                            if ([shared valueForKey:@"SFUserID"] != (id)[NSNull null] && [shared valueForKey:@"SFUserID"] != nil){
                                
                                NSString *userID = [shared valueForKey:@"SFUserID"];
                                NSDictionary *fetchUserBadgeRequest = @{@"request" : @"fetchUserBadgeRequest",@"userID":userID};
                                
                                
                                NSLog(@"Fetch user badge request:%@",fetchUserBadgeRequest);
                                
                                [TaskDetailInterfaceController openParentApplication:fetchUserBadgeRequest reply:^(NSDictionary *replyInfo, NSError *error) {
                                    
                                    
                                    NSLog(@"fetchUserBadgeRequest: ReplyInfo %@",replyInfo);
                                    
                                    
                                    if (error) {
                                        
                                        NSLog(@"fetchUserBadgeRequest Error :%@",error);
                                        [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                                        
                                    }else if ([replyInfo objectForKey:@"Error"]!=nil) {
                                        
                                        NSLog(@"fetchUserBadgeRequest Error :%@",[replyInfo objectForKey:@"Error"]);
                                        [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                                        
                                    }else if ([replyInfo objectForKey:@"Success"]!=nil && [[replyInfo objectForKey:@"Success"] isEqualToString:@"Fetch User Badge Success"]) {
                                        
                                        NSString *badgeNumberTobeAssigned = @"";
                                        if ([replyInfo objectForKey:@"badgeNumberTobeAssigned"]!=nil && [replyInfo objectForKey:@"badgeNumberTobeAssigned"] != (id)[NSNull null]) {
                                            badgeNumberTobeAssigned = [replyInfo objectForKey:@"badgeNumberTobeAssigned"];
                                        }
                                        
                                        if (self.badgeID != nil && ![self.badgeID isEqualToString:@""] && self.badgeDetail != nil && ![badgeNumberTobeAssigned isEqualToString:@""]) {
                                            
                                            NSDictionary *fieldDict = @{badgeNumberTobeAssigned:self.badgeID};
                                            
                                            NSDictionary *assignBadgeToUserRequest = @{@"request" : @"assignBadgeToUserRequest",@"fieldDict":fieldDict};
                                            
                                            NSLog(@"assignBadgeToUserRequest:%@",assignBadgeToUserRequest);
                                            
                                            [TaskDetailInterfaceController openParentApplication:assignBadgeToUserRequest reply:^(NSDictionary *replyInfo, NSError *error) {
                                                
                                                NSLog(@"ReplyInfo assignBadgeUserRequest:%@",replyInfo);
                                                if (error) {
                                                    
                                                    NSLog(@"assignBadgeUserRequest Error :%@",error);
                                                    [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                                                    
                                                    
                                                }else if ([replyInfo objectForKey:@"Error"]!=nil) {
                                                    
                                                    
                                                    NSLog(@"assignBadgeUserRequest Error :%@",[replyInfo objectForKey:@"Error"]);
                                                    [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                                                    
                                                    
                                                }else if ([replyInfo objectForKey:@"Success"]!=nil && [[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge assigned successfully"]) {
                                                    
                                                    NSLog(@"assignBadgeUserRequest ReplyInfo :%@",replyInfo);
                                                    
                                                    if (self.badgeDetail !=nil ) {
                                                        
                                                        NSString *characterName = [self.badgeDetail objectForKey:@"Name"];
                                                        NSString *imageStr = [self.badgeDetail objectForKey:@"Badge_Image_URL__c"];
                                                        
                                                        NSURL *characterImageURL = [NSURL URLWithString:[imageStr stringByReplacingOccurrencesOfString:@"imagetypeplaceholder" withString:@"standard_medium"]];
                                                        
                                                        NSDictionary *detailInfo = @{@"badgeName" : [NSString stringWithFormat:@"%@ badge assigned",characterName],@"badgeImage":characterImageURL};
                                                        
                                                        [self pushControllerWithName:@"BadgeAssignInterfaceController" context:detailInfo];
                                                    }else {
                                                        
                                                        NSLog(@"assignBadgeUserRequest Failed");
                                                        [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                                                    }
                                                    
                                                }
                                            }];
                                        }else {
                                            
                                            NSLog(@"fetchUserBadgeRequest Failed");
                                            [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                                        }
                                        
                                    }
                                    
                                }];
                            } else {
                                
                                NSLog(@"createNewBadgeRequest Failed");
                                [self pushControllerWithName:@"BadgeAssignInterfaceController" context:nil];
                                
                            }
                        }
                    }];
                }
            }
            
        }
        
    }];
}

@end



