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
 */

#import "RootViewController.h"

#import <SalesforceRestAPI/SFRestAPI.h>
#import <SalesforceRestAPI/SFRestRequest.h>
#import "SmartStoreInterface.h"
#import "ResultViewController.h"
#import <SalesforceSDKCore/SFAuthenticationManager.h>

@implementation RootViewController

@synthesize smartStoreIntf,charactersImageList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        smartStoreIntf = [[SmartStoreInterface alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.smartStoreIntf = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    charactersImageList = [[NSMutableArray alloc]init];
    [self getMarvelCharactersList];
    self.FetchSFDCContacts.layer.cornerRadius = 5.0;
    self.ClearOfflineStore.layer.cornerRadius = 5.0;
    self.ShowSFDCContacts.layer.cornerRadius = 5.0;
    
    SFIdentityData *idData = [SFAuthenticationManager sharedManager].idCoordinator.idData;
    
   NSLog(@"ImageURL :%@",idData.pictureUrl);
    
    NSLog(@"Access Token :%@",[SFAuthenticationManager sharedManager].idCoordinator.credentials.accessToken);
    
    
    //  NSData *data = [NSData dataWithContentsOfURL:idData.thumbnailUrl];
//    [self.testImageView setImage:[UIImage imageWithData:data]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:idData.thumbnailUrl] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"Response :%@ data:%@ Erorr :%@",response,data,error);
   //     NSData *imageData = [data copy];
//      [self.testImageView setBackgroundColor:[UIColor blackColor]];
//      [self.testImageView setImage: [UIImage imageWithData:imageData]];
    }];
    
    self.title = @"SalesForce Marvels";
    
}

- (void)request:(SFRestRequest *)request didLoadResponse:(id)dataResponse
{
    NSArray *records = dataResponse[@"records"];
    if (nil != records) {
        NSDictionary *firstRecord = records[0];
        if (nil != firstRecord) {
            NSDictionary *attributes = [firstRecord valueForKey:@"attributes"];
            if (nil != attributes) {
                NSString *type = [attributes valueForKey:@"type"];
//                if ([type isEqual:@"Account"]) {
//                    [self.smartStoreIntf insertAccounts:records];
//                } else if ([type isEqual:@"Opportunity"]) {
//                    [self.smartStoreIntf insertOpportunities:records];
//                }
                if ([type isEqual:@"Contact"]) {
                    NSLog(@"Records : %@",records);
                    [self.smartStoreIntf insertContacts:records];
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
}

- (void)requestDidCancelLoad:(SFRestRequest *)request
{
    [self log:SFLogLevelDebug format:@"REST request canceled. Request: %@", request];
}

- (void)requestDidTimeout:(SFRestRequest *)request
{
    [self log:SFLogLevelDebug format:@"REST request timed out. Request: %@", request];
}

- (IBAction)btnSaveRecOfflinePressed:(id)sender
{
//    [self.smartStoreIntf createAccountsSoup];
//    [self.smartStoreIntf createOpportunitiesSoup];
    [self.smartStoreIntf createContactSoup];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name, Id,PhotoUrl FROM Contact"];
    [[SFRestAPI sharedInstance] send:request delegate:self];
//    request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name, Id, AccountId, OwnerId, Amount FROM Opportunity"];
//    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (IBAction)btnClearOfflineStorePressed:(id)sender
{
    [self.smartStoreIntf deleteAccountsSoup];
    [self.smartStoreIntf deleteOpportunitiesSoup];
    [self.smartStoreIntf createAccountsSoup];
    [self.smartStoreIntf createOpportunitiesSoup];
}

- (IBAction)btnRunReportPressed:(id)sender
{
    NSArray *results = [self.smartStoreIntf query:kAllContactsQuery];
    ResultViewController *resultVC = [[ResultViewController alloc] initWithNibName:nil bundle:nil];
    [resultVC setResultDataSet:results];
    [resultVC setCharactarListArray:charactersImageList];
    [[self navigationController] pushViewController:resultVC animated:YES];
}

-(void)getMarvelCharactersList
{
    NSURL *marvelCharURL = [NSURL URLWithString:@"http://gateway.marvel.com/v1/public/characters?limit=99&ts=1&apikey=881c39be03bfea051ce0ac8bbb059ed5&hash=85864f63858ba05aaa6afbf14c92378e"];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:marvelCharURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSError *error1 = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error1 != nil) {
            NSLog(@"Error parsing JSON.");
        }
        else {
            NSLog(@"Status %@ Limit %@",[jsonDict objectForKeyedSubscript:@"status"],[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"limit"]);
            NSMutableArray *charInfoArray = [NSMutableArray arrayWithArray:[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"results"]];

//            NSMutableArray *charactersImageList = [[NSMutableArray alloc]init];
            for (int count = 0; count < [charInfoArray count]; count++) {
                NSString *imageURL = [NSString stringWithFormat:@"%@/standard_medium.%@",[[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"path"],[[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"extension"]];
                                      
                NSLog(@"NAME %d : %@ \n URL %@",count,[[charInfoArray objectAtIndex:count] objectForKey:@"name"],imageURL);
                [charactersImageList addObject:imageURL];
            }
            
        }


    }];
}

@end
