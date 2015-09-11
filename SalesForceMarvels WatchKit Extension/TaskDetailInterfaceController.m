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
        id value = [shared valueForKey:@"SFUserName"];
        if (value == (id)[NSNull null]) {
            [self.userName setText:[NSString stringWithFormat:@"%@",value]];
        }else {
            [self.userName setText:@""];
        }
        
        [self.subject setText:[taskDetail objectForKey:@"Subject"]];
        [self.status setText:[taskDetail objectForKey:@"Status"]];
        [self.type setText:[taskDetail objectForKey:@"Type"]];
        [self.dueDate setText:[taskDetail objectForKey:@"ActivityDate"]];
        self.taskID = [taskDetail objectForKey:@"Id"];
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
    
    // Invoke Parent app to get latest Tasks data from the local store
    NSDictionary *userInfo = @{@"request" : @"markTaskAsComplete", @"taskID": self.taskID};//set up userInfo dictionary
    
    [TaskDetailInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"ReplyInfo :%@",replyInfo);
            
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
            }
            
        }
        
    }];
    
}

-(void)checkUserBadgeRequest:(NSDictionary*)request {
    
    [TaskDetailInterfaceController openParentApplication:request reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error in checkUserBadgeRequest");
            
        }else if ([replyInfo objectForKey:@"Error"]!=nil) {
            
            NSLog(@"Error in checkUserBadgeRequest");
            
        }else if([replyInfo objectForKey:@"Success"]!=nil) {
            
            NSLog(@"ReplyInfo checkUserBadgeRequest:%@",replyInfo);
            
            if ([[replyInfo objectForKey:@"Success"] isEqualToString:@"Congratulations, You already have 10 badges"]) {
                
                NSDictionary *detailInfo = @{@"badgeName" : @"Congratulations, You already have 10 badges"};
                [self pushControllerWithName:@"BadgeAssignInterfaceController" context:detailInfo];
                
                NSLog(@"Already Have 10 badges");
                
            }else if ([[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge Exists True"]) {
                
                NSLog(@"Badge Exists True");
                [self checkUserBadgeRequest:request];
                
            }else if ([[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge Exists False"]) {
                
                NSDictionary *badgeDetail = [replyInfo objectForKey:@"BadgeDetail"];
                NSDictionary *createNewBadgeRequest = @{@"request" : @"createNewBadgeRequest",@"BadgeDetail":badgeDetail};
                
                [TaskDetailInterfaceController openParentApplication:createNewBadgeRequest reply:^(NSDictionary *replyInfo, NSError *error) {

                    NSLog(@"ReplyInfo createNewBadgeRequest:%@",replyInfo);
                    if (error) {
                        
                        NSLog(@"Error in create New Badge");
                        
                    }else if ([replyInfo objectForKey:@"Error"]!=nil) {
                        
                        NSLog(@"Error in create New Badge");
                        
                    }else if ([replyInfo objectForKey:@"Success"]!=nil && [[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge Created Successfully"]) {
                       
                      /*  NSDictionary *badgeInfo = [replyInfo objectForKey:@"BadgeDetail"];
                        NSString *characterName = [badgeInfo objectForKey:@"Name"];
                        NSString *imageStr = [badgeInfo objectForKey:@"Badge_Image_URL__c"];
                        
                         NSURL *characterImageURL = [NSURL URLWithString:[imageStr stringByReplacingOccurrencesOfString:@"imagetypeplaceholder" withString:@"standard_medium"]];
                        
                        NSDictionary *detailInfo = @{@"badgeName" : [NSString stringWithFormat:@"%@ badge assigned",characterName],@"badgeImage":characterImageURL};
                        
                        [self pushControllerWithName:@"BadgeAssignInterfaceController" context:detailInfo];
                        */
                        
                       
                        self.badgeID = [replyInfo objectForKey:@"objectID"];
                        self.badgeDetail = [replyInfo objectForKey:@"BadgeDetail"];
                        
                        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.metacube.mobile.salesforcemarvel"];
                        NSString *userID = [shared valueForKey:@"SFUserID"];
                        NSDictionary *fetchUserBadgeRequest = @{@"request" : @"fetchUserBadgeRequest",@"userID":userID};
                        
                        NSLog(@"Fetch user badge request:%@",fetchUserBadgeRequest);
                        [TaskDetailInterfaceController openParentApplication:fetchUserBadgeRequest reply:^(NSDictionary *replyInfo, NSError *error) {
                            
                            NSLog(@"ReplyInfo fetchUserBadgeRequest:%@",replyInfo);

                            if (error) {
                                
                                NSLog(@"fetch User Badge Error :%@",error);
                                
                            }else if ([replyInfo objectForKey:@"Error"]!=nil) {
                                
                                NSLog(@"fetch User Badge Error ");
                                
                            }else if ([replyInfo objectForKey:@"Success"]!=nil && [[replyInfo objectForKey:@"Success"] isEqualToString:@"Fetch User Badge Success"]) {
                                
                                NSString *badgeNumberTobeAssigned = [replyInfo objectForKey:@"badgeNumberTobeAssigned"];

                                if (self.badgeID != nil && self.badgeDetail != nil) {
                                    
                                    NSDictionary *fieldDict = @{badgeNumberTobeAssigned:self.badgeID};
                                    
                                    NSDictionary *assignBadgeToUserRequest = @{@"request" : @"assignBadgeToUserRequest",@"fieldDict":fieldDict};
                                    
                                    NSLog(@"assignBadgeToUserRequest:%@",assignBadgeToUserRequest);
                                    
                                    [TaskDetailInterfaceController openParentApplication:assignBadgeToUserRequest reply:^(NSDictionary *replyInfo, NSError *error) {
                                        
                                        NSLog(@"ReplyInfo assignBadgeUserRequest:%@",replyInfo);
                                        if (error) {
                                            
                                            NSLog(@"Assign Badge To User  Error :%@",error);
                                            
                                        }else if ([replyInfo objectForKey:@"Error"]!=nil) {
                                            
                                            NSLog(@"Assign Badge To User  Error ");
                                            
                                        }else if ([replyInfo objectForKey:@"Success"]!=nil && [[replyInfo objectForKey:@"Success"] isEqualToString:@"Badge assigned successfully"]) {
                                            
                                            NSLog(@"ReplyInfo :%@",replyInfo);
                                            
                                            if (self.badgeDetail !=nil ) {
                                                
                                                NSString *characterName = [self.badgeDetail objectForKey:@"Name"];
                                                NSString *imageStr = [self.badgeDetail objectForKey:@"Badge_Image_URL__c"];
                                                
                                                NSURL *characterImageURL = [NSURL URLWithString:[imageStr stringByReplacingOccurrencesOfString:@"imagetypeplaceholder" withString:@"standard_medium"]];
                                                
                                                NSDictionary *detailInfo = @{@"badgeName" : [NSString stringWithFormat:@"%@ badge assigned",characterName],@"badgeImage":characterImageURL};
                                                
                                                [self pushControllerWithName:@"BadgeAssignInterfaceController" context:detailInfo];
                                            }
                                            
                                        }
                                    }];
                                }
 
   
                            }
                            
                        }];
                
                    }
                }];
            }

            
        }
        
    }];
}

@end



