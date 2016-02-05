//
//  PostViewController.m
//  ThoughtBot
//
//  Created by Charlie Jacobson on 2/1/16.
//  Copyright © 2016 IntroToiOS. All rights reserved.
//

#import "PostViewController.h"
#import "MarkovModel.h"

@implementation PostViewController

- (instancetype)initWithFriend:(TWTRUser *)friendToMimic_
{
	self = [super init];
	if (self) {
		self.friendToMimic = friendToMimic_;
		self.title = [NSString stringWithFormat:@"Tweeting like @%@", self.friendToMimic.screenName];
	}
	return self;
}

- (void)viewDidLoad
{
	self.view.backgroundColor = [UIColor whiteColor];

	self.postLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 84, self.view.frame.size.width - 40, 350)];
	self.postLabel.backgroundColor = [UIColor whiteColor];
	self.postLabel.font = [UIFont systemFontOfSize:18];
	self.postLabel.numberOfLines = 0;
	[self.view addSubview:self.postLabel];
	
	self.reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.reloadButton.frame = CGRectMake(20, 84 + 350  + 20, self.view.frame.size.width - 40, 50);
	self.reloadButton.backgroundColor = [UIColor lightGrayColor];
	[self.reloadButton setAdjustsImageWhenHighlighted:YES];
	[self.reloadButton setTitle:@"Try again" forState:UIControlStateNormal];
	[self.reloadButton addTarget:self action:@selector(didTapReload:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.reloadButton];
	
	self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.postButton.frame = CGRectMake(20, 84 + 350 + 20 + 50 + 20, self.view.frame.size.width - 40, 50);
	self.postButton.backgroundColor = [[TWTRLogInButton alloc] init].backgroundColor;
	[self.postButton setTitle:@"Post to Twitter" forState:UIControlStateNormal];
	[self.postButton addTarget:self action:@selector(didTapPost:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.postButton];
	
	[self trainFriendModel];

}



- (void) didTapReload: (UIButton *) button
{
	[self draftPost];
}

- (void) didTapPost: (UIButton *) button
{
	[self postTweet:self.postLabel.text];
}

- (void) draftPost
{
	// draft post
	NSString *postText = [self.friendModel generateStringWithRandomSeedAndLength:130];
	self.postLabel.text = postText;
}

- (void) trainFriendModel
{
	TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:self.currentSession.userID];
	NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
	NSDictionary *params = @{
							 @"id" : self.friendToMimic.userID,
							 @"exclude_replies": @"1",
							 @"count":@"200",
							 @"include_rts":@"0"
							 };
	NSError *clientError;
	
	NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
	
	if (request) {
		[client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			if (data) {
				
				NSError *jsonError;
				NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
				NSLog(@"Results: %@", json);
				
				// parse data
				NSArray *tweets = [TWTRTweet tweetsWithJSONArray:json];
				
				// combine tweets, removing hyperlinks
				NSMutableString *combinedTweets = [NSMutableString stringWithString:@""];
				for (TWTRTweet *tweet in tweets) {
					NSArray *tweetComps = [tweet.text componentsSeparatedByString:@" "];
					for (NSString *word in tweetComps) {
						// ignore links
						if ([word containsString:@"http"] || [word containsString:@".com"]) {
							continue;
						}
						[combinedTweets appendFormat:@"%@ ", word];
					}
				}
				
				
				// train model
				self.friendModel = [[MarkovModel alloc] initWithKValue:6 text:combinedTweets];
				
				[self draftPost];
				
			}
			else {
				NSLog(@"Error: %@", connectionError);
			}
		}];
	}
	else {
		NSLog(@"Error: %@", clientError);
	}

}

- (void) postTweet: (NSString *) tweetText
{
	// add signature to tweet
	tweetText = [tweetText stringByAppendingString:@" via ThoughtBot"];
	
	// create composer
	TWTRComposer *composer = [[TWTRComposer alloc] init];
	[composer setText:tweetText];
	
	// launch
	[composer showFromViewController:self completion:^(TWTRComposerResult result) {
		NSLog(@"Result: %ld", result);
	}];
}


@end
