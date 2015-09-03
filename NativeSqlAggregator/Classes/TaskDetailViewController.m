//
//  TaskDetailViewController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 20/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "Util.h"
#import "ChatterRecord.h"
#import "SFRestAPI+Blocks.h"

@interface TaskDetailViewController ()

@end

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.charactersList = [[NSMutableArray alloc] init];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784/portrait_incredible.jpg"];
    [self.backgroundImgView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    
    CALayer * l = [self.profileImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor blackColor] CGColor]];

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Mark as Completed" style:UIBarButtonItemStyleDone target:self action:@selector(updateTaskStatus)];
    
    ChatterRecord *chatterRec = [[ChatterRecord alloc]init];
    chatterRec.chatterActorName = [[[[SFUserAccountManager sharedInstance]currentUser] idData]username];
    chatterRec.imageURLString = [[[[[SFUserAccountManager sharedInstance]currentUser] idData]thumbnailUrl]absoluteString];
    
    [self startIconDownload:chatterRec forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [self.userName setText:[NSString stringWithFormat:@"%@ %@",[[[[SFUserAccountManager sharedInstance]currentUser]idData]firstName],[[[[SFUserAccountManager sharedInstance]currentUser]idData]lastName]]];
    [self.taskStatus setText:[Util getValueFor:@"Status" inJSON:self.taskDetailDict]];
    [self.taskType setText:[Util getValueFor:@"Type" inJSON:self.taskDetailDict]];
    [self.subject setText:[Util getValueFor:@"Subject" inJSON:self.taskDetailDict]];
    [self.dueDate setText:[Util getValueFor:@"ActivityDate" inJSON:self.taskDetailDict]];
    [self.priority setText:[Util getValueFor:@"Priority" inJSON:self.taskDetailDict]];
    [self.comments setText:[Util getValueFor:@"Description" inJSON:self.taskDetailDict]];
    self.customVC = [[CustomAlertViewController alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)startIconDownload:(ChatterRecord *)chatterFeedRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.chatterRecord = chatterFeedRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload:@"Chatter"];
    }
}


// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        self.profileImage.image = iconDownloader.chatterRecord.chatterActorIcon;
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)updateTaskStatus {
    
    NSDictionary *fieldDict = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObject:@"Completed"] forKeys:[NSArray arrayWithObject:@"Status"]];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    SFRestRequest *request = [[SFRestAPI sharedInstance] performUpdateWithObjectType:@"Task" objectId:[self.taskDetailDict objectForKey:@"Id"] fields:fieldDict failBlock:^(NSError *e) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completion Failed" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
        });
        
    } completeBlock:^(NSDictionary *dict) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Response Dict on task completion :%@",dict);
            [self getMarvelCharactersList];
        });
        
    }];
    
     NSLog(@"Task Update Request :%@",request);
    
}

-(void)getMarvelCharactersList
{
    
    NSString *stringForHash = [NSString stringWithFormat:@"%@%@%@",TS,MARVEL_PRIVATE_KEY,MARVEL_PUBLIC_KEY];
    NSString *hashString = [Util md5:stringForHash];
    NSURL *marvelCharURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?limit=50&ts=%@&apikey=%@&hash=%@",MARVEL_SERVER_URL,MARVEL_GET_CHAR_API_URL,TS,MARVEL_PUBLIC_KEY,hashString]];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:marvelCharURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSError *error1 = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error1 != nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"Error parsing JSON.");
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completed Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            });
            
        }
        else {
            
            NSLog(@"Status %@ Limit %@",[jsonDict objectForKeyedSubscript:@"status"],[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"limit"]);
            
            NSMutableArray *charInfoArray = [NSMutableArray arrayWithArray:[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"results"]];
            
            NSLog(@"Characters Data :%@",[jsonDict objectForKeyedSubscript:@"data"]);
            
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
                            
                            [self.charactersList addObject:infoDict];
                        }
                    }
                    
                }
                
            }
            
            NSLog(@"Response of character Images with their id :%@",self.charactersList);
            if (![self.charactersList isEqual:[NSNull null]] && [self.charactersList count]>0) {
                [self createNewBadgeWithRandomCharacter];
            }else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"Error parsing JSON.");
                    [SVProgressHUD dismiss];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completed Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                });
            }
        }
        
        
    }];
}

- (void)createNewBadgeWithRandomCharacter {
    int rIndex = arc4random() % [self.charactersList count];
    NSDictionary *badgeInfoDict = [[NSDictionary alloc]initWithDictionary:[self.charactersList objectAtIndex:rIndex]];
    
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[NSString stringWithFormat:@"SELECT Id,Name,Badge_Image_URL__c,Marvel_Char_ID__c FROM Badge__c WHERE user_ID__c = '%@'",[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId]]];
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completed Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
        
    } completeBlock:^(id response) {
        
        NSLog(@"Badge Fetch Response :%@",response);
        NSArray *records = response[@"records"];
        BOOL badgeExists = false;
        
        if (nil != records && records.count > 0) {
            
            if (records.count == 10) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Congratulations" message:@"You already have 10 badges" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                });
                return ;
                
            } else {
        
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
        }
        
        if(badgeExists == true){
            
            [self createNewBadgeWithRandomCharacter];
            
        }else {
            
            
            SFRestRequest *request = [[SFRestAPI sharedInstance] performCreateWithObjectType:@"Badge__c" fields:badgeInfoDict failBlock:^(NSError *e) {
                
                NSLog(@"Error for create Badge :%@",e);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completed Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                });
                
            } completeBlock:^(NSDictionary *dict) {
                NSLog(@"Badge Create Response :%@",dict);
                
                if([[dict objectForKey:@"errors"] count]==0)
                {
                    
                    BOOL status = [dict objectForKey:@"success"];
                    if (status == true) {
                        NSString *newObjectID = [NSString stringWithString:[dict valueForKey:@"id"]];
                        
                        NSLog(@"ID = %@",newObjectID);
                        
                        [self assignBadgeToUser:newObjectID WithBadgeDetail:badgeInfoDict];
                    }
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completed Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    });
                }
            }];
            
            NSLog(@"update image with id request :%@",request);
        }
        
    }];

    
    
    
}

- (void)assignBadgeToUser:(NSString*)badgeID WithBadgeDetail:(NSDictionary*)badgeDetail{
    
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[NSString stringWithFormat:@"SELECT Badge1__c,Badge2__c,Badge3__c,Badge4__c,Badge5__c,Badge6__c,Badge7__c,Badge8__c,Badge9__c,Badge10__c FROM User WHERE Id = '%@'",[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId]]];
     [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
         
         NSLog(@"Error for fetching badge :%@",e);
         dispatch_async(dispatch_get_main_queue(), ^{
             [SVProgressHUD dismiss];
             UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completed Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         });
         
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
                 
                 if (badgeNumberTobeAssigned!=nil && ![badgeNumberTobeAssigned isEqualToString:@""] && badgeID!=nil) {
                     
                     NSDictionary *fieldDict = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObject:badgeID] forKeys:[NSArray arrayWithObject:badgeNumberTobeAssigned]];
                     
                     [[SFRestAPI sharedInstance] performUpdateWithObjectType:@"User" objectId:[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId] fields:fieldDict failBlock:^(NSError *e) {
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [SVProgressHUD dismiss];
                             UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Task Completed Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                             [alertView show];
                         });
                         
                     } completeBlock:^(NSDictionary *dict) {
                         
                         NSLog(@"Badge Assign Response :%@ %@",dict,badgeDetail);
                    
                         
                         
                         
                         
                         if (badgeDetail != nil) {
                                 
                            
                            NSString *characterName = [Util getValueFor:@"Name" inJSON:badgeDetail];
                           
                            NSString *imageStr = [Util getValueFor:@"Badge_Image_URL__c" inJSON:badgeDetail];
                                 
                            NSURL *characterImageURL = [NSURL URLWithString:[imageStr stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
                                 
                           
                             self.customVC.msgStr = [NSString stringWithFormat:@"%@ badge assigned",characterName];
                             self.customVC.imageURL = characterImageURL;
                                 
                             NSLog(@"character Image URL :%@ msg :%@",characterImageURL,[NSString stringWithFormat:@"%@ badge assigned",characterName]);

                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [SVProgressHUD dismiss];
                                
                             });
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.navigationController pushViewController:self.customVC animated:YES];                                 
                             });

                             
                             
                         } else {
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [SVProgressHUD dismiss];
                                 
                             });
                         }
                         
                         
                        
                         
                     }];
                     
                 } else {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [SVProgressHUD dismiss];
                         
                     });
                 }
             }
         }
     }];
    
}



@end
