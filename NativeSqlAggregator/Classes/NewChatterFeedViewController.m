//
//  NewChatterFeedViewController.m
//  SocialForce
//
//  Created by vish on 17/05/13.
//  Copyright (c) 2013 Metacube. All rights reserved.
//

 #import <QuartzCore/QuartzCore.h> 
#import "NewChatterFeedViewController.h"
#import "Util.h"
#import "SFRestRequest.h"
#import "SFRestAPI.h"
#import "SFRestAPI+Files.h"
//#import "ChatterUsersViewController.h"
//#import <FacebookSDK/FacebookSDK.h>

#define SOCIAL_IMAGE_TAG 1121
#define NAME_TAG 1131
#define SWITCH_TAG 1141
@interface NewChatterFeedViewController (){
    int linkedInPublishStatus;
    int facebookPublishStatus;
    int twitterPublishStatus;
}
//@property (strong, nonatomic) FBRequestConnection *requestConnection;
@end

@implementation NewChatterFeedViewController
@synthesize socialShareOptions,loadingSpinner;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    haveAttachment = NO;
    self.socialShareOptions.allowsSelection = NO;
    self.charactersInfoWithImageArray = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *closeButton=[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeTapped)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    UIBarButtonItem *postButton=[[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postTap)];
    self.navigationItem.rightBarButtonItem = postButton;

//    self.title = @"Chatter";
    if(UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad) {
        self.textField.autoresizingMask  = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/4/60/52695285d6e7e/portrait_incredible.jpg"];
    [backgroundImgView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    
    [[self.textField layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [[self.textField layer] setBorderWidth:2];
    [[self.textField layer] setCornerRadius:3];
    [self.textField setFont:[UIFont boldSystemFontOfSize:15]];
    
    [[self.addMarvelOutlet layer] setCornerRadius:2];
    
    [[attachedMavelView layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [[attachedMavelView layer] setBorderWidth:1];
    [[attachedMavelView layer] setCornerRadius:3];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(haveAttachment == YES)
        attachedMavelView.hidden = NO;
    else
        attachedMavelView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeTapped{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)postTap{
    NSLog(@"Post Tapped");
    if([self.textField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Chatter" message:@"Enter any text to make new chatter post." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([self.textField.text length] >1000) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SocialForce" message:CHATTER_LIMIT_CROSSED_ALERT_MSG delegate:self cancelButtonTitle:ALERT_NEGATIVE_BUTTON_TEXT otherButtonTitles:ALERT_POSITIVE_BUTTON_TEXT, nil];
        alert.tag = CHATTER_POST_LIMIT_ALERT_TAG;
        [alert show];
    }
    else
    {
        [self postToChatterWall];
    }

}


#pragma mark - SFRestAPIDelegate
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
    NSLog(@"request:%@",[request description]);
    NSLog(@"jsonResponse:%@",jsonResponse);
    
//    NSInteger statusCode = [(NSHTTPURLResponse *)jsonResponse statusCode];
//    if (statusCode == 200) {
        NSString *url = [request path];
        if ([url rangeOfString:POST_TO_USER_WALL_URL].location != NSNotFound || [url rangeOfString:POST_TO_CHATTER_WALL_URL].location != NSNotFound ) {
            NSLog(@"Response for chatter post");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resetChatterView];
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chatter Successfully Posted On Wall"
                                                                message:@""
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            });
            
        }
        else
        {
            NSLog(@"### Upload file response ###");
            NSString *attachemtId = [jsonResponse valueForKey:@"id"];
            if(attachemtId != nil)
            {
                [self createFeedForAttachmentID:attachemtId];
            }
            else
            {
                NSLog(@"Some Error in fetching attachment ID");
            }
        }
//    }
    
}

- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@ code:%ld path:%@", error,(long)error.code,request.path);
    NSLog(@"request:didFailLoadWithError:error.userInfo :%@",error.userInfo);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
    NSString *alertMessaage ;
    if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"STRING_TOO_LONG"]) {
        alertMessaage = CHATTER_LIMIT_CROSSED_ERROR_MSG;
    } else if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"API_DISABLED_FOR_ORG"]) {
        alertMessaage = CHATTER_API_DISABLED;
    }
    else {
        alertMessaage = [error.userInfo valueForKey:@"message"];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:alertMessaage delegate:nil cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
    [alert show];
    [self closeTapped];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.textField isFirstResponder] &&[touch view]) {
        [self.textField resignFirstResponder];
    }
       [super touchesBegan:touches withEvent:event];
}

-(void)postToChatterWall
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    if(haveAttachment == YES)
        [self uploadImageToSalesforce:self.marvelImageFileName withUrl:self.marvelImageURL];
    else
        [self createFeed];

}
-(void)uploadImageToSalesforce:(NSString *)imageFileName  withUrl:(NSURL *)imageURL {
    NSLog(@"Upload Image name : %@, URL : %@",imageFileName,imageURL);
    //Make image as JPEG
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: imageURL];
    // Upload image to chatter files with some default names.
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUploadFile:imageData
                                                                         name:[NSString stringWithFormat:@"%@.jpg",imageFileName]
                                                                  description:@"Selected Marvel Image"
                                                                     mimeType:@"image/jpeg"];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

-(void)createFeed {
    NSLog(@"Post chatter without any image.");
    NSString * path = POST_TO_CHATTER_WALL_URL;
    NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",self.textField.text, @"text",nil];
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:param],@"messageSegments", nil];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:message,@"body", nil];
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
    [[SFRestAPI sharedInstance] send:request delegate:self];

}

-(void)createFeedForAttachmentID:(NSString *)attachmentId {
    NSLog(@"Create Feed With attachment Doc ID= %@",attachmentId);
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"feedTemplate" ofType:@"json"];
    NSError *error = nil;
    NSData *feedJSONTemplateData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    NSString * feedJSONTemplateStr = [[NSString alloc] initWithData:feedJSONTemplateData encoding:NSUTF8StringEncoding];
    feedJSONTemplateStr = [feedJSONTemplateStr stringByReplacingOccurrencesOfString:@"__BODY_TEXT__" withString:self.textField.text];
    feedJSONTemplateStr = [feedJSONTemplateStr stringByReplacingOccurrencesOfString:@"__ATTACHMENT_ID__" withString:attachmentId];
    
    NSDictionary *jsonObj =
    [NSJSONSerialization JSONObjectWithData:[feedJSONTemplateStr dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
    SFRestAPI *api = [SFRestAPI sharedInstance];
    NSString * path = POST_TO_USER_WALL_URL;
    
    NSLog(@"JSON OBJ %@",jsonObj);
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:jsonObj];
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView *socialShareOptionImage;
    UILabel *socialShareOptionName;
   UISwitch *switchView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        socialShareOptionImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 30)];
        
        socialShareOptionImage.contentMode = UIViewContentModeScaleAspectFit;
        
        socialShareOptionImage.tag = SOCIAL_IMAGE_TAG;
        [cell.contentView addSubview:socialShareOptionImage];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            socialShareOptionName = [[UILabel alloc]initWithFrame:CGRectMake(50, 5,400 , 30)];
            socialShareOptionName.font = [UIFont boldSystemFontOfSize:16.0f];
            
        } else {
            
            socialShareOptionName = [[UILabel alloc]initWithFrame:CGRectMake(50,5, 160, 30)];
            socialShareOptionName.font = [UIFont boldSystemFontOfSize:12.0f];
            
        }
        
        [socialShareOptionName setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
        socialShareOptionName.numberOfLines = 0;
        socialShareOptionName.backgroundColor = [UIColor clearColor];
        [socialShareOptionName setLineBreakMode:NSLineBreakByWordWrapping];
        socialShareOptionName.tag = NAME_TAG;
        [cell.contentView addSubview:socialShareOptionName];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
           // switchView = [[UISwitch alloc]initWithFrame:CGRectMake(500, 5, 75, 30)];
            switchView = [[UISwitch alloc]initWithFrame:CGRectZero];

        }else {
            //switchView = [[UISwitch alloc]initWithFrame:CGRectMake(220, 5, 75, 30)];
            switchView = [[UISwitch alloc]initWithFrame:CGRectZero];

        }
        switchView.tag = indexPath.row;
        
        
        cell.accessoryView = switchView;
        [switchView setOn:NO animated:NO];
        [switchView addTarget:self action:@selector(getSwitchStatus:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switchView];
        
        
    } else {
        
        socialShareOptionImage = (UIImageView*)[cell.contentView viewWithTag:SOCIAL_IMAGE_TAG];
        socialShareOptionName = (UILabel*)[cell.contentView viewWithTag:NAME_TAG];
        
    }
    
    if (indexPath.row == 0) {
        
        socialShareOptionImage.image = [UIImage imageNamed:@"icn-linkedin.png"];
        socialShareOptionName.text = @"Publish On LinkedIn";
        
    }else if(indexPath.row == 1) {
        
        socialShareOptionImage.image = [UIImage imageNamed:@"icn-fb.png"];
        socialShareOptionName.text = @"Publish On Facebook";
        
    }else if(indexPath.row == 2) {
        
        socialShareOptionImage.image = [UIImage imageNamed:@"icn-twitter.png"];
        socialShareOptionName.text = @"Publish On Twitter";
    }
        return cell;
}

-(void)getSwitchStatus:(UISwitch*)sender {
    
    NSLog(@"sender.status at 0..%@",sender);
    if (sender.tag == 0) {
        
        if (sender.on) {
            linkedInPublishStatus = 1;
        }else {
            linkedInPublishStatus = 0;
        }
    }else if (sender.tag == 1) {
        
        NSLog(@"sender.status at 1..%@",sender);
        if (sender.on) {
            facebookPublishStatus = 1;
        }else {
            facebookPublishStatus = 0;
        }
    }
    if (sender.tag == 2) {
        
        NSLog(@"sender.status at 2..%@",sender);
        if (sender.on) {
            twitterPublishStatus = 1;
        }else {
            twitterPublishStatus = 0;
        }
    }
    
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}
#pragma mark -
#pragma mark UITextView delegate method
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	//DebugLog(@"SEND VIEW  textViewDidBeginEditing");
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
	} else {
		//DebugLog(@"SEND VIEW  textViewDidBeginEditing phone");
        //[postScrollView adjustOffsetToIdealIfNeeded];
	}
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
	} else {
	}
	[textView resignFirstResponder];
    // Additional Code
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
   // DebugLog(@"SEND VIEW  textViewShouldEndEditing");
	[textView resignFirstResponder];
	return YES;
}

- (IBAction)addMarvelAction:(id)sender {
    
    [self getMarvelCharactersList];
}

- (IBAction)marvelifySwitchAction:(id)sender {
    if([sender isOn])
    {
        [self getMarvelCharactersList];
    }
    else
    {
        [self removeMarvelIfAttached];
    }
}

- (void)setSelectedMarvel:(NSDictionary *)data
{
    haveAttachment = YES;
    NSLog(@"Selected Marvel %@",data);
    NSString *characterName = [data objectForKey:@"name"];
    NSLog(@"comic character name == %@",characterName);

    NSString *imageURLStr = [NSString stringWithFormat:@"%@/%@.%@",[[data objectForKey:@"thumbnail"]objectForKey:@"path"],IMAGE_TYPE_PLACEHOLDER,[[data objectForKey:@"thumbnail"]objectForKey:@"extension"]];
    
    NSURL *imageURL = [NSURL URLWithString:[imageURLStr stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
    
    NSLog(@"URL = %@",imageURL);
   NSString *imageFileName = [NSString stringWithFormat:@"%@.jpeg",[characterName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    self.marvelImageFileName = [characterName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.marvelImageURL = imageURL;
    dispatch_async(dispatch_get_main_queue(), ^{
        attachedMavelView.hidden = NO;
        selectedMarvelTitle.text = characterName;
        [selectedMarvelImageview sd_setImageWithURL:imageURL
                                   placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
        
        [SVProgressHUD dismiss];
    });
    
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
            NSLog(@"Status %@ data : %@",[jsonDict objectForKeyedSubscript:@"status"],[jsonDict objectForKeyedSubscript:@"data"]);
            NSMutableArray *charInfoArray = [NSMutableArray arrayWithArray:[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"results"]];
            
            for (int count = 0; count < [charInfoArray count]; count++) {
                
                
                
                NSString *imageURL;
                if ([charInfoArray objectAtIndex:count]!=nil) {
                    
                    if ([[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"] != [NSNull null] && [[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"path"]!= [NSNull null] && [[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"extension"] != [NSNull null]) {
                        
                        imageURL = [NSString stringWithFormat:@"%@/%@.%@",[[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"path"],IMAGE_TYPE_PLACEHOLDER,[[[charInfoArray objectAtIndex:count] objectForKey:@"thumbnail"]objectForKey:@"extension"]];
                        
                        NSLog(@"NAME %d/%lu : %@ \n URL %@",count,(unsigned long)[charInfoArray count],[[charInfoArray objectAtIndex:count] objectForKey:@"name"],imageURL);
                        
                        if ([imageURL rangeOfString:@"image_not_available"].location == NSNotFound) {
                            [self.charactersInfoWithImageArray addObject:[charInfoArray objectAtIndex:count]];
                        }
                    }
                    
                }
                
            }
            
            if (self.charactersInfoWithImageArray != nil && self.charactersInfoWithImageArray.count > 0) {
                int rIndex = arc4random() % [self.charactersInfoWithImageArray count];
                NSDictionary *badgeInfoDict = [[NSDictionary alloc]initWithDictionary:[self.charactersInfoWithImageArray objectAtIndex:rIndex]];
                [self setSelectedMarvel:badgeInfoDict];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No marvel character found" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                });
            }
            
        }
    }];
}
-(void) resetChatterView {
    self.textField.text = @"";
    attachedMavelView.hidden = YES;
    [marvelifySwitch setOn:NO];
    haveAttachment = NO;
}
-(void) removeMarvelIfAttached {
    attachedMavelView.hidden = YES;
    haveAttachment = NO;
}
@end
