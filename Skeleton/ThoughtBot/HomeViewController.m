//
//  HomeViewController.m
//  ThoughtBot
//
//  Created by Charlie Jacobson on 2/1/16.
//  Copyright © 2016 IntroToiOS. All rights reserved.
//

#import "HomeViewController.h"
#import "AFNetworking.h"
#import "PostViewController.h"

@interface HomeViewController()

@end

@implementation HomeViewController


- (instancetype)init
{
	self = [super init];
	if (self) {
		self.friends = @[];
	
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
}



- (void) getTwitterFriends
{
	TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:self.currentSession.userID];
	NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/friends/list.json";
	NSDictionary *params = @{@"id" : self.currentSession.userID};
	NSError *clientError;
	
	NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
	
	if (request) {
		[client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			if (data) {
				// handle the response data e.g.
				NSError *jsonError;
				NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
				NSLog(@"Results: %@", json);
				[self parseTwitterFriendsForResponse:json];
				
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

- (void) parseTwitterFriendsForResponse: (NSDictionary *) response
{
	NSArray *friendsData = [response valueForKey:@"users"];
	self.friends = [TWTRUser usersWithJSONArray:friendsData];
	for (TWTRUser *friend in self.friends) {\
		NSLog(@"%@ (%@)", friend.name, friend.screenName);
	}
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
