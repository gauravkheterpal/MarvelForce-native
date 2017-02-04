//
//  TasksListViewController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 20/08/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "TasksListViewController.h"
#import "TaskDetailViewController.h"
#import "UserProfileViewController.h"
#import "Util.h"


@interface TasksListViewController ()

@end

@implementation TasksListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784/portrait_incredible.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    [backgroundImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
    //[self.tableView setBackgroundView:backgroundImageView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.title = @"Tasks";
    self.taskResultDataSet = [[NSArray alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    NSLog(@"Logged In user :%@",[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId]);
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[NSString stringWithFormat:@"SELECT Id, Subject, Type, Description, ActivityDate, Priority, Status FROM Task WHERE Status != 'Completed' AND OwnerId = '%@' ORDER BY ActivityDate",[[[[SFUserAccountManager sharedInstance]currentUser] idData]userId]]];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)request:(SFRestRequest *)request didLoadResponse:(id)dataResponse
{
    NSArray *records = dataResponse[@"records"];
    if (nil != records && records.count > 0) {
        NSDictionary *firstRecord = records[0];
        if (nil != firstRecord) {
            NSDictionary *attributes = [firstRecord valueForKey:@"attributes"];
            if (nil != attributes) {
                NSString *type = [attributes valueForKey:@"type"];
                if ([type isEqual:@"Task"]) {
                    NSLog(@"Records : %@",records);
                     [self setTaskResultDataSet:records];
                    
                    
                    NSMutableArray *taskArray = [[NSMutableArray alloc]init];
                    for (int cnt = 0; cnt<records.count; cnt++) {
                        
                        NSDictionary *tempDict = [records objectAtIndex:cnt];
                        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
                        if ([tempDict objectForKey:@"Status"]!=nil && [tempDict objectForKey:@"Status"] != (id)[NSNull null]) {
                            [dataDict setValue:[tempDict objectForKey:@"Status"] forKey:@"Status"];
                        }else {
                            [dataDict setValue:@" " forKey:@"Status"];
                        }
                        
                        if ([tempDict objectForKey:@"Subject"]!=nil && [tempDict objectForKey:@"Subject"] != (id)[NSNull null]) {
                            [dataDict setValue:[tempDict objectForKey:@"Subject"] forKey:@"Subject"];
                        }else {
                            [dataDict setValue:@" " forKey:@"Subject"];
                        }
                        
                        if ([tempDict objectForKey:@"Type"]!=nil && [tempDict objectForKey:@"Type"] != (id)[NSNull null]) {
                            [dataDict setValue:[tempDict objectForKey:@"Type"] forKey:@"Type"];
                        }else {
                            [dataDict setValue:@" " forKey:@"Type"];
                        }
                        
                        if ([tempDict objectForKey:@"ActivityDate"]!=nil && [tempDict objectForKey:@"ActivityDate"] != (id)[NSNull null]) {
                            [dataDict setValue:[tempDict objectForKey:@"ActivityDate"] forKey:@"ActivityDate"];
                        }else {
                            [dataDict setValue:@" " forKey:@"ActivityDate"];
                        }
                        
                        if ([tempDict objectForKey:@"Id"]!=nil && [tempDict objectForKey:@"Id"] != (id)[NSNull null]) {
                            [dataDict setValue:[tempDict objectForKey:@"Id"] forKey:@"Id"];
                        }else {
                            [dataDict setValue:@" " forKey:@"Id"];
                        }
                        
                       
                        
                        
                        if (dataDict!=nil) {
                            [taskArray addObject:dataDict];
                        }
                        
                    }
                    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:APP_SUITE_NAME];
                    [shared setObject:taskArray forKey:@"Tasks"];
                    [shared synchronize];
            
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    
                }
                else {
                    /*
                     * If the object is not an account or opportunity,
                     * we do nothing. This block can be used to save
                     * other types of records.
                     */
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
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
    return [self.taskResultDataSet count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    NSDictionary *item = [[NSDictionary alloc]initWithDictionary:self.taskResultDataSet[indexPath.row]];
    NSLog(@"item == %@",item);
    
    cell.textLabel.text = [item objectForKey:@"Subject"];
    cell.detailTextLabel.text = [item objectForKey:@"Status"];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    backgroundView.backgroundColor = [UIColor lightTextColor];
    backgroundView.alpha = 0.7;
    cell.backgroundView = backgroundView;
    
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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    NSDictionary *taskItemDetail = [[NSDictionary alloc]initWithDictionary:self.taskResultDataSet[indexPath.row]];
    
    TaskDetailViewController *taskDetailViewController = [[TaskDetailViewController alloc]init];
    taskDetailViewController.taskDetailDict = taskItemDetail;
    [self.navigationController pushViewController:taskDetailViewController animated:YES];
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
