//
//  ComicDetailViewController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 12/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "ComicDetailViewController.h"
#import "EventListViewController.h"
#import "SVProgressHUD.h"
#import "Util.h"

@interface ComicDetailViewController ()

@end

@implementation ComicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Show Events" style:UIBarButtonItemStyleDone target:self action:@selector(showEvents)];
    
    self.comicDetailDict = [[NSDictionary alloc]init];
    [self getMarvelComicDetail];
    // Do any additional setup after loading the view from its nib.
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

-(void)getMarvelComicDetail
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *stringForHash = [NSString stringWithFormat:@"%@%@%@",TS,MARVEL_PRIVATE_KEY,MARVEL_PUBLIC_KEY];
    NSString *hashString = [Util md5:stringForHash];
    NSURL *marvelCharURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@?ts=%@&apikey=%@&hash=%@",MARVEL_SERVER_URL,MARVEL_GET_COMIC_DETAIL_API_URL,self.comicId,TS,MARVEL_PUBLIC_KEY,hashString]];
    
    NSLog(@"REQUEST URL : %@",marvelCharURL);
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:marvelCharURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSError *error1 = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error1 != nil) {
            NSLog(@"Error parsing JSON.");
        }
        else {
            NSLog(@"Status %@ data : %@",[jsonDict objectForKeyedSubscript:@"status"],[jsonDict objectForKeyedSubscript:@"data"]);
          
            NSMutableArray *comicDetailArray = [NSMutableArray arrayWithArray:[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"results"]];
            if (comicDetailArray.count>0 && [comicDetailArray objectAtIndex:0]
                != nil) {
                self.comicDetailDict = [comicDetailArray objectAtIndex:0];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setMarvelComicDetail];
                [SVProgressHUD dismiss];
            });        }
        
        
    }];
}

-(void)setMarvelComicDetail {
    
    if (self.comicDetailDict != nil) {
        
        NSString *imageURL;
        
        if ([self.comicDetailDict objectForKey:@"thumbnail"] != [NSNull null] && [[self.comicDetailDict objectForKey:@"thumbnail"]objectForKey:@"path"]!= [NSNull null] && [[self.comicDetailDict objectForKey:@"thumbnail"]objectForKey:@"extension"] != [NSNull null]) {
            
            imageURL = [NSString stringWithFormat:@"%@/%@.%@",[[self.comicDetailDict objectForKey:@"thumbnail"]objectForKey:@"path"],IMAGE_TYPE_PLACEHOLDER,[[self.comicDetailDict objectForKey:@"thumbnail"]objectForKey:@"extension"]];
        }
    
        
        
        // Get the Layer of any view
        CALayer * l = [self.characterImage layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:10.0];
        // You can even add a border
        [l setBorderWidth:2.0];
        [l setBorderColor:[[UIColor lightGrayColor] CGColor]];
        

        
        if (imageURL != nil && [imageURL rangeOfString:@"image_not_available"].location == NSNotFound) {
         
            NSURL *portrait_incridible_imageURL = [NSURL URLWithString:[imageURL stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:PORTRAIT_INCREDIBLE]];
            //    portrait_incredible
           // [self.backgroundImage sd_setImageWithURL:portrait_incridible_imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
            
            NSURL *standard_medium_imageURL = [NSURL URLWithString:[imageURL stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
            
            [self.characterImage sd_setImageWithURL:standard_medium_imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
            
        }else {
            [self.characterImage setImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
        }
        
        [self.titleLbl setText:[Util getValueFor:@"title" inJSON:self.comicDetailDict]];
        [self.pagesLbl setText:[NSString stringWithFormat:@"Total Pages: %@",[Util getValueFor:@"pageCount" inJSON:self.comicDetailDict]]];
       
        NSString *comicPrice;
        if ([self.comicDetailDict objectForKey:@"prices"]!=nil) {
            NSMutableArray *priceArray = [NSMutableArray arrayWithArray:[self.comicDetailDict objectForKey:@"prices"]];
            for (int cnt = 0; cnt < priceArray.count; cnt++) {
                if ([[priceArray objectAtIndex:cnt]objectForKey:@"type"]!=nil && [[[priceArray objectAtIndex:cnt]objectForKey:@"type"]  isEqual: @"digitalPurchasePrice"] ) {
                    comicPrice = [[priceArray objectAtIndex:cnt]objectForKey:@"price"];
                }
            }
            
        }
        if (![comicPrice isEqual:[NSNull null]] && comicPrice!=nil && ![comicPrice isEqual:@"(null)"]) {
            [self.priceLbl setText:[NSString stringWithFormat:@"Price: %@$",comicPrice]];
        }
        
        if ([self.comicDetailDict objectForKey:@"description"]!=nil && ![[self.comicDetailDict objectForKey:@"description"] isEqual:[NSNull null]]) {
            [self.descTextView setText:[self.comicDetailDict objectForKey:@"description"]];
        }
        
      
        if ([self.comicDetailDict objectForKey:@"characters"] != nil && [[self.comicDetailDict objectForKey:@"characters"]objectForKey:@"items"] != nil) {
            
            NSMutableArray *charactersArray = [NSMutableArray arrayWithArray:[[self.comicDetailDict objectForKey:@"characters"]objectForKey:@"items"]];
            
            NSString * characters = [[charactersArray valueForKey:@"name"] componentsJoinedByString:@", "];
            NSLog(@"characters :%@",characters);
            [self.charactersTextView setText:characters];
        }
        
        
    }
    
}

-(void)showEvents {
    
    EventListViewController *eventListViewController = [[EventListViewController alloc] init];
    eventListViewController.comicID = [self.comicDetailDict objectForKey:@"id"];
    [self.navigationController pushViewController:eventListViewController animated:YES];
    
}

@end
