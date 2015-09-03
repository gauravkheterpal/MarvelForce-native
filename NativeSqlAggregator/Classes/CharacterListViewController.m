//
//  CharacterListViewController.m
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 8/10/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "CharacterListViewController.h"
#import "CharacterDetailViewController.h"

@interface CharacterListViewController ()

@end

@implementation CharacterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Character";
    [self getMarvelCharactersList];
    self.charactersInfoWithImageArray = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/6/20/52602f21f29ec/portrait_incredible.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    [backgroundImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
    [self.tableView setBackgroundView:backgroundImageView];
    
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
    return [self.charactersInfoWithImageArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.charactersInfoWithImageArray[indexPath.row]];
    
    NSString *characterName = [item objectForKey:@"name"];
    NSLog(@"comic character name == %@",characterName);
    cell.textLabel.text = characterName;
    NSString *imageURLStr = [NSString stringWithFormat:@"%@/%@.%@",[[item objectForKey:@"thumbnail"]objectForKey:@"path"],IMAGE_TYPE_PLACEHOLDER,[[item objectForKey:@"thumbnail"]objectForKey:@"extension"]];
    
    NSURL *imageURL = [NSURL URLWithString:[imageURLStr stringByReplacingOccurrencesOfString:IMAGE_TYPE_PLACEHOLDER withString:STANDARD_MEDIUM]];
    
    NSLog(@"URL = %@",imageURL);
    [cell.imageView sd_setImageWithURL:imageURL
                          placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    
    return cell;
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
        NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.charactersInfoWithImageArray[indexPath.row]];
        NSString *characterId = [item objectForKey:@"id"];
        CharacterDetailViewController *characterDetailViewController = [[CharacterDetailViewController alloc]init];
        characterDetailViewController.characterId = characterId;
        [self.navigationController pushViewController:characterDetailViewController animated:YES];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Array Count : %lu",(unsigned long)self.charactersInfoWithImageArray.count);
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            });
        }
     
     
    }];
}

@end
