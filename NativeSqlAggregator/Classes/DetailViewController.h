//
//  DetailViewController.h
//  SocialForce
//
//  Created by Ritika on 12/05/13.
//  Copyright (c) 2013 Metacube. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "SVProgressHUD.h"
#import "SFRestAPI.h"
//#import "OAuthLoginView.h"
//#import "SearchListViewController.h"

@protocol LinkedInDelegate;
@interface DetailViewController : UIViewController <SFRestDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UIImageView *bkgView;
@property (retain, nonatomic) NSString *fName;
@property (retain, nonatomic) NSString *company;
@property (retain, nonatomic) NSString *address;
@property (retain, nonatomic) NSString *email;
@property (retain, nonatomic) NSString *phone;
@property (retain, nonatomic) NSString *website;
@property (retain, nonatomic) IBOutlet UITableView *detailTableView;
@property (retain, nonatomic) IBOutlet UIButton *facebookBtn;
@property (retain, nonatomic) IBOutlet UIButton *linkedInBtn;
@property (retain, nonatomic) IBOutlet UIButton *twitterBtn;
@property (nonatomic,retain) NSDictionary *recordDetails;
@property (nonatomic,retain) NSString *recordType;
@property (nonatomic,retain) NSString *recordId;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
- (IBAction)findOnTwitter:(id)sender;
- (IBAction)findOnFacebook:(id)sender;

@end
