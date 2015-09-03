//
//  DetailViewController.m
//  SocialForce
//
//  Created by Ritika on 12/05/13.
//  Copyright (c) 2013 Metacube. All rights reserved.
//

#import "DetailViewController.h"
//#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
//#import "SearchListViewController.h"
#import "Util.h"
#define CONTACT_LBL_TAG 1
#define CONTACT_NAME_TAG 2
#define COMPANY_LBL_TAG 3
#define COMPANY_NAME_TAG 4
#define PHONE_LBL_TAG 5
#define PHONE_NO_TAG 6
#define EMAIL_LBL_TAG 7
#define EMAIL_ID_TAG 8
#define ADDRESS_LBL_TAG 9
#define ADDRESS_TAG 10
#define ACCOUNT_LBL_TAG 11
#define ACCOUNT__NAME_TAG 12
#define ACC_PHONE_LBL_TAG 13
#define ACC_PHONE_TAG 14
#define ACC_ADDRESS_LBL_TAG 15
#define ACC_ADDRESS_TAG 16
#define ACC_WEBSITE_LBL_TAG 17
#define ACC_WEBSITE_TAG 18

@interface DetailViewController () {
//    OAuthLoginView *loginView;
}
//@property (strong, nonatomic) FBRequestConnection *requestConnection;

@end

@implementation DetailViewController
@synthesize recordType,recordId,recordDetails,detailTableView,fName,company,address,email,phone,website,facebookBtn,linkedInBtn,twitterBtn;
//@synthesize requestConnection = _requestConnection;


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
    self.detailTableView.allowsSelection = NO;
    if(UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault];
            NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor grayColor],NSForegroundColorAttributeName,
                                                       [UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
            self.navigationController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
            self.navigationController.navigationBar.tintColor = [UIColor grayColor];
        }
    }
    [self changeBkgrndImgWithOrientation];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    });
    self.title = [NSString stringWithFormat:@"%@ Detail",self.recordType];
    // Do any additional setup after loading the view from its nib.
    self.detailTableView.scrollEnabled = YES;
    [self fetchRecordDetail];
    if([self.recordType isEqualToString:@"Account"]) {
        linkedInBtn.frame = CGRectMake(50, 15, 81, 30);
        linkedInBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        twitterBtn.frame = CGRectMake(190, 15, 81, 30);
        twitterBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        facebookBtn.hidden = YES;
        facebookBtn.enabled = NO;
    } else {
        facebookBtn.hidden = NO;
        //facebookBtn.enabled = YES;
        
    }
    self.detailTableView.allowsSelection = NO;
    [super viewDidLoad];
}
-(void)changeBkgrndImgWithOrientation {
    
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_320x480.png"]];
    [backgroundImgView setFrame:detailTableView.frame];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            backgroundImgView.image = [UIImage imageNamed:@"bg_480x320.png"];
            self.bkgView.image = [UIImage imageNamed:@"bg_480x320.png"];
        }
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bg_320x480.png"];
            self.bkgView.image = [UIImage imageNamed:@"bg_320x480.png"];
        }
    } else {
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            backgroundImgView.image = [UIImage imageNamed:@"bg_1024x748.png"];
            self.bkgView.image = [UIImage imageNamed:@"bg_1024x748.png"];
        }
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bg_768x1004.png"];
            self.bkgView.image = [UIImage imageNamed:@"bg_768x1004.png"];
        }
    }
    detailTableView.backgroundView = backgroundImgView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fetchRecordDetail {
    NSString *queryString = @"";
    if([self.recordType isEqualToString:@"Contact"]) {
        queryString = [NSString stringWithFormat:@"SELECT  FirstName,LastName,Account.Name,Email,Phone,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet from %@ where Id = '%@'",self.recordType,self.recordId];
    } else if([self.recordType isEqualToString:@"Account"]) {
        queryString = [NSString stringWithFormat:@"SELECT  Name,Owner.FirstName,Owner.LastName,Phone,Website,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet FROM %@ where Id = '%@'",self.recordType,self.recordId];
    } else if([self.recordType isEqualToString:@"Lead"]) {
        queryString = [NSString stringWithFormat:@"SELECT FirstName,LastName,Company,Owner.FirstName,Owner.LastName,Email,Phone,City,Country,PostalCode,State,Street FROM %@ where Id = '%@'",self.recordType,self.recordId];}
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    });
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:queryString];
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    //self.facebookBtn.enabled = YES;
   // self.linkedInBtn.enabled = YES;
   // self.twitterBtn.enabled = YES;
    //[self.loadingSpinner stopAnimating];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self changeBkgrndImgWithOrientation];
}
- (IBAction)findOnTwitter:(id)sender {
    
}
- (IBAction)findOnFacebook:(id)sender {
    
}
-(void)searchPeopleOnFacebook {
    
}


#pragma mark - SFRestDelegate methods
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
    NSLog(@"request:%@",[request description]);
    NSLog(@"jsonResponse:%@",jsonResponse);

    if([[request description] rangeOfString:@"SELECT"].location != NSNotFound)
    {
        if([[jsonResponse objectForKey:@"errors"] count]==0)
        {
            
            //If this is a record fetch request, execute the following bunch of code
            
            //Hide progress indicator
            
            //            dialog_imgView.hidden = YES;
            //            loadingLbl.hidden = YES;
            //            doneImgView.hidden = YES;
            //            [loadingSpinner stopAnimating];
            
            NSArray *records = [jsonResponse objectForKey:@"records"];
            
            
            NSLog(@"request:didLoadResponse: #records: %lu records %@ req %@ rsp %@", (unsigned long)records.count,records,request,jsonResponse);
            NSLog(@"records count...%lu",(unsigned long)records.count);
            self.recordDetails = [records objectAtIndex:0];
            if([self.recordType isEqualToString:@"Contact"]) {
                //sfContactDictionary = [[NSDictionary alloc] initWithDictionary:recordDetails];
                self.fName = [NSString stringWithFormat:@"%@ %@",[self.recordDetails valueForKey:@"FirstName"],[self.recordDetails valueForKey:@"LastName"]];
                if (![(NSString*)[[self.recordDetails valueForKey:@"Account"]valueForKey:@"Name"]isEqual:[NSNull null]]) {
                    self.company = [[self.recordDetails valueForKey:@"Account"]valueForKey:@"Name"];
                }else {
                    self.company = @"";
                }
                
                if (![(NSString*)[self.recordDetails valueForKey:@"Email"]isEqual:[NSNull null]]) {
                    self.email = [self.recordDetails valueForKey:@"Email"];
                }else {
                    self.email = @"";
                }
                
                if (![(NSString*)[self.recordDetails valueForKey:@"Phone"]isEqual:[NSNull null]]) {
                    self.phone = [self.recordDetails valueForKey:@"Phone"];
                }else {
                    self.phone = @"";
                }
                self.address = @"";
                NSString *mailingAddress = [[NSMutableString alloc]init];
                if(![(NSString*)[self.recordDetails valueForKey:@"MailingStreet"]isEqual:[NSNull null]]) {
                    mailingAddress = [self.recordDetails valueForKey:@"MailingStreet"];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"MailingCity"]isEqual:[NSNull null]]) {
                    [mailingAddress stringByAppendingString:[NSString stringWithFormat:@"\n%@",[self.recordDetails valueForKey:@"MailingCity"]]];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"MailingState"]isEqual:[NSNull null]]) {
                    if([mailingAddress isEqualToString:@""])
                        mailingAddress = [self.recordDetails valueForKey:@"MailingState"];
                    else {
                        [mailingAddress stringByAppendingString:[NSString stringWithFormat:@",%@",[self.recordDetails valueForKey:@"MailingState"]]];
                    }
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"MailingPostalCode"]isEqual:[NSNull null]]) {
                    [mailingAddress stringByAppendingString:[NSString stringWithFormat:@" %@",[self.recordDetails valueForKey:@"MailingPostalCode"]]];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"MailingCountry"]isEqual:[NSNull null]]) {
                    [mailingAddress stringByAppendingString:[NSString stringWithFormat:@"\n%@",[self.recordDetails valueForKey:@"MailingCountry"]]];
                }
                
                self.address = mailingAddress;
                
            } else if([self.recordType isEqualToString:@"Account"]) {
                //sfAccountDictionary = [[NSDictionary alloc]initWithDictionary:recordDetails];
                self.fName = [self.recordDetails valueForKey:@"Name"];
                self.company = @"";
                if (![(NSString*)[self.recordDetails valueForKey:@"Phone"]isEqual:[NSNull null]]) {
                    self.phone = [self.recordDetails valueForKey:@"Phone"];
                }else {
                    self.phone = @"";
                }
                if (![(NSString*)[self.recordDetails valueForKey:@"Website"]isEqual:[NSNull null]]) {
                    self.website = [self.recordDetails valueForKey:@"Website"];
                }else {
                    self.website = @"";
                }
                self.address = @"";
                NSString *billingAddress = [[NSMutableString alloc]init];
                if(![(NSString*)[self.recordDetails valueForKey:@"BillingStreet"]isEqual:[NSNull null]]) {
                    billingAddress = [self.recordDetails valueForKey:@"BillingStreet"];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"BillingCity"]isEqual:[NSNull null]]) {
                    billingAddress = [NSString stringWithFormat:@"%@\n%@",billingAddress,[self.recordDetails valueForKey:@"BillingCity"]];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"BillingState"]isEqual:[NSNull null]]) {
                    if([billingAddress isEqualToString:@""])
                        billingAddress = [self.recordDetails valueForKey:@"BillingState"];
                    else {
                        billingAddress = [NSString stringWithFormat:@"%@,%@",billingAddress,[self.recordDetails valueForKey:@"BillingState"]];
                    }
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"BillingPostalCode"]isEqual:[NSNull null]]) {
                    billingAddress =  [NSString stringWithFormat:@"%@ %@",billingAddress,[self.recordDetails valueForKey:@"BillingPostalCode"]];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"BillingCountry"]isEqual:[NSNull null]]) {
                    billingAddress = [NSString stringWithFormat:@"%@\n%@",billingAddress,[self.recordDetails valueForKey:@"BillingCountry"]];
                }
                
                self.address = billingAddress;
                
            } else if([self.recordType isEqualToString:@"Lead"]) {
                //sfLeadDictionary = [[NSDictionary alloc]initWithDictionary:recordDetails];
                self.fName = [NSString stringWithFormat:@"%@ %@",[self.recordDetails valueForKey:@"FirstName"],[self.recordDetails valueForKey:@"LastName"]];
                self.company = [self.recordDetails valueForKey:@"Company"];
                if (![(NSString*)[self.recordDetails valueForKey:@"Email"]isEqual:[NSNull null]]) {
                    self.email = [self.recordDetails valueForKey:@"Email"];
                }else {
                    self.email = @"";
                }
                
                if (![(NSString*)[self.recordDetails valueForKey:@"Phone"]isEqual:[NSNull null]]) {
                    self.phone = [self.recordDetails valueForKey:@"Phone"];
                }else {
                    self.phone = @"";
                }
                self.address = @"";
                NSString *billingAddress = [[NSMutableString alloc]init];;
                if(![(NSString*)[self.recordDetails valueForKey:@"Street"]isEqual:[NSNull null]]) {
                    billingAddress  = [recordDetails valueForKey:@"Street"];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"City"]isEqual:[NSNull null]]) {
                    billingAddress = [NSString stringWithFormat:@"%@\n%@",billingAddress,[self.recordDetails valueForKey:@"City"]];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"State"]isEqual:[NSNull null]]) {
                    if([billingAddress isEqualToString:@""])
                        billingAddress = [self.recordDetails valueForKey:@"State"];
                    else {
                        billingAddress = [NSString stringWithFormat:@"%@,%@",billingAddress,[self.recordDetails valueForKey:@"State"]];
                    }
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"PostalCode"]isEqual:[NSNull null]]) {
                    billingAddress =  [NSString stringWithFormat:@"%@ %@",billingAddress,[self.recordDetails valueForKey:@"PostalCode"]];
                }
                if(![(NSString*)[self.recordDetails valueForKey:@"Country"]isEqual:[NSNull null]]) {
                    billingAddress = [NSString stringWithFormat:@"%@\n%@",billingAddress,[self.recordDetails valueForKey:@"Country"]];
                }
                
                self.address = billingAddress;
                /*else {
                 self.address = @"";
                 }*/
                
            }
            
            //NSLog(@"...f.%@..l.%@..a.%@...e.%@..p//%@/....",self.fName,self.company,self.address,self.email,self.phone);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.detailTableView reloadData];
                [SVProgressHUD dismiss];
            });
            self.detailTableView.delegate = self;
            self.detailTableView.dataSource = self;
            
            
            /*self.SFLeadsArr = [records sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
             
             //[selectedRow removeAllObjects];
             
             if([self.SFLeadsArr count] != 0)
             {
             
             //dict = [self fillingDictionary:cellIndexData];
             }*/
        }
        else
        {
            
        }
        
        
    }
    else
    {
        
        if([[jsonResponse objectForKey:@"errors"] count]==0)
        {
            
        }
        else
        {
            
        }
        
        //        [Utility hideCoverScreen];
    }
    self.facebookBtn.enabled = YES;
    self.linkedInBtn.enabled = YES;
    self.twitterBtn.enabled = YES;
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error
{
    //Show back button
    [self.navigationItem setHidesBackButton:NO animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    NSLog(@"request:didFailLoadWithError: %@ code:%ld", error,(long)error.code);
    
    //Hide loading indicator
    //    [Utility hideCoverScreen];
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Salesforce Error" message:@"An error occured.Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    self.facebookBtn.enabled = YES;
    self.linkedInBtn.enabled = YES;
    self.twitterBtn.enabled = YES;
}

- (void)requestDidCancelLoad:(SFRestRequest *)request
{
    //Show back button
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    self.facebookBtn.enabled = YES;
    self.linkedInBtn.enabled = YES;
    self.twitterBtn.enabled = YES;
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
    
    //    [Utility hideCoverScreen];
    
}

- (void)requestDidTimeout:(SFRestRequest *)request
{
    //Show back button
    
    //add your failed error handling here
    //    [Utility hideCoverScreen];
    self.facebookBtn.enabled = YES;
    self.linkedInBtn.enabled = YES;
    self.twitterBtn.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.recordType isEqualToString:@"Contact"]||[self.recordType isEqualToString:@"Lead"]) {
        
        return 5;
        
    } else if([self.recordType isEqualToString:@"Account"]) {
        return 4;
    }
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 120;
        
    }else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    if (indexPath.section == 0) {
        CellIdentifier = @"Cell1";
    }else if(indexPath.section == 1) {
        CellIdentifier = @"Cell2";
    }else if(indexPath.section == 2) {
        CellIdentifier = @"Cell3";
    }else if(indexPath.section == 3) {
        CellIdentifier = @"Cell4";
    }else if(indexPath.section == 4) {
        CellIdentifier = @"Cell5";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.section == 0) {
        UILabel *accountName,*accountLbl,*contactLbl, *contactName;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    contactLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    contactLbl.font =[UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    contactLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    contactLbl.font =[UIFont boldSystemFontOfSize:16.0f];
                }
                [contactLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                contactLbl.numberOfLines = 0;
                contactLbl.tag = CONTACT_LBL_TAG;
                contactLbl.userInteractionEnabled = NO;
                [contactLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [contactLbl setBackgroundColor:[UIColor clearColor]];
                //contactLbl.text = @"Name";
                [cell.contentView addSubview:contactLbl];
                
                
                contactName = [[UILabel alloc]initWithFrame:CGRectMake(85, 0, 205, 60)];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    contactName = [[UILabel alloc]initWithFrame:CGRectMake(135, 0, 155, 120)];
                    contactName.font =[UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                } else {
                    
                    
                    contactName.font =[UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                
                contactName.numberOfLines = 0;
                contactName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                contactName.tag = CONTACT_NAME_TAG;
                contactName.userInteractionEnabled = NO;
                [contactName setLineBreakMode:NSLineBreakByWordWrapping];
                [contactName setBackgroundColor:[UIColor clearColor]];
                //contactName.text = self.fName;
                [cell.contentView addSubview:contactName];
                
            } else if ([self.recordType isEqualToString:@"Account"]) {
                
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    accountLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    accountLbl.font = [UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    accountLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    accountLbl.font = [UIFont boldSystemFontOfSize:16.0f];
                }
                accountLbl.tag = ACCOUNT_LBL_TAG;
                [accountLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                accountLbl.numberOfLines = 0;
                accountLbl.userInteractionEnabled = NO;
                [accountLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [accountLbl setBackgroundColor:[UIColor clearColor]];
                //accountLbl.text = @"Name";
                [cell.contentView addSubview:accountLbl];
                
                accountName = [[UILabel alloc]initWithFrame:CGRectMake(85, 0, 205, 60)];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    accountName = [[UILabel alloc]initWithFrame:CGRectMake(135, 0, 155, 120)];
                    accountName.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
                } else {
                    
                    
                    accountName.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                accountName.tag = ACCOUNT__NAME_TAG;
                accountName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                accountName.numberOfLines = 0;
                accountName.userInteractionEnabled = NO;
                [accountName setLineBreakMode:NSLineBreakByWordWrapping];
                [accountName setBackgroundColor:[UIColor clearColor]];
                //accountName.text = self.fName;
                [cell.contentView addSubview:accountName];
            }
        } else {
            
            contactLbl = (UILabel*)[cell.contentView viewWithTag:CONTACT_LBL_TAG];
            contactName = (UILabel*)[cell.contentView viewWithTag:CONTACT_NAME_TAG];
            accountLbl = (UILabel*)[cell.contentView viewWithTag:ACCOUNT_LBL_TAG];
            accountName = (UILabel*)[cell.contentView viewWithTag:ACCOUNT__NAME_TAG];
        }
        if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
            contactLbl.text = @"Name";
            
            contactName.text = self.fName;
            
            
        }else if ([self.recordType isEqualToString:@"Account"]) {
            accountLbl.text = @"Name";
            
            accountName.text = self.fName;
            
            
        }
        
    } else if(indexPath.section == 1) {
        
        UILabel *companyNameLbl, *companyName, *phoneNoLbl;
        UILabel *phoneNo;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
            
            if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
                
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    companyNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    companyNameLbl.font =[UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    companyNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    companyNameLbl.font =[UIFont boldSystemFontOfSize:16.0f];
                }
                [companyNameLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                companyNameLbl.tag = COMPANY_LBL_TAG;
                companyNameLbl.numberOfLines = 0;
                companyNameLbl.userInteractionEnabled = NO;
                [companyNameLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [companyNameLbl setBackgroundColor:[UIColor clearColor]];
                //companyNameLbl.text = @"Company";
                [cell.contentView addSubview:companyNameLbl];
                
                companyName = [[UILabel alloc]initWithFrame:CGRectMake(85, 0, 205, 60)];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    companyName = [[UILabel alloc]initWithFrame:CGRectMake(135, 0, 155, 120)];
                    companyName.font =[UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                } else {
                    
                    
                    companyName.font =[UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                companyName.tag = COMPANY_NAME_TAG;
                companyName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                companyName.numberOfLines = 0;
                companyName.userInteractionEnabled = NO;
                [companyName setLineBreakMode:NSLineBreakByWordWrapping];
                [companyName setBackgroundColor:[UIColor clearColor]];
                //companyName.text = self.company;
                [cell.contentView addSubview:companyName];
                
            } else if ([self.recordType isEqualToString:@"Account"]) {
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    phoneNoLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    phoneNoLbl.font = [UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    phoneNoLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    phoneNoLbl.font = [UIFont boldSystemFontOfSize:16.0f];
                }
                [phoneNoLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                phoneNoLbl.numberOfLines = 0;
                phoneNoLbl.tag = ACC_PHONE_LBL_TAG;
                phoneNoLbl.userInteractionEnabled = NO;
                [phoneNoLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [phoneNoLbl setBackgroundColor:[UIColor clearColor]];
                //phoneNoLbl.text = @"Phone";
                [cell.contentView addSubview:phoneNoLbl];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    phoneNo = [[UILabel alloc]initWithFrame:CGRectMake(130, 38, 470, 120)];
                    phoneNo.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                } else {
                    
                    phoneNo = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 220, 60)];
                    phoneNo.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                phoneNo.tag = ACC_PHONE_TAG;
//                phoneNo.delegate = self;
//                phoneNo.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
//                phoneNo.editable = NO;
                [phoneNo setBackgroundColor:[UIColor clearColor]];
                //phoneNo.text = self.phone;
                [cell.contentView addSubview:phoneNo];
                
            }
        }else {
            
            companyNameLbl = (UILabel*)[cell.contentView viewWithTag:COMPANY_LBL_TAG];
            companyName = (UILabel*)[cell.contentView viewWithTag:COMPANY_NAME_TAG];
            phoneNoLbl = (UILabel*)[cell.contentView viewWithTag:ACC_PHONE_LBL_TAG];
            phoneNo = (UILabel*)[cell.contentView viewWithTag:ACC_PHONE_TAG];
        }
        if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
            companyNameLbl.text = @"Company";
            
            companyName.text = self.company;
            
            
        }else if ([self.recordType isEqualToString:@"Account"]) {
            phoneNoLbl.text = @"Phone";
            
            phoneNo.text = self.phone;
            
        }
    } else if(indexPath.section == 2) {
        UILabel *phoneNoLbl,*addressNameLbl,*addressName;
        UILabel *phoneNo;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
                
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    phoneNoLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    phoneNoLbl.font = [UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    phoneNoLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    phoneNoLbl.font = [UIFont boldSystemFontOfSize:16.0f];
                }
                [phoneNoLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                phoneNoLbl.numberOfLines = 0;
                phoneNoLbl.tag = PHONE_LBL_TAG;
                phoneNoLbl.userInteractionEnabled = NO;
                [phoneNoLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [phoneNoLbl setBackgroundColor:[UIColor clearColor]];
                //phoneNoLbl.text = @"Phone";
                [cell.contentView addSubview:phoneNoLbl];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    phoneNo = [[UILabel alloc]initWithFrame:CGRectMake(130, 38, 460, 120)];
                    phoneNo.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                    
                } else {
                    
                    phoneNo = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 220, 60)];
                    phoneNo.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
                    
                }
                
                phoneNo.tag = PHONE_NO_TAG;
//                phoneNo.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
//                phoneNo.delegate = self;
//                phoneNo.editable = NO;
                [phoneNo setBackgroundColor:[UIColor clearColor]];
                //phoneNo.text = self.phone;
                [cell.contentView addSubview:phoneNo];
                
                
            } else if ([self.recordType isEqualToString:@"Account"]) {
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    addressNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    addressNameLbl.font = [UIFont boldSystemFontOfSize:20.0f];
                } else {
                    
                    addressNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    addressNameLbl.font = [UIFont boldSystemFontOfSize:16.0f];
                }
                [addressNameLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                addressNameLbl.numberOfLines = 0;
                addressNameLbl.tag = ACC_ADDRESS_LBL_TAG;
                addressNameLbl.userInteractionEnabled = NO;
                [addressNameLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [addressNameLbl setBackgroundColor:[UIColor clearColor]];
                //addressNameLbl.text = @"Address";
                [cell.contentView addSubview:addressNameLbl];
               
                addressName = [[UILabel alloc]initWithFrame:CGRectMake(85, 0, 205, 60)];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    addressName = [[UILabel alloc]initWithFrame:CGRectMake(135, 0, 155, 120)];
                    addressName.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                } else {
                    
                    
                    addressName.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                
                addressName.numberOfLines = 0;
                addressName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                addressName.tag = ACC_ADDRESS_TAG;
                addressName.userInteractionEnabled = NO;
                [addressName setLineBreakMode:NSLineBreakByWordWrapping];
                [addressName setBackgroundColor:[UIColor clearColor]];
                //addressName.text = self.address;
                [cell.contentView addSubview:addressName];
            }
        }else {
            
            phoneNoLbl = (UILabel*)[cell.contentView viewWithTag:PHONE_LBL_TAG];
            phoneNo = (UILabel*)[cell.contentView viewWithTag:PHONE_NO_TAG];
            addressNameLbl = (UILabel*)[cell.contentView viewWithTag:ACC_ADDRESS_LBL_TAG];
            addressName = (UILabel*)[cell.contentView viewWithTag:ACC_ADDRESS_TAG];
        }
        if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
            phoneNoLbl.text = @"Phone";
            
            phoneNo.text = self.phone;
            
            
        }else if ([self.recordType isEqualToString:@"Account"]) {
            addressNameLbl.text = @"Address";
            
            addressName.text = self.address;
            
            
            
        }
    } else if(indexPath.section == 3) {
        
        UILabel *emailAddLbl,*websiteUrlLbl;
        UILabel *emailId,*websiteUrl;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
            
            if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
                
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    emailAddLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    emailAddLbl.font = [UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    emailAddLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    emailAddLbl.font = [UIFont boldSystemFontOfSize:16.0f];
                }
                [emailAddLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                emailAddLbl.numberOfLines = 0;
                emailAddLbl.tag = EMAIL_LBL_TAG;
                emailAddLbl.userInteractionEnabled = NO;
                [emailAddLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [emailAddLbl setBackgroundColor:[UIColor clearColor]];
                //emailAddLbl.text = @"Email";
                [cell.contentView addSubview:emailAddLbl];
                
                emailId = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 210, 60)];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    emailId = [[UILabel alloc]initWithFrame:CGRectMake(130, 38, 160, 120)];
                    emailId.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                } else {
                    
                    
                    emailId.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                
                emailId.tag = EMAIL_ID_TAG;
                emailId.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                emailId.dataDetectorTypes = UIDataDetectorTypeAll;
//                emailId.delegate = self;
//                emailId.editable= NO;
                [emailId setBackgroundColor:[UIColor clearColor]];
                //emailId.text = self.email;
                [cell.contentView addSubview:emailId];
                
                
            } else if ([self.recordType isEqualToString:@"Account"]) {
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    websiteUrlLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    websiteUrlLbl.font = [UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    websiteUrlLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    websiteUrlLbl.font = [UIFont boldSystemFontOfSize:16.0f];
                }
                [websiteUrlLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                websiteUrlLbl.numberOfLines = 0;
                websiteUrlLbl.tag = ACC_WEBSITE_LBL_TAG;
                websiteUrlLbl.userInteractionEnabled = NO;
                [websiteUrlLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [websiteUrlLbl setBackgroundColor:[UIColor clearColor]];
                //websiteUrlLbl.text = @"Website";
                [cell.contentView addSubview:websiteUrlLbl];
                
                websiteUrl = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 210, 60)];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    websiteUrl = [[UILabel alloc]initWithFrame:CGRectMake(130,10, 160, 100)];
                    websiteUrl.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                } else {
                    
                    
                    websiteUrl.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                
                
                websiteUrl.tag = ACC_WEBSITE_TAG;
                websiteUrl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                websiteUrl.dataDetectorTypes = UIDataDetectorTypeLink;
//                websiteUrl.editable = NO;
                [websiteUrl setBackgroundColor:[UIColor clearColor]];
                //websiteUrl.text = self.website;
                [cell.contentView addSubview:websiteUrl];
            }
        }else {
            
            emailAddLbl = (UILabel*)[cell.contentView viewWithTag:EMAIL_LBL_TAG];
            emailId = (UILabel*)[cell.contentView viewWithTag:EMAIL_ID_TAG];
            websiteUrlLbl = (UILabel*)[cell.contentView viewWithTag:ACC_WEBSITE_LBL_TAG];
            websiteUrl = (UILabel*)[cell.contentView viewWithTag:ACC_WEBSITE_TAG];
        }
        if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
            emailAddLbl.text = @"Email";
            
            emailId.text = self.email;
            
        }else if ([self.recordType isEqualToString:@"Account"]) {
            websiteUrlLbl.text = @"Website";
            
            websiteUrl.text = self.website;
            
        }
    }else if(indexPath.section == 4) {
        UILabel *addressNameLbl, *addressName;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
            
            if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
                
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    addressNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 120)];
                    addressNameLbl.font =[UIFont boldSystemFontOfSize:20.0f];
                    
                } else {
                    
                    addressNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 75, 60)];
                    addressNameLbl.font =[UIFont boldSystemFontOfSize:16.0f];
                }
                [addressNameLbl setTextColor:[UIColor colorWithRed:(120/255.f) green:(133/255.f) blue:(169/255.f) alpha:1.0f]];
                addressNameLbl.numberOfLines = 0;
                addressNameLbl.userInteractionEnabled = NO;
                [addressNameLbl setLineBreakMode:NSLineBreakByWordWrapping];
                [addressNameLbl setBackgroundColor:[UIColor clearColor]];
                //addressNameLbl.text = @"Address";
                [cell.contentView addSubview:addressNameLbl];
                
                addressName = [[UILabel alloc]initWithFrame:CGRectMake(85, 0, 205, 60)];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    addressName = [[UILabel alloc]initWithFrame:CGRectMake(135, 0, 155, 120)];
                    addressName.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
                    
                } else {
                    
                    
                    addressName.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
                }
                
                addressName.numberOfLines = 0;
                addressName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                addressName.userInteractionEnabled = NO;
                [addressName setLineBreakMode:NSLineBreakByWordWrapping];
                [addressName setBackgroundColor:[UIColor clearColor]];
                //addressName.text = self.address;
                [cell.contentView addSubview:addressName];
                
            }
        }else {
            
            addressNameLbl = (UILabel*)[cell.contentView viewWithTag:ADDRESS_LBL_TAG];
            addressName = (UILabel*)[cell.contentView viewWithTag:ADDRESS_TAG];
            
        }
        if([self.recordType isEqualToString:@"Contact"] || [self.recordType isEqualToString:@"Lead"]) {
            addressNameLbl.text = @"Address";
            
            addressName.text = self.address;
            
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    //[cell.layer setBorderWidth: 1.0];
    return cell;
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
    
    [self.detailTableView deselectRowAtIndexPath:[self.detailTableView indexPathForSelectedRow] animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
#pragma mark -
- (NSString *)urlEncodeForTwitter: (NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)string,NULL,(CFStringRef)@"!*'();@&+$,/?%#[]~=_-.:",kCFStringEncodingUTF8 ));
}
- (NSString *) urlEncode: (NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)string,NULL,(CFStringRef)@"!*'();@&+$,/?%#[]~=_-.:",kCFStringEncodingUTF8 ));
}
- (void)dealloc {

}
-(void)viewDidDisappear:(BOOL)animated {
}
- (void)viewDidUnload {
    
    [super viewDidUnload];
}
@end

