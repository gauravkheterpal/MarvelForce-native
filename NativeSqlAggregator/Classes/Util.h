//
//  Util.h
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 7/17/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MARVEL_PRIVATE_KEY @"229e1692e67820a99745cd7889af0017f8c5317f"
#define MARVEL_PUBLIC_KEY @"1971c5c1a55b92fbbd444d12b4831d38"
#define TS @"1"


#define  MARVEL_SERVER_URL @"http://gateway.marvel.com"
#define MARVEL_GET_CHAR_API_URL @"/v1/public/characters"
#define MARVEL_GET_CHAR_DETAIL_API_URL @"/v1/public/characters/"
#define MARVEL_GET_COMIC_DETAIL_API_URL @"/v1/public/comics/"


#define SF_CONTACT_QUERY @"SELECT Name, Id,PhotoUrl,Marvel_Image__c,Marvel_ID__c FROM Contact"

#define IMAGE_TYPE_PLACEHOLDER @"imagetypeplaceholder"
#define PORTRAIT_SMALL @"portrait_small"            //50x75px
#define PORTRAIT_MEDIUM @"portrait_medium"          //100x150px
#define PORTRAIT_XLARGE @"portrait_xlarge"          //150x225px
#define PORTRAIT_FANTASTIC @"portrait_fantastic" 	//168x252px
#define PORTRAIT_UNCANNY @"portrait_uncanny"        //300x450px
#define PORTRAIT_INCREDIBLE @"portrait_incredible"  //216x324px

#define STANDARD_MEDIUM @"standard_medium"

#define MARVEL_IMAGE_URL_FIELD_NAME @"Marvel_Image__c"
#define MARVEL_CHAR_ID_FIELD_NAME @"Marvel_ID__c"

#define CHATTER_POST_LIMIT_ALERT_TAG               2000
#define CHATTER_POST_TO_GROUP_LIMIT_ALERT_TAG      3000
#define kCellImageViewTag           1000
#define kAttachmentImageTag         1001

#define NETWORK_UNAVAILABLE_MSG  @"No network connectivity!"
#define ALERT_POSITIVE_BUTTON_TEXT @"Yes"
#define ALERT_NEGATIVE_BUTTON_TEXT @"No"
#define ALERT_NEUTRAL_BUTTON_TEXT @"OK"
#define LOADING_MSG @"Loading..."
#define DONE_MSG @"Done!"
#define SOME_ERROR_OCCURED_MESSAGE @"An error occurred. Please try again."

#define CHATTER_LIMIT_CROSSED_ALERT_MSG  @"The number of characters in your note exceed the allowed limit on Salesforce Chatter.Do you want to truncate note content & post?"
#define CHATTER_LIMIT_CROSSED_ERROR_MSG @"The number of characters in your note exceed the allowed limit on Salesforce Chatter. Please split your content into multiple notes and try again."
#define CHATTER_MENTIONS_CROSSED_ERROR_MSG @"The number of Mentions exceed the allowed limit on Salesforce Chatter. Please deselect some users and try again."
#define SF_FIELDS_LIMIT_CROSSED_ERROR_MSG @"The number of characters in your note exceed the length of the Salesforce field. Please choose another field and try again"
#define CHATTER_API_DISABLED @"Unable to post. Chatter Connect API is disabled."

#define POST_TO_CHATTER_WALL_URL @"v27.0/chatter/feeds/news/me/feed-items"
#define POST_TO_USER_WALL_URL @"v27.0/chatter/feeds/user-profile/me/feed-items"
#define LIST_OF_CHATTER_FOLLOWING_URL @"/services/data/v27.0/chatter/users/me/following?filterType=005&pageSize=1000"
#define LIST_OF_CHATTER_GROUP_URL @"v27.0/chatter/users/me/groups?pageSize=250"
#define APP_SUITE_NAME @"group.metacube.mobile.salesforcemarvel"

@interface Util : NSObject

+ (NSString *) md5:(NSString *) input;

+ (id) getValueFor:(NSString *) key inJSON:(NSDictionary *) dict;


@end
