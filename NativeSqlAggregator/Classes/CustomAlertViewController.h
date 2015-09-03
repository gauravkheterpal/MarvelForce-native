//
//  CustomAlertViewController.h
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 22/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomAlertViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *characterImage;
@property (weak, nonatomic) IBOutlet UILabel *msgLbl;
@property (nonatomic,retain) NSURL  *imageURL;
@property (nonatomic,retain) NSString *msgStr;



@end
