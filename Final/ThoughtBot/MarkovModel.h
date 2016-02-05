//
//  MarkovModel.h
//  ThoughtBot
//
//  Created by Charlie Jacobson on 2/2/16.
//  Copyright © 2016 IntroToiOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarkovModel : NSObject

@property NSMutableDictionary *kGramCounts;
@property NSMutableDictionary *charAfterKGramCounts;

- (instancetype) initWithKValue: (int) kVal text: (NSString *) text;

- (NSUInteger) frequencyOfKGram: (NSString *) kgram;
- (NSUInteger) frequencyOfChar: (char) nextChar afterKGram: (NSString *) kgram;

- (char) generateRandomCharAfterKGram: (NSString *) kgram;
- (NSString *) generateStringWithSeed: (NSString *) kgramseed length: (int) stringLength;
- (NSString *) generateStringWithRandomSeedAndLength: (int) stringLength;

@end
