//
//  UserProfileViewController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 21/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "UserProfileViewController.h"
#import "ChatterRecord.h"
#import "BadgeCollectionViewCell.h"
#import "SFRestAPI+Blocks.h"
#import "Util.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.title = @"My Profile";
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.userBadgeArray = [[NSMutableArray alloc]init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/9/50/4ce18691cbf04/portrait_incredible.jpg"];
    [self.backgroundImgView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    
    CALayer * l = [self.userProfile layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor blackColor] CGColor]];
    
    
    [self.userName setText:[NSString stringWithFormat:@"%@ %@",[[[[SFUserAccountManager sharedInstance]currentUser]idData]firstName],[[[[SFUserAccountManager sharedInstance]currentUser]idData]lastName]]];
    
    ChatterRecord *chatterRec = [[ChatterRecord alloc]init];
    chatterRec.chatterActorName = [[[[SFUserAccountManager sharedInstance]currentUser] idData]username];
    chatterRec.imageURLString = [[[[[SFUserAccountManager sharedInstance]currentUser] idData]thumbnailUrl]absoluteString];
    
    [self startIconDownload:chatterRec forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UINib *cellNib = [UINib nibWithNibName:@"BadgeCollectionViewCell" bundle:nil];
    [self.badgesCollection registerNib:cellNib forCellWithReuseIdentifier:@"BadgeCollectionViewCell"];
    
    [self fetchBadges];
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
        self.userProfile.image = iconDownloader.chatterRecord.chatterActorIcon;
    }
    
    
}

-(void)fetchBadges
{
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[NSString stringWithFormat:@"SELECT Badge1__c,Badge2__c,Badge3__c,Badge4__c,Badge5__c,Badge6__c,Badge7__c,Badge8__c,Badge9__c,Badge10__c FROM User WHERE Id = '%@'",[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId]]];
    
    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Get Badge is Failed" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            
        });
        
    } completeBlock:^(id response) {
        
        NSLog(@"Badge Fetch Response :%@",response);
        NSArray *records = response[@"records"];
        if (nil != records && records.count > 0) {
            NSDictionary *firstRecord = records[0];
            if (nil != firstRecord) {
                
                NSMutableArray *badgeArray = [[NSMutableArray alloc]init];
                
                if ([firstRecord objectForKey:@"Badge1__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge1__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge2__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge2__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge3__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge3__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge4__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge4__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge5__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge5__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge6__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge6__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge7__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge7__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge8__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge8__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge9__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge9__c"]];
                    
                }
                if ([firstRecord objectForKey:@"Badge10__c"] != (id)[NSNull null]) {
                    
                    [badgeArray addObject:[firstRecord objectForKey:@"Badge10__c"]];
                }
                
                SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Id,Name,Badge_Image_URL__c FROM Badge__c"];
                
                [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    
                } completeBlock:^(id response) {
                    
                    NSLog(@"Badge Fetch Response :%@",response);
                    NSArray *records = response[@"records"];
                    if (nil != records && records.count > 0) {
                        
                        for (int cnt=0; cnt<badgeArray.count; cnt++) {
                            
                            for (int recordCnt = 0; recordCnt< records.count; recordCnt++) {
                                
                                NSDictionary *recordDict = [records objectAtIndex:recordCnt];
                                if ([recordDict objectForKey:@"Id"]!=nil && [[recordDict objectForKey:@"Id"] isEqualToString:[badgeArray objectAtIndex:cnt]]) {
                                    [self.userBadgeArray addObject:recordDict];
                                    break;
                                }
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            self.badgesCollection.delegate = self;
                            self.badgesCollection.dataSource = self;
                            [self.badgesCollection reloadData];
                        });
                        
                    }else {
                        
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
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    }];
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.userBadgeArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(65, 100);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"BadgeCollectionViewCell";
    
    BadgeCollectionViewCell *cell =  (BadgeCollectionViewCell *)[collectionView
                                                                 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    
    NSDictionary *badgeDetailDict = [self.userBadgeArray objectAtIndex:indexPath.row];
    NSURL *badgeImageURL = [NSURL URLWithString:[[badgeDetailDict objectForKey:@"Badge_Image_URL__c"] stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
    
    CALayer * l = [cell.badgeImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    
    [cell.badgeImage sd_setImageWithURL:badgeImageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    cell.badgeName.text = [badgeDetailDict objectForKey:@"Name"];
    cell.userInteractionEnabled = NO;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
