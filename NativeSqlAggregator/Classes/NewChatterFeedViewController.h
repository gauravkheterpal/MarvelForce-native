//
//  NewChatterFeedViewController.h
//  SocialForce
//
//  Created by vish on 17/05/13.
//  Copyright (c) 2013 Metacube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "CharacterListViewController.h"
//#import "ChatterGroupVCntrlViewController.h"
//#import "OAuthLoginView.h"
//#import "TPKeyboardAvoidingScrollView.h"

@protocol LinkedInDelegate;
@interface NewChatterFeedViewController : UIViewController <SFRestDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
{
    IBOutlet UIScrollView *postScrollView;
    IBOutlet UIImageView *backgroundImgView;
    BOOL haveAttachment;
    __weak IBOutlet UIView *attachedMavelView;
    __weak IBOutlet UIImageView *selectedMarvelImageview;
    __weak IBOutlet UILabel *selectedMarvelTitle;
    __weak IBOutlet UISwitch *marvelifySwitch;
}

@property (retain, nonatomic) IBOutlet UITextView *textField;
@property (retain, nonatomic) IBOutlet UITableView *socialShareOptions;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
//@property (retain, nonatomic) IBOutlet UIScrollView *newFeedScrollView;
@property (weak, nonatomic) IBOutlet UIButton *addMarvelOutlet;

@property (nonatomic, retain) NSString *marvelImageFileName;
@property (nonatomic, retain) NSURL *marvelImageURL;
@property (nonatomic,strong) NSMutableArray * charactersInfoWithImageArray;


- (IBAction)addMarvelAction:(id)sender;
- (IBAction)marvelifySwitchAction:(id)sender;


@end
