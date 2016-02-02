//
//  PostViewController.h
//  ThoughtBot
//
//  Created by Charlie Jacobson on 2/1/16.
//  Copyright © 2016 IntroToiOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import "MarkovModel.h"

@interface PostViewController : UIViewController

- (instancetype)initWithFriend: (TWTRUser *) friendToMimic_;

@property TWTRSession *currentSession;
@property TWTRUser *friendToMimic;

@property MarkovModel *friendModel;

@property UILabel *postLabel;
@property UIButton *postButton;
@property UIButton *reloadButton;

@end
