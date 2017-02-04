//
//  ContactDetailViewController.m
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 7/17/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "CharacterDetailViewController.h"

@interface ContactDetailViewController ()

@end

@implementation ContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Show My Character" style:UIBarButtonItemStyleDone target:self action:@selector(showMyCharacter)];
    
    // Do any additional setup after loading the view from its nib.
    NSString *charImageURL = [Util getValueFor:@"Marvel_Image__c" inJSON:self.recordDict];
    
    if (charImageURL.length == 0)
    {
        charImageURL = [self.recordDict valueForKey:@"CharImageURL"];
        
    }
    
    NSLog(@"Image URL : %@",self.recordDict);
    
    if (charImageURL != nil && charImageURL.length>0 ) {
    
        NSURL *portrait_incridible_imageURL = [NSURL URLWithString:[charImageURL stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:PORTRAIT_INCREDIBLE]];
        //    portrait_incredible
       // [self.backgroundImage sd_setImageWithURL:portrait_incridible_imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    
        NSURL *standard_medium_imageURL = [NSURL URLWithString:[charImageURL stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
        [self.profileImage sd_setImageWithURL:standard_medium_imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    }
    
    [self fetchSFDCContactDetail];

//    [self.profileImage setImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
//    SFIdentityData *idData = [SFAuthenticationManager sharedManager].idCoordinator.idData;
//    NSData *data = [NSData dataWithContentsOfURL:idData.thumbnailUrl];
//    [self.profileImage setImage:[UIImage imageWithData:data]];
    
    // Get the Layer of any view
    CALayer * l = [self.profileImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor lightGrayColor] CGColor]];
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

-(void)fetchSFDCContactDetail
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForRetrieveWithObjectType:@"contact" objectId:[self.recordDict objectForKey:@"Id"] fieldList:nil];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}


- (void)request:(SFRestRequest *)request didLoadResponse:(id)dataResponse
{
    NSLog(@"RESPONSE = %@",dataResponse);
    NSString *contactName = [NSString stringWithString:[Util getValueFor:@"Name" inJSON:dataResponse]];
    NSString *departmentText = [NSString stringWithString:[Util getValueFor:@"Department" inJSON:dataResponse]];
    NSDictionary *mailingAddressDict = [dataResponse objectForKey:@"MailingAddress"];
    
    NSMutableString *addressText = [[NSMutableString alloc]init];
    if (mailingAddressDict != nil && mailingAddressDict != (id)[NSNull null]) {
        
        addressText = [NSMutableString stringWithFormat:@"%@,%@,%@, %@,%@",
                       [Util getValueFor:@"street" inJSON:mailingAddressDict],
                       [Util getValueFor:@"city" inJSON:mailingAddressDict],
                       [Util getValueFor:@"state" inJSON:mailingAddressDict],
                       [Util getValueFor:@"country" inJSON:mailingAddressDict],
                       [Util getValueFor:@"postalCode" inJSON:mailingAddressDict]];
    }
    
    
    NSString *phoneText = [NSString stringWithString:[Util getValueFor:@"MobilePhone" inJSON:dataResponse]];
    NSString *emailText = [NSString stringWithString:[Util getValueFor:@"Email" inJSON:dataResponse]];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.NameLbl setText:contactName];
            [self.departmentLbl setText:departmentText];
            [self.addressLbl setText:addressText];
            [self.phoneLbl setText:phoneText];
            [self.emailLbl setText:emailText];
            [SVProgressHUD dismiss];
        });
    });

    
//    NSArray *records = dataResponse[@"records"];
//    if (nil != records) {
//        NSDictionary *firstRecord = records[0];
//        if (nil != firstRecord) {
//            NSDictionary *attributes = [firstRecord valueForKey:@"attributes"];
//            if (nil != attributes) {
//                NSString *type = [attributes valueForKey:@"type"];
//                if ([type isEqual:@"Contact"]) {
//                    NSLog(@"Records : %@",records);
//                    dispatch_async(dispatch_get_main_queue(), ^{
////                        [self.tableView reloadData];
//                    });
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        // time-consuming task
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [SVProgressHUD dismiss];
//                        });
//                    });
//                }
//                else {
//                    /*
//                     * If the object is not an account or opportunity,
//                     * we do nothing. This block can be used to save
//                     * other types of records.
//                     */
//                }
//            }
//        }
//    }
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

- (void)showMyCharacter {
    
    NSString *characterId = [self.recordDict objectForKey:@"Marvel_ID__c"];
    
    CharacterDetailViewController *characterDetailViewController = [[CharacterDetailViewController alloc]init];
    characterDetailViewController.characterId = characterId;
    [self.navigationController pushViewController:characterDetailViewController animated:YES];
}

@end
