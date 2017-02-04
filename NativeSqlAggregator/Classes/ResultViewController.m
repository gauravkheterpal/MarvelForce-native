/*
 Copyright (c) 2013, salesforce.com, inc. All rights reserved.
 
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
 
 Created by Bharath Hariharan on 6/13/13.
 */

#import "ResultViewController.h"
#import "SmartStoreInterface.h"
#import <SalesforceRestAPI/SFRestAPI.h>
#import <SalesforceRestAPI/SFRestRequest.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>

@implementation ResultViewController
@synthesize resultDataSet,charactarListArray,smartStoreIntf;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        smartStoreIntf = [[SmartStoreInterface alloc] init];
        resultDataSet = [[NSArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.resultDataSet = nil;
    self.smartStoreIntf = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    SFIdentityData *idData = [SFAuthenticationManager sharedManager].idCoordinator.idData;
    //    NSLog(@"Access Token :%@",[SFAuthenticationManager sharedManager].idCoordinator.credentials.accessToken);
    self.title = @"Contacts";
    //    [self fetchSFDCContacts];
    
    self.charactersImageWithIDList = @[].mutableCopy;
    
    [self getMarvelCharactersList];
    
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/6/70/4cd061e6d6573/portrait_incredible.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    [backgroundImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
    //[self.tableView setBackgroundView:backgroundImageView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    int count = 0;
    //    if (nil != self.resultDataSet) {
    //        count = [self.resultDataSet count] + 1;
    //    }
    return [self.resultDataSet count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:resultDataSet[indexPath.row]];
    NSLog(@"item == %@",item);
    NSString *contactName = [item valueForKey:@"Name"];
    cell.textLabel.text = contactName;
    
    NSString *recordMarvelImage = [item valueForKey:MARVEL_IMAGE_URL_FIELD_NAME];
    if (recordMarvelImage == (id)[NSNull null] || [recordMarvelImage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 )
    {
        if(self.charactersImageWithIDList != nil && self.charactersImageWithIDList.count > 0) {
            
            int position = 0;
            if (indexPath.row < self.charactersImageWithIDList.count)
                position = (int)indexPath.row;
            else
                position = (int)(indexPath.row%self.charactersImageWithIDList.count);
            
            NSURL *imageURL = [NSURL URLWithString:[[[self.charactersImageWithIDList objectAtIndex:position] objectForKey:@"marvel_image_url"] stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
            NSLog(@"URL = %@",imageURL);
            [cell.imageView sd_setImageWithURL:imageURL
                              placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
        }
    }
    else
        
    {
        NSURL *imageURL = [NSURL URLWithString:[recordMarvelImage stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
        NSLog(@"URL = %@",imageURL);
        [cell.imageView sd_setImageWithURL:imageURL
                          placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    backgroundView.backgroundColor = [UIColor lightTextColor];
    backgroundView.alpha = 0.7;
    cell.backgroundView = backgroundView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    
    NSMutableDictionary *selectedRecord = [[NSMutableDictionary alloc] initWithDictionary:[resultDataSet objectAtIndex:indexPath.row]];
    if (self.charactersImageWithIDList!=nil && self.charactersImageWithIDList.count > 0) {
        int position = 0;
        if (indexPath.row < self.charactersImageWithIDList.count)
            position = (int)indexPath.row;
        else
            position = (int)(indexPath.row%self.charactersImageWithIDList.count);
        
        NSString *charImageURL = [[NSString alloc] initWithString:[[self.charactersImageWithIDList objectAtIndex:position] objectForKey:@"marvel_image_url"]];
        NSString *charID = [NSString stringWithFormat:@"%@",[[self.charactersImageWithIDList objectAtIndex:position] objectForKey:@"marvel_char_id"]];
        [selectedRecord setValue:charImageURL forKey:@"CharImageURL"];
        [selectedRecord setValue:charID forKey:@"CharID"];
    }
    
    
    NSLog(@"Selected Record :%@",selectedRecord);
    ContactDetailViewController *contactDetailViewController = [[ContactDetailViewController alloc]init];
    contactDetailViewController.recordDict = selectedRecord;
    [self.navigationController pushViewController:contactDetailViewController animated:YES];
    
}

-(void)fetchSFDCContacts
{
    [self.smartStoreIntf createContactSoup];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:SF_CONTACT_QUERY];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

-(void)getMarvelCharactersList
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *stringForHash = [NSString stringWithFormat:@"%@%@%@",TS,MARVEL_PRIVATE_KEY,MARVEL_PUBLIC_KEY];
    NSString *hashString = [Util md5:stringForHash];
    NSURL *marvelCharURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?limit=50&ts=%@&apikey=%@&hash=%@",MARVEL_SERVER_URL,MARVEL_GET_CHAR_API_URL,TS,MARVEL_PUBLIC_KEY,hashString]];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:marvelCharURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSError *error1 = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error1 != nil) {
            NSLog(@"Error parsing JSON.");
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
                            
                            NSDictionary *infoDict = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:imageURL,characterID, nil] forKeys:[NSArray arrayWithObjects:@"marvel_image_url",@"marvel_char_id", nil]];
                            
                            [self.charactersImageWithIDList addObject:infoDict];
                        }
                    }
                    
                }
                
            }
            
            NSLog(@"Response of character Images with their id :%@",self.charactersImageWithIDList);
            
            [self fetchSFDCContacts];
        }
        
        
    }];
}

- (void)request:(SFRestRequest *)request didLoadResponse:(id)dataResponse
{
    NSLog(@"dataResponse%@",dataResponse);
    NSArray *records = dataResponse[@"records"];
    if (nil != records) {
        NSDictionary *firstRecord = records[0];
        if (nil != firstRecord) {
            NSDictionary *attributes = [firstRecord valueForKey:@"attributes"];
            if (nil != attributes) {
                NSString *type = [attributes valueForKey:@"type"];
                if ([type isEqual:@"Contact"]) {
                    NSLog(@"Records : %@",records);
                    //                    [self.smartStoreIntf insertContacts:records];
                    //                    NSArray *results = [self.smartStoreIntf query:kAllContactsQuery];
                    [self setResultDataSet:records];
                    [self updateMarvelImageURLWithID];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        // time-consuming task
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                        });
                    });
                }
                else {
                    /*
                     * If the object is not an account or opportunity,
                     * we do nothing. This block can be used to save
                     * other types of records.
                     */
                }
            }
        }
    }
}

- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error
{
    [self log:SFLogLevelError format:@"REST request failed with error: %@", error];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

- (void)requestDidCancelLoad:(SFRestRequest *)request
{
    [self log:SFLogLevelDebug format:@"REST request canceled. Request: %@", request];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

- (void)requestDidTimeout:(SFRestRequest *)request
{
    [self log:SFLogLevelDebug format:@"REST request timed out. Request: %@", request];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

- (void)updateMarvelImageURLWithID {
    
    if (self.charactersImageWithIDList !=  nil && self.charactersImageWithIDList.count > 0) {
        int recordCount = (int)[self.resultDataSet count];
        
        for( int index = 0; index < recordCount;index++)
        {
            NSDictionary *item = [[NSDictionary alloc]initWithDictionary:[self.resultDataSet objectAtIndex:index]];
            NSString *recordID = [item valueForKey:@"Id"];
            NSString *recordMarvelImage = [item valueForKey:MARVEL_IMAGE_URL_FIELD_NAME];
            NSString *recordMarvelCharID = [item valueForKey:MARVEL_CHAR_ID_FIELD_NAME];
            
            int position = 0;
            if (index < self.charactersImageWithIDList.count)
                position = (int)index;
            else
                position = (int)(index%self.charactersImageWithIDList.count);
            
            NSString *imageURLStr;
            if (recordMarvelImage == (id)[NSNull null] || [recordMarvelImage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 )
            {
                if ([self.charactersImageWithIDList objectAtIndex:position]!=nil) {
                    imageURLStr = [[[self.charactersImageWithIDList objectAtIndex:position] objectForKey:@"marvel_image_url"] stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM];
                }
                
                
                
            }
            
            NSString *charIDStr;
            
            if (recordMarvelCharID == (id)[NSNull null] || [recordMarvelCharID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 ) {
                
                charIDStr = [[self.charactersImageWithIDList objectAtIndex:position] objectForKey:@"marvel_char_id"];
                
            }
            
            NSDictionary *fieldDict;
            if (imageURLStr != nil && charIDStr != nil) {
                
                fieldDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:charIDStr,imageURLStr, nil] forKeys:[NSArray arrayWithObjects:MARVEL_CHAR_ID_FIELD_NAME,MARVEL_IMAGE_URL_FIELD_NAME,nil]];
                
            }else if (imageURLStr != nil) {
                
                fieldDict = [NSDictionary dictionaryWithObject:imageURLStr forKey:MARVEL_IMAGE_URL_FIELD_NAME];
                
            }else if (charIDStr != nil) {
                
                fieldDict = [NSDictionary dictionaryWithObject:charIDStr forKey:MARVEL_CHAR_ID_FIELD_NAME];
            }
            
            if (fieldDict!=nil) {
                SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:@"Contact" objectId:recordID fields:fieldDict];
                NSLog(@"update image with id request :%@",request);
                [[SFRestAPI sharedInstance] send:request delegate:nil];
            }
            
            
        }
        
    }
}

@end
