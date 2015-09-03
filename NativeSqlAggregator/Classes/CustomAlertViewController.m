//
//  CustomAlertViewController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 22/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "CustomAlertViewController.h"
#import "UIImageView+WebCache.h"
#import "TasksListViewController.h"

@interface CustomAlertViewController () {
    UIImageView *backgroundImage;
}

@end

@implementation CustomAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *closeButton=[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeTapped)];
    self.navigationItem.rightBarButtonItem = closeButton;
    self.navigationItem.hidesBackButton = YES;

    
    CALayer * l = [self.characterImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor blackColor] CGColor]];
    
   self.view.alpha = 0.7;
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidLayoutSubviews {
    [self setControls:self.imageURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)closeTapped{
    
  
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        NSLog(@"controller class:%@",[controller class]);
        if ([controller isKindOfClass:[TasksListViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void)setControls:(NSURL*)imageUrl {
    
    NSLog(@"Image Array :%@",imageUrl);
   
        if(imageUrl!=nil){
            
            [ self.characterImage sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
             
            
        }
        
        if (self.msgStr!=nil) {
            
            [self.msgLbl setText:self.msgStr];
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

@end
