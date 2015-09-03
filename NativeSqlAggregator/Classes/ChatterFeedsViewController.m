//
//  ChatterFeedsViewController.m
//  SalesForceMarvels
//
//  Created by Bhavna Gupta on 01/09/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "ChatterFeedsViewController.h"
#import "SVProgressHUD.h"
#import "SFRestAPI+Blocks.h"
#import "SFRestAPI+Files.h"
#import "SFRestAPI.h"
#import "ChatterRecord.h"
#import "Util.h"
#import "NewChatterFeedViewController.h"
#import "SFUserAccountManager.h"

@interface ChatterFeedsViewController ()

@end

@implementation ChatterFeedsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *imageURL = [NSURL URLWithString:@"http://i.annihil.us/u/prod/marvel/i/mg/4/60/52695285d6e7e/portrait_incredible.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    [backgroundImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder.png"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
    [self.tableView setBackgroundView:backgroundImageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"NewFeed" style:UIBarButtonItemStyleBordered target:self action:@selector(newFeedTap)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated {
    
    self.chatterFeedsArray = [[NSMutableArray alloc]init];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [super viewDidAppear:animated];
    [self fetchChatterFeed];
}

-(void)newFeedTap{
    
    NewChatterFeedViewController *newChatter = [[NewChatterFeedViewController alloc]init];
    UINavigationController *nvCtrl = [[UINavigationController alloc]initWithRootViewController:newChatter];
     
    [self presentViewController:nvCtrl animated:YES completion:nil];

}

-(void)fetchChatterFeed {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *chatterfeedPath = @"v27.0/chatter/feeds/news/me/feed-items";
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET path:chatterfeedPath queryParams:nil];

    [[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
        
        NSLog(@"Error :%@",e);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        
    } completeBlock:^(id response) {
        
        NSArray *records = [response objectForKey:@"items"];
        NSLog(@"Records = %@",records);
        for (NSDictionary *record in records) {
            
            ChatterRecord *chatterRec = [[ChatterRecord alloc]init];
            chatterRec.chatterActorName = [[record valueForKey:@"actor"]valueForKey:@"name"];
            chatterRec.chatterBodyText =  [[record valueForKey:@"body"]valueForKey:@"text"];
            chatterRec.imageURLString = [[[record valueForKey:@"actor"]valueForKey:@"photo"]valueForKey:@"smallPhotoUrl"];
            chatterRec.attachmentDetail = [record valueForKey:@"attachment"];
            NSLog(@"imageURLString:%@",chatterRec.imageURLString);
            [self.chatterFeedsArray addObject:chatterRec];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        });

        
    }];
    
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
    return self.chatterFeedsArray.count;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    backgroundView.backgroundColor = [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1.0f];
    backgroundView.alpha = 0.7;
    cell.backgroundView = backgroundView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   // if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //}
    
    // Configure the cell...
    
    ChatterRecord *chatterRecord = [self.chatterFeedsArray objectAtIndex:indexPath.row];
    if(chatterRecord !=nil) {
        UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(45, 5, self.tableView.frame.size.width - 60, 22)];
        nameLbl.backgroundColor = [UIColor clearColor];
        nameLbl.text = chatterRecord.chatterActorName;
        nameLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        nameLbl.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:nameLbl];
       
        
        
        UILabel *contentLbl = [[UILabel alloc]initWithFrame:CGRectMake(45, 30, self.tableView.frame.size.width - 50, 60)];
        contentLbl.backgroundColor = [UIColor clearColor];
        contentLbl.numberOfLines = 0;
        contentLbl.font = [UIFont systemFontOfSize:14];
        contentLbl.lineBreakMode = NSLineBreakByWordWrapping;
        contentLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        contentLbl.text = chatterRecord.chatterBodyText;
        //Calculate the expected size based on the font and linebreak mode of your label
        // FLT_MAX here simply means no constraint in height
        CGSize maximumLabelSize = CGSizeMake(280, FLT_MAX);
        
        CGSize expectedLabelSize = [chatterRecord.chatterBodyText sizeWithFont:contentLbl.font constrainedToSize:maximumLabelSize lineBreakMode:contentLbl.lineBreakMode];
        
        //adjust the label the the new height.
        CGRect newFrame = contentLbl.frame;
        newFrame.size.height = expectedLabelSize.height +20;
        contentLbl.frame = newFrame;
        
        
        [cell.contentView addSubview:contentLbl];
        
        UIImageView *imageView = [[ UIImageView alloc]initWithFrame:CGRectMake(5, 5, 32, 32)];
        imageView.tag = kCellImageViewTag;
        // Only load cached images; defer new downloads until scrolling ends
        if (!chatterRecord.chatterActorIcon)
        {
            imageView.image = [UIImage imageNamed:@"chatter_icon.png"];
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:chatterRecord forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            
        }
        else
        {
            imageView.image = chatterRecord.chatterActorIcon;
        }
        [cell.contentView addSubview:imageView];
        
        if (chatterRecord.attachmentDetail != nil && chatterRecord.attachmentDetail != (id)[NSNull null]) {
            
            NSLog(@"Download url :%@ title :%@ index: %lu",[chatterRecord.attachmentDetail valueForKey:@"downloadUrl"],[chatterRecord.attachmentDetail valueForKey:@"title"],indexPath.row);
            
            if ([chatterRecord.attachmentDetail valueForKey:@"id"] != nil && [chatterRecord.attachmentDetail valueForKey:@"id"] != (id)[NSNull null] && [chatterRecord.attachmentDetail valueForKey:@"fileExtension"] != nil && [chatterRecord.attachmentDetail valueForKey:@"fileExtension"] != (id)[NSNull null] && ([[chatterRecord.attachmentDetail valueForKey:@"fileExtension"] isEqual:@"jpg"] || [[chatterRecord.attachmentDetail valueForKey:@"fileExtension"] isEqual:@"png"])) {
                
                UIImageView *attachmentImg = [[ UIImageView alloc]initWithFrame:CGRectMake(cell.frame.size.width-50, 40, 45, 45)];
                attachmentImg.tag = kAttachmentImageTag;
                
                SFRestRequest *imageRequest = [[SFRestAPI sharedInstance]requestForFileContents:[chatterRecord.attachmentDetail valueForKey:@"id"] version:nil];
                [[SFRestAPI sharedInstance]sendRESTRequest:imageRequest failBlock:nil completeBlock:^(id response) {
                    
                    NSData *responseData = response;
                    UIImage *image = [UIImage imageWithData:responseData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [attachmentImg setImage:image];
                
                    });
                }];
                
                [cell.contentView addSubview:attachmentImg];
            }
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSDictionary *chatterRecord = [self.chatterArr objectAtIndex:indexPath.row];
    ChatterRecord *chatterRecord = [self.chatterFeedsArray objectAtIndex:indexPath.row];
    if(chatterRecord !=nil) {
        //Calculate the expected size based on the font and linebreak mode of your label
        // FLT_MAX here simply means no constraint in height
        CGSize maximumLabelSize = CGSizeMake(280, FLT_MAX);
        
        CGSize expectedLabelSize = [chatterRecord.chatterBodyText sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        //if((expectedLabelSize.height +35) < 44)
        //  return 44;
        //NSLog(@"expectedLabelSize.height  %f",expectedLabelSize.height +1700);
        return expectedLabelSize.height +100;
    }
    return 44;
    
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
- (void)startIconDownload:(ChatterRecord *)chatterFeedRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.chatterRecord = chatterFeedRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload:@"Chatter"];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.chatterFeedsArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            ChatterRecord *chatterUser = [self.chatterFeedsArray objectAtIndex:indexPath.row];
            if (!chatterUser.chatterActorIcon) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:chatterUser forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
        // Display the newly loaded image
        imageView.image = iconDownloader.chatterRecord.chatterActorIcon;
    }
}

//Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
