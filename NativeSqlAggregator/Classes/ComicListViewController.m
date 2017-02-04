//
//  ComicListViewController.m
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 8/11/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "ComicListViewController.h"
#import "ComicDetailViewController.h"

@interface ComicListViewController ()

@end

@implementation ComicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Comics";
    self.comicListArray = [[NSMutableArray alloc] init];
    [self getMarvelComicList];
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/9/30/535feab462a64/portrait_incredible.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    [backgroundImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
   // [self.tableView setBackgroundView:backgroundImageView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
     return [self.comicListArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.comicListArray[indexPath.row]];
    
    NSString *comicName = [item objectForKey:@"title"];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = comicName;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    cell.indentationWidth = 10; // The amount each indentation will move the text
    cell.indentationLevel = 4;
    
    NSString *imageURLStr = [NSString stringWithFormat:@"%@/%@.%@",[[item objectForKey:@"thumbnail"]objectForKey:@"path"],IMAGE_TYPE_PLACEHOLDER,[[item objectForKey:@"thumbnail"]objectForKey:@"extension"]];
    
    NSURL *imageURL = [NSURL URLWithString:[imageURLStr stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
    
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 5.0f, 35.0f, 35.0f)];
    
    [iconImageView sd_setImageWithURL:imageURL
                     placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    
    [cell.contentView addSubview:iconImageView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.comicListArray[indexPath.row]];
    
    NSString *comicName = [item objectForKey:@"title"];
    
    if (comicName != nil) {
        
        CGRect rect = [comicName boundingRectWithSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX)
                                              options:NSLineBreakByWordWrapping | NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f]}
                                              context:nil];
        return rect.size.height + 30;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    backgroundView.backgroundColor = [UIColor lightTextColor];
    backgroundView.alpha = 0.7;
    cell.backgroundView = backgroundView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.comicListArray[indexPath.row]];
    NSString *comicId = [item objectForKey:@"id"];
    
    ComicDetailViewController *comicDetailViewController = [[ComicDetailViewController alloc]init];
    comicDetailViewController.comicId = comicId;
    [self.navigationController pushViewController:comicDetailViewController animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getMarvelComicList
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *stringForHash = [NSString stringWithFormat:@"%@%@%@",TS,MARVEL_PRIVATE_KEY,MARVEL_PUBLIC_KEY];
    NSString *hashString = [Util md5:stringForHash];
    NSURL *marvelCharURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/comics?ts=%@&apikey=%@&hash=%@",MARVEL_SERVER_URL,MARVEL_GET_CHAR_API_URL,self.characterID,TS,MARVEL_PUBLIC_KEY,hashString]];
    
    NSLog(@"REQUEST URL : %@",marvelCharURL);
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
                [self.comicListArray addObject:[charInfoArray objectAtIndex:count]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Array Count : %lu Array Data :%@",(unsigned long)self.comicListArray.count,self.comicListArray);
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            });
        }
        
        
    }];
}

@end
