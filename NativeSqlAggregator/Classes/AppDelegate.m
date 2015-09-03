/*
 Copyright (c) 2011-2014, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
//#import "InitialViewController.h"
#import "RootViewController.h"
#import "ResultViewController.h"
#import "CharacterListViewController.h"
#import "NewChatterFeedViewController.h"
#import "ChatterFeedsViewController.h"
#import <SalesforceSDKCore/SFPushNotificationManager.h>
#import <SalesforceSDKCore/SFDefaultUserManagementViewController.h>
#import <SalesforceSDKCore/SalesforceSDKManager.h>
#import <SalesforceSDKCore/SFUserAccountManager.h>
#import "SFRestAPI+Blocks.h"

#import "UserProfileViewController.h"
#import "ComicListViewController.h"
#import "TasksListViewController.h"


// Fill these in when creating a new Connected Application on Force.com
static NSString * const RemoteAccessConsumerKey = @"3MVG9ZL0ppGP5UrBly5N4WklgL18V4zDpNan9Ct6m35V9p.gK.KN55P.A4Q2TgHxmCb20egoeXH0iBfqBbHyY";
static NSString * const OAuthRedirectURI        = @"testsfdc:///mobilesdk/detect/oauth/done";

@interface AppDelegate ()

/**
 * Convenience method for setting up the main UIViewController and setting self.window's rootViewController
 * property accordingly.
 */
- (void)setupRootViewController;

/**
 * (Re-)sets the view state when the app first loads (or post-logout).
 */
- (void)initializeAppViewState;

@end

@implementation AppDelegate

@synthesize window = _window;

- (id)init
{
    self = [super init];
    if (self) {
        [SFLogger setLogLevel:SFLogLevelDebug];

        [SalesforceSDKManager sharedManager].connectedAppId = RemoteAccessConsumerKey;
        [SalesforceSDKManager sharedManager].connectedAppCallbackUri = OAuthRedirectURI;
        [SalesforceSDKManager sharedManager].authScopes = @[ @"web", @"api" ];
        __weak AppDelegate *weakSelf = self;
        [SalesforceSDKManager sharedManager].postLaunchAction = ^(SFSDKLaunchAction launchActionList) {
            [weakSelf log:SFLogLevelInfo format:@"Post-launch: launch actions taken: %@", [SalesforceSDKManager launchActionsStringRepresentation:launchActionList]];
            [weakSelf setupRootViewController];
        };
        [SalesforceSDKManager sharedManager].launchErrorAction = ^(NSError *error, SFSDKLaunchAction launchActionList) {
            [weakSelf log:SFLogLevelError format:@"Error during SDK launch: %@", [error localizedDescription]];
            [weakSelf initializeAppViewState];
            [[SalesforceSDKManager sharedManager] launch];
        };
        [SalesforceSDKManager sharedManager].postLogoutAction = ^{
            [weakSelf handleSdkManagerLogout];
        };
        [SalesforceSDKManager sharedManager].switchUserAction = ^(SFUserAccount *fromUser, SFUserAccount *toUser) {
            [weakSelf handleUserSwitch:fromUser toUser:toUser];
        };
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self initializeAppViewState];
    
    //
    // If you wish to register for push notifications, uncomment the line below.  Note that,
    // if you want to receive push notifications from Salesforce, you will also need to
    // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
    //
    //[[SFPushNotificationManager sharedInstance] registerForRemoteNotifications];
    //
    
    [[SalesforceSDKManager sharedManager] launch];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //
    // Uncomment the code below to register your device token with the push notification manager
    //
    //[[SFPushNotificationManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    //if ([SFAccountManager sharedInstance].credentials.accessToken != nil) {
    //    [[SFPushNotificationManager sharedInstance] registerForSalesforceNotifications];
    //}
    //
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // Respond to any push notification registration errors here.
}

#pragma mark - Private methods

- (void)initializeAppViewState
{
//    self.window.rootViewController = [[InitialViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
}

- (void)setupRootViewController
{
    ResultViewController *resultViewController = [[ResultViewController alloc] init];
    resultViewController.tabBarItem.title = @"Contact";
    resultViewController.tabBarItem.image = [UIImage imageNamed:@"tab-cont-icn.png"];
    UINavigationController *resultNavigationController = [[UINavigationController alloc]initWithRootViewController:resultViewController];


    TasksListViewController *taskListViewController = [[TasksListViewController alloc] init];
    taskListViewController.tabBarItem.title = @"Tasks";
    taskListViewController.tabBarItem.image = [UIImage imageNamed:@"tab-leads-icn.png"];
    UINavigationController *tasksListNavigationController = [[UINavigationController alloc]initWithRootViewController:taskListViewController];

    /*NewChatterFeedViewController *newChatterFeedViewController = [[NewChatterFeedViewController alloc] init];
    newChatterFeedViewController.tabBarItem.title = @"Chatter";
    newChatterFeedViewController.tabBarItem.image = [UIImage imageNamed:@"tab-cont-icn.png"];
    UINavigationController *newChatterViewNavigationController = [[UINavigationController alloc]initWithRootViewController:newChatterFeedViewController];
    */
    
    ChatterFeedsViewController *chatterFeedsViewController = [[ChatterFeedsViewController alloc] init];
    chatterFeedsViewController.tabBarItem.title = @"Chatter";
    chatterFeedsViewController.tabBarItem.image = [UIImage imageNamed:@"tab-cont-icn.png"];
    UINavigationController *chatterFeedsViewNavigationController = [[UINavigationController alloc]initWithRootViewController:chatterFeedsViewController];
    
    CharacterListViewController *characterListViewController = [[CharacterListViewController alloc] init];
    characterListViewController.tabBarItem.title = @"Character";
    characterListViewController.tabBarItem.image = [UIImage imageNamed:@"tab-cont-icn.png"];
    UINavigationController *characterListViewNavigationController = [[UINavigationController alloc]initWithRootViewController:characterListViewController];


    UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
    userProfileViewController.tabBarItem.title = @"My Profile";
    userProfileViewController.tabBarItem.image = [UIImage imageNamed:@"tab-acont-icn.png"];
    UINavigationController *userProfileViewNavigationController = [[UINavigationController alloc]initWithRootViewController:userProfileViewController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers = @[resultNavigationController,tasksListNavigationController,
                                         chatterFeedsViewNavigationController,
                                         characterListViewNavigationController,
                                         userProfileViewNavigationController];

    

    [[UINavigationBar appearance]setTintColor:[UIColor blackColor]];
    self.window.rootViewController = tabBarController;
}

- (void)resetViewState:(void (^)(void))postResetBlock
{
    if ([self.window.rootViewController presentedViewController]) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            postResetBlock();
        }];
    } else {
        postResetBlock();
    }
}

- (void)handleSdkManagerLogout
{
    [self log:SFLogLevelDebug msg:@"SFAuthenticationManager logged out.  Resetting app."];
    [self resetViewState:^{
        [self initializeAppViewState];
        
        // Multi-user pattern:
        // - If there are two or more existing accounts after logout, let the user choose the account
        //   to switch to.
        // - If there is one existing account, automatically switch to that account.
        // - If there are no further authenticated accounts, present the login screen.
        //
        // Alternatively, you could just go straight to re-initializing your app state, if you know
        // your app does not support multiple accounts.  The logic below will work either way.
        NSArray *allAccounts = [SFUserAccountManager sharedInstance].allUserAccounts;
        if ([allAccounts count] > 1) {
            SFDefaultUserManagementViewController *userSwitchVc = [[SFDefaultUserManagementViewController alloc] initWithCompletionBlock:^(SFUserManagementAction action) {
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
            }];
            [self.window.rootViewController presentViewController:userSwitchVc animated:YES completion:NULL];
        } else {
            if ([allAccounts count] == 1) {
                [SFUserAccountManager sharedInstance].currentUser = ([SFUserAccountManager sharedInstance].allUserAccounts)[0];
            }
            
            [[SalesforceSDKManager sharedManager] launch];
        }
    }];
}

- (void)handleUserSwitch:(SFUserAccount *)fromUser
                  toUser:(SFUserAccount *)toUser
{
    [self log:SFLogLevelDebug format:@"SFUserAccountManager changed from user %@ to %@.  Resetting app.",
     fromUser.userName, toUser.userName];
    [self resetViewState:^{
        [self initializeAppViewState];
        [[SalesforceSDKManager sharedManager] launch];
    }];
}


#pragma mark - WatchKit Extension Call Methods

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply{
    
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"getTasks"]) {
       
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[NSString stringWithFormat:@"SELECT Id, Subject, Type, Description, ActivityDate, Priority, Status FROM Task WHERE Status != 'Completed' AND OwnerId = '%@' ORDER BY ActivityDate",[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId]]];
        [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
            reply(@{ @"error:": e.localizedDescription });
        } completeBlock:^(id response) {
            
            NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:APP_SUITE_NAME];
            [shared setObject:[NSString stringWithFormat:@"%@ %@",[[[[SFUserAccountManager sharedInstance]currentUser]idData]firstName],[[[[SFUserAccountManager sharedInstance]currentUser]idData]lastName]] forKey:@"SFUserName"];
            [shared setObject:[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId] forKey:@"SFUserID"];
            [shared synchronize];
            reply(response);
            
            
        }];
        
    }else if ([[userInfo objectForKey:@"request"] isEqualToString:@"markTaskAsComplete"]) {
        
        NSDictionary *fieldDict = @{@"Status" : @"Completed"};
        
        [[SFRestAPI sharedInstance] performUpdateWithObjectType:@"Task" objectId:[userInfo objectForKey:@"taskID"] fields:fieldDict failBlock:^(NSError *e) {
            
            reply(@{ @"error:": e.localizedDescription });
            
        } completeBlock:^(NSDictionary *dict) {
            
            reply(@{ @"Success": @"Task Completed Successfully" });
        }];
        
    }else if ([[userInfo objectForKey:@"request"] isEqualToString:@"getMarvelCharacter"]) {
        
        NSMutableArray *charactersList = [[NSMutableArray alloc]init];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *stringForHash = [NSString stringWithFormat:@"%@%@%@",TS,MARVEL_PRIVATE_KEY,MARVEL_PUBLIC_KEY];
            NSString *hashString = [Util md5:stringForHash];
            NSURL *marvelCharURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?limit=50&ts=%@&apikey=%@&hash=%@",MARVEL_SERVER_URL,MARVEL_GET_CHAR_API_URL,TS,MARVEL_PUBLIC_KEY,hashString]];
            
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:marvelCharURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                NSError *error1 = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if (error1 != nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        reply(@{ @"error:": error1.localizedDescription });
                        
                    });
                    
                }
                else {
                    
                    NSMutableArray *charInfoArray = [NSMutableArray arrayWithArray:[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"results"]];
                    
                    if (charInfoArray.count > 0) {
                        for (int count = 0; count < [charInfoArray count]; count++) {
                            
                            NSString *imageURL;
                            if ([charInfoArray objectAtIndex:count]!=nil) {
                                
                                if ([[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"] != [NSNull null] && [[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"path"]!= [NSNull null] && [[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"extension"] != [NSNull null]) {
                                    
                                    imageURL = [NSString stringWithFormat:@"%@/%@.%@",[[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"path"],IMAGE_TYPE_PLACEHOLDER,[[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"extension"]];
                                    
                                    NSLog(@"NAME %d/%lu : %@ \n URL %@",count,(unsigned long)[charInfoArray count],[[charInfoArray objectAtIndex:count] objectForKey:@"name"],imageURL);
                                    
                                    if ([imageURL rangeOfString:@"image_not_available"].location == NSNotFound) {
                                        
                                        NSString *characterID = [[charInfoArray objectAtIndex:count] objectForKey:@"id"];
                                        NSString *characterName = [[charInfoArray objectAtIndex:count] objectForKey:@"name"];
                                        
                                        NSDictionary *infoDict = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:characterName,characterID,imageURL,[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId], nil] forKeys:[NSArray arrayWithObjects:@"Name",@"Marvel_Char_ID__c",@"Badge_Image_URL__c",@"user_ID__c", nil]];
                                        
                                        [charactersList addObject:infoDict];
                                       
                                    }
                                }
                                
                            }
                            
                        }
                        
                        reply(@{@"Success": charactersList});
                    }else {
                        
                        reply(@{ @"error:": @"Not found marvel character" });
                      
                    }
                    
                }
                
            }];
        });
    }else if ([[userInfo objectForKey:@"request"] isEqualToString:@"checkUserBadgeRequest"]) {
        
        NSMutableArray *charactersList = [userInfo objectForKey:@"charactersList"];
        
        if (![charactersList isEqual:[NSNull null]] && [charactersList count]>0) {
            
            int rIndex = arc4random() % [charactersList count];
            NSDictionary *badgeInfoDict = [[NSDictionary alloc]initWithDictionary:[charactersList objectAtIndex:rIndex]];
            
            SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[NSString stringWithFormat:@"SELECT Id,Name,Badge_Image_URL__c,Marvel_Char_ID__c FROM Badge__c WHERE user_ID__c = '%@'",[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId]]];
            
            [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
                
                reply(@{ @"error:": @"Fetch Badge Request Failed" });
                
            } completeBlock:^(id response) {
                
                NSLog(@"Badge Fetch Response :%@",response);
                NSArray *records = response[@"records"];
                
                
                if (nil != records && records.count == 10) {
                    
                    reply(@{ @"Success": @"Congratulations, You already have 10 badges" });
                    
                } else {
                    
                    BOOL badgeExists = false;
                    if (nil != records && records.count >0) {
                        
                        for (int recordCnt = 0; recordCnt< records.count; recordCnt++) {
                            
                            NSDictionary *recordDict = [records objectAtIndex:recordCnt];
                            NSLog(@"if (%@ == %@)",[recordDict objectForKey:@"Marvel_Char_ID__c"],[badgeInfoDict objectForKey:@"Marvel_Char_ID__c"]);
                            if ([recordDict objectForKey:@"Marvel_Char_ID__c"]!=nil)
                            {
                                
                                
                                if([[NSString stringWithFormat:@"%@",[recordDict valueForKey:@"Marvel_Char_ID__c"] ] isEqualToString:[NSString stringWithFormat:@"%@",[badgeInfoDict valueForKey:@"Marvel_Char_ID__c"]]]) {
                                    
                                    badgeExists = true;
                                    break;
                                }
                            }
                        }
                    }
                    if(badgeExists == true){
                        
                        reply(@{ @"Success": @"Badge Exists True" });
                        
                    }else {
                        
                        reply(@{ @"Success": @"Badge Exists False",@"BadgeDetail":badgeInfoDict });
                    }
                }
            }];

        }else {
            
            reply(@{ @"error:": @"Not Have any character" });
        }
    }else if ([[userInfo objectForKey:@"request"] isEqualToString:@"createNewBadgeRequest"]) {
        
        NSDictionary *badgeInfoDict = [userInfo objectForKey:@"BadgeDetail"];
        
        [[SFRestAPI sharedInstance] performCreateWithObjectType:@"Badge__c" fields:badgeInfoDict failBlock:^(NSError *e) {
            
            reply(@{ @"error:": @"Badge Create Request Failed" });
            
        } completeBlock:^(NSDictionary *dict) {
           
            NSLog(@"Badge Create Response :%@",dict);
            
            if([[dict objectForKey:@"errors"] count]==0)
            {
                
                BOOL status = [dict objectForKey:@"success"];
                if (status == true) {
                    NSString *newObjectID = [NSString stringWithString:[dict valueForKey:@"id"]];
                    
                    NSLog(@"ID = %@",newObjectID);
                    
                    reply(@{ @"Success": @"Badge Created Successfully",@"BadgeDetail":badgeInfoDict,@"objectID":newObjectID });
                }
                
            }
            else
            {
                reply(@{ @"error:": @"Badge Create Request Failed" });
            }
        }];
    }else if ([[userInfo objectForKey:@"request"] isEqualToString:@"fetchUserBadgeRequest"]) {
        
        NSString *userID = [userInfo objectForKey:@"userID"];
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[NSString stringWithFormat:@"SELECT Badge1__c,Badge2__c,Badge3__c,Badge4__c,Badge5__c,Badge6__c,Badge7__c,Badge8__c,Badge9__c,Badge10__c FROM User WHERE Id = '%@'",userID]];
        [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
            
            reply(@{ @"error:": @"Error in badge fetch" });
            
        } completeBlock:^(id response) {
            
            NSLog(@"Badge Fetch Response :%@",response);
            NSArray *records = response[@"records"];
            if (nil != records) {
                NSDictionary *firstRecord = records[0];
                if (nil != firstRecord) {
                    
                    NSString *badgeNumberTobeAssigned = @"";
                    if ([firstRecord objectForKey:@"Badge1__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge1__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge2__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge2__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge3__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge3__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge4__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge4__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge5__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge5__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge6__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge6__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge7__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge7__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge8__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge8__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge9__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge9__c";
                        
                    }else if ([firstRecord objectForKey:@"Badge10__c"] == (id)[NSNull null]) {
                        
                        badgeNumberTobeAssigned = @"Badge10__c";
                    }
                    
                    if (badgeNumberTobeAssigned!=nil && ![badgeNumberTobeAssigned isEqualToString:@""]) {
                        
                    
                        reply(@{ @"Success": @"Fetch User Badge Success",@"badgeNumberTobeAssigned":badgeNumberTobeAssigned});
                        
                        
                    } else {
                        
                        reply(@{ @"error:": @"Error in badge fetch request" });
                    }
                }else {
                    reply(@{ @"error:": @"Error in badge fetch request" });
                }
            }else {
                reply(@{ @"error:": @"Error in badge fetch request" });
            }
        }];
    }else if ([[userInfo objectForKey:@"request"] isEqualToString:@"assignBadgeToUserRequest"]) {
        
        NSDictionary *fieldDict = [userInfo objectForKey:@"fieldDict"];
        
        [[SFRestAPI sharedInstance] performUpdateWithObjectType:@"User" objectId:[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId] fields:fieldDict failBlock:^(NSError *e) {
         
            reply(@{ @"error:": e.localizedDescription });
         
        } completeBlock:^(NSDictionary *dict) {
         
            reply(@{ @"Success": @"Badge assigned successfully"});
         
         }];
    }
}



@end
