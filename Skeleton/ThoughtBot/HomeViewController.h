//
//  HomeViewController.h
//  ThoughtBot
//
//  Created by Charlie Jacobson on 2/1/16.
//  Copyright © 2016 IntroToiOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>

@interface HomeViewController : UIViewController 

@property TWTRSession *currentSession;

@property NSArray<TWTRUser *> *friends;

- (instancetype)init;

@end
