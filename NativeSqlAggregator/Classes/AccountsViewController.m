//
//  AccountsViewController.m
//  SocialForce
//
//  Created by Ritika on 10/05/13.
//  Copyright (c) 2013 Metacube. All rights reserved.
//

#import "AccountsViewController.h"
#import "DetailViewController.h"
#import "Util.h"
@interface AccountsViewController ()

@end

@implementation AccountsViewController
@synthesize SFAccountsArr;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchSFAccountsList];
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/6/70/4cd061e6d6573/portrait_incredible.jpg"];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenOriginX = screenRect.origin.x;
    CGFloat screenOriginY = screenRect.origin.y;
    CGRect WindowFrame = CGRectMake(screenOriginX, screenOriginY, screenWidth, screenHeight);
    UIView *backgroundView = [[UIView alloc]initWithFrame:WindowFrame];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:WindowFrame];
    [imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    [backgroundView addSubview:imageView];
    [accTable setBackgroundView:backgroundView];
    self.title = @"Accounts";
//    if(UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
//        if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
//        {
//            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault];
//            NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIColor grayColor],UITextAttributeTextColor,
//                                                       [UIColor lightGrayColor], UITextAttributeTextShadowColor,
//                                                       [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
//            self.navigationController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
//            self.navigationController.navigationBar.tintColor = [UIColor grayColor];
//        }
//    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self changeBkgrndImgWithOrientation];
}
-(void)changeBkgrndImgWithOrientation {
    
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_320x480.png"]];
    [backgroundImgView setFrame:accTable.frame];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bg_480x320.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bg_320x480.png"];
        }
    } else {
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bg_1024x748.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bg_768x1004.png"];
        }
    }
    accTable.backgroundView = backgroundImgView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fetchSFAccountsList {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *queryString = @"SELECT Name,Id from Account Order by Name";
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:queryString];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}
#pragma mark - Table view data source


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    backgroundView.backgroundColor = [UIColor lightTextColor];
    backgroundView.alpha = 0.7;
    cell.backgroundView = backgroundView;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.filteredAccountArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==  nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [[self.filteredAccountArr objectAtIndex:indexPath.row]valueForKey:@"Name"];
    // Configure the cell...
    
//    cell.imageView.image = [Utility resizeImage:[UIImage imageNamed:@"company_icon.png"] withWidth:30 withHeight:30];
    return cell;
}
#pragma mark - SFRestDelegate methods
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
    
    NSLog(@"request:%@",[request description]);
    NSLog(@"jsonResponse:%@",jsonResponse);
    
//    if([[request description] rangeOfString:@"SELECT"].location != NSNotFound)
//    {
        if([[jsonResponse objectForKey:@"errors"] count]==0)
        {
            
            //If this is a record fetch request, execute the following bunch of code
            
            //Hide progress indicator
            
            //            dialog_imgView.hidden = YES;
            //            loadingLbl.hidden = YES;
            //            doneImgView.hidden = YES;
            //            [loadingSpinner stopAnimating];
            
            NSArray *records = [jsonResponse objectForKey:@"records"];
            
            
//            NSLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
//            NSLog(@"records count...%d",records.count);
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Name"  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            
            [self.SFAccountsArr removeAllObjects];
            self.SFAccountsArr =(NSMutableArray*)[records sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            
            //[selectedRow removeAllObjects];
            
            if([self.SFAccountsArr count] != 0)
            {
                self.filteredAccountArr = self.SFAccountsArr;
                //dict = [self fillingDictionary:cellIndexData];
            }
        }
        else
        {
            NSLog(@"Error");
        }
        
        
//    }
//    else
//    {
    
//        if([[jsonResponse objectForKey:@"errors"] count]==0)
//        {
//            
//        }
//        else
//        {
//            
//        }
//        
        //        [Utility hideCoverScreen];
//    }
    
    accTable.dataSource = self;
    accTable.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
            [accTable reloadData];
        [SVProgressHUD dismiss];
    });

}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error
{
    //Show back button
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    NSLog(@"request:didFailLoadWithError: %@ code:%ld", error,(long)error.code);
    
    //Hide loading indicator
    //    [Utility hideCoverScreen];
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Salesforce Error" message:@"An error occured.Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}



- (void)requestDidCancelLoad:(SFRestRequest *)request
{
    //Show back button
    [SVProgressHUD dismiss];
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
    
    //    [Utility hideCoverScreen];
    
}

- (void)requestDidTimeout:(SFRestRequest *)request
{
    //Show back button
    [SVProgressHUD dismiss];
    //add your failed error handling here
    //    [Utility hideCoverScreen];
    
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
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.recordId = [[self.filteredAccountArr objectAtIndex:indexPath.row]valueForKey:@"Id"];
    detailViewController.recordType = @"Account";
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];

}
#pragma mark - UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar  {                     // return NO to not become first responder
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;// called when text starts editing
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {                       // return NO to not resign first responder
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;// called when text ends editing
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {   // called when text changes (including clear)
    
    NSLog(@"searchBar.text:%@",searchBar.text);
    NSLog(@"searchText:%@",searchText);
    NSPredicate *bPredicate =
    //[NSPredicate predicateWithFormat:@"SELF beginswith[c] '%@'",searchText];
    [NSPredicate predicateWithFormat:@"Name contains[c] %@",searchText];
    if(![searchText isEqualToString:@""])
        self.filteredAccountArr = [self.SFAccountsArr filteredArrayUsingPredicate:bPredicate];
    else
        self.filteredAccountArr = self.SFAccountsArr;
    [accTable reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.filteredAccountArr = self.SFAccountsArr;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [accTable reloadData];
}
#pragma mark -
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self changeBkgrndImgWithOrientation];
}
- (void)dealloc {
}
@end
