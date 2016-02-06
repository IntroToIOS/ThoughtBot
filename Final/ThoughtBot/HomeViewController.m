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
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.loginButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
		
		// logged in successfully
		if (session) {
			
			self.currentSession = session;
			
			// show table view
			CGRect friendsTableRect = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 50);
			self.friendsTable = [[UITableView alloc] initWithFrame:friendsTableRect style:UITableViewStylePlain];
			self.friendsTable.dataSource = self;
			self.friendsTable.delegate = self;
			[self.view addSubview:self.friendsTable];
			
			// show signed in username at bottom
			CGRect signedInFrame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 40);
			UILabel *signedInLabel = [[UILabel alloc] initWithFrame:signedInFrame];
			[self.view addSubview:signedInLabel];
			
			// text: "Signed in as [user]"
			NSString *signedInText = [NSString stringWithFormat:@"Signed in as %@", [session userName]];
			signedInLabel.text = signedInText;
			signedInLabel.textColor = [UIColor blackColor];
			signedInLabel.textAlignment = NSTextAlignmentCenter;
			
			// remove log in button
			self.loginButton.alpha = 0;
			
			// fetch Twitter friends
			[self getTwitterFriends];
		}
		// logged in failed
		else {
			NSLog(@"Login error: %@", [error localizedDescription]);
		}
	}];
	
	self.loginButton.center = self.view.center;
	[self.view addSubview:self.loginButton];

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
				[self.friendsTable reloadData];
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

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"FriendCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}
	
	TWTRUser *currentFriend = [self.friends objectAtIndex:indexPath.row];
	cell.textLabel.text = currentFriend.name;
	cell.detailTextLabel.text = [NSString  stringWithFormat:@"@%@", currentFriend.screenName];
	
	return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TWTRUser *selectedFriend = [self.friends objectAtIndex:indexPath.row];
	PostViewController *postVC = [[PostViewController alloc] initWithFriend:selectedFriend];
	postVC.currentSession = self.currentSession;
	[self.navigationController pushViewController:postVC animated:YES];
}
#pragma mark - Memory
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
