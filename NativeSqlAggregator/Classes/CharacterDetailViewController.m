//
//  CharacterDetailViewController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 11/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "CharacterDetailViewController.h"
#import "SVProgressHUD.h"
#import "Util.h"
#import "ComicListViewController.h"

@interface CharacterDetailViewController ()

@end

@implementation CharacterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Show Comics" style:UIBarButtonItemStyleDone target:self action:@selector(showComics)];
    self.characterDetailDict = [[NSDictionary alloc]init];
    self.storyDataArray = [[NSMutableArray alloc]init];
    [self getMarvelCharacterDetail];
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

-(void)getMarvelCharacterDetail
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *stringForHash = [NSString stringWithFormat:@"%@%@%@",TS,MARVEL_PRIVATE_KEY,MARVEL_PUBLIC_KEY];
    NSString *hashString = [Util md5:stringForHash];
    NSURL *marvelCharURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@?ts=%@&apikey=%@&hash=%@",MARVEL_SERVER_URL,MARVEL_GET_CHAR_DETAIL_API_URL,self.characterId,TS,MARVEL_PUBLIC_KEY,hashString]];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:marvelCharURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSError *error1 = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error1 != nil) {
            NSLog(@"Error parsing JSON.");
        }
        else {
            NSLog(@"Detail status %@ data : %@",[jsonDict objectForKeyedSubscript:@"status"],[jsonDict objectForKeyedSubscript:@"data"]);
            NSMutableArray *charDetailArray = [NSMutableArray arrayWithArray:[[jsonDict objectForKeyedSubscript:@"data"] objectForKey:@"results"]];
            if (charDetailArray.count>0 && [charDetailArray objectAtIndex:0]
                != nil) {
                self.characterDetailDict = [charDetailArray objectAtIndex:0];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setMarvelCharacterDetail];
                self.storyLbl.hidden = NO;
                [SVProgressHUD dismiss];
            });
        }
        
        
    }];
}

-(void)setMarvelCharacterDetail {
    
    if (self.characterDetailDict != nil) {
        
        NSString *imageURL = [NSString stringWithFormat:@"%@/%@.%@",[[self.characterDetailDict objectForKey:@"thumbnail"]objectForKey:@"path"],IMAGE_TYPE_PLACEHOLDER,[[self.characterDetailDict objectForKey:@"thumbnail"]objectForKey:@"extension"]];
        
        // Get the Layer of charcter image
        CALayer * l = [self.characterImage layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:10.0];
        // You can even add a border
        [l setBorderWidth:2.0];
        [l setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
        
        
        if ([imageURL rangeOfString:@"image_not_available"].location == NSNotFound) {
            NSURL *portrait_incridible_imageURL = [NSURL URLWithString:[imageURL stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:PORTRAIT_INCREDIBLE]];
            //    portrait_incredible
            [self.backgroundImage sd_setImageWithURL:portrait_incridible_imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
            
            NSURL *standard_medium_imageURL = [NSURL URLWithString:[imageURL stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
            
            [self.characterImage sd_setImageWithURL:standard_medium_imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
            
        }else {
            
            [self.backgroundImage setImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
            [self.characterImage setImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
        }
        
        [self.NameLbl setText:[Util getValueFor:@"name" inJSON:self.characterDetailDict]];
        if ([self.characterDetailDict objectForKey:@"stories"]!=nil) {
            
            NSDictionary *storyDict = [self.characterDetailDict objectForKey:@"stories"];
            if ([storyDict objectForKey:@"items"]!=nil) {
                NSMutableArray *storyArray =  [NSMutableArray arrayWithArray:[storyDict objectForKey:@"items"]];
                for (int count = 0; count < [storyArray count]; count++) {
                    [self.storyDataArray addObject:[storyArray objectAtIndex:count]];
                }
            }
        }
        
        // Get the Layer of story list
        CALayer * storyTblLayer = [self.storyListView layer];
        [storyTblLayer setMasksToBounds:YES];
        [storyTblLayer setCornerRadius:10.0];
        //add a border
        [storyTblLayer setBorderWidth:2.0];
        [storyTblLayer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
       
        
        if (self.storyDataArray.count>0) {
            
            self.storyListView.hidden = false;
            self.storyListView.delegate = self;
            self.storyListView.dataSource = self;
            [self.storyListView reloadData];
            
        } else {
            self.storyNotAvailableLbl.hidden = false;
            
        }
    }
    
}

-(void)showComics {
    
    ComicListViewController *comicListViewController = [[ComicListViewController alloc] init];
    comicListViewController.characterID = self.characterId;
    [self.navigationController pushViewController:comicListViewController animated:YES];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.storyDataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.storyDataArray[indexPath.row]];
    
    NSString *storyName = [item objectForKey:@"name"];
    
    if (storyName != nil) {
        
        CGRect rect = [storyName boundingRectWithSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX)
                                                 options:NSLineBreakByWordWrapping | NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f]}
                                                 context:nil];
        return rect.size.height + 30;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.storyDataArray[indexPath.row]];
    
    NSString *storyName = [item objectForKey:@"name"];
    NSLog(@"story name == %@",storyName);
    cell.textLabel.text = storyName;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSString *storyType = [item objectForKey:@"type"];
    cell.detailTextLabel.text = storyType;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    backgroundView.backgroundColor = [UIColor lightTextColor];
    cell.backgroundView = backgroundView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
}



@end
