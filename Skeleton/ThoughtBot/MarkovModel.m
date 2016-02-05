//
//  MarkovModel.m
//  ThoughtBot
//
//  Created by Charlie Jacobson on 2/2/16.
//  Copyright © 2016 IntroToiOS. All rights reserved.
//

#import "MarkovModel.h"

@implementation MarkovModel

- (instancetype)initWithKValue:(int)kVal text:(NSString *)text
{
	self = [super init];
	if (self) {
		[self buildModelWithKValue:kVal text:text];
		
		NSString *test1 = [self generateStringWithSeed:[self.kGramCounts.allKeys objectAtIndex:1] length:100];
		NSString *test2 = [self generateStringWithSeed:[self.kGramCounts.allKeys objectAtIndex:1] length:100];
		NSString *test3 = [self generateStringWithSeed:[self.kGramCounts.allKeys objectAtIndex:1] length:100];
	}
	return self;
}

- (void) buildModelWithKValue:(int)kVal text:(NSString *)text
{
	self.kGramCounts = [NSMutableDictionary dictionary];
	self.charAfterKGramCounts = [NSMutableDictionary dictionary];
	
	// each possible k gram
	for (int i = 0; i < text.length - kVal; i++) {
		NSString *currentKGram = [text substringWithRange:NSMakeRange(i, kVal)];
		char nextChar = [text characterAtIndex:i+kVal];
		
		// increment k gram counter
		NSUInteger kGramCount = [self frequencyOfKGram:currentKGram];
		[self.kGramCounts setObject:@(kGramCount+1) forKey:currentKGram];
		
		// increment char counter
		NSMutableDictionary *freqsForKGram = [self.charAfterKGramCounts objectForKey:currentKGram];
		if (freqsForKGram == nil) {
			freqsForKGram = [NSMutableDictionary dictionary];
		}
		NSUInteger charCount = [[freqsForKGram objectForKey:@(nextChar)] integerValue];
		[freqsForKGram setObject:@(charCount+1) forKey:@(nextChar)];
		[self.charAfterKGramCounts setObject:freqsForKGram forKey:currentKGram];
	}
	
}

- (NSUInteger)frequencyOfKGram:(NSString *)kgram
{
	return [[self.kGramCounts objectForKey:kgram] intValue];
}

- (NSUInteger)frequencyOfChar:(char)nextChar afterKGram:(NSString *)kgram
{
	NSMutableDictionary *freqsForKGram = [self.charAfterKGramCounts objectForKey:kgram];
	if (freqsForKGram == nil) {
		return 0;
	}
	return [[freqsForKGram objectForKey:@(nextChar)] integerValue];
}

-(char)generateRandomCharAfterKGram:(NSString *)kgram
{
	float freqOfKGram = (float)[self frequencyOfKGram:kgram];
	NSMutableDictionary *freqsForCharsAfterKGram = [self.charAfterKGramCounts objectForKey:kgram];
	
	float drawnP = (float)rand() / RAND_MAX;
	
	for (NSNumber *charKey in freqsForCharsAfterKGram) {
		float freqOfChar = ([[freqsForCharsAfterKGram objectForKey:charKey] integerValue]*1.0/freqOfKGram);
		if (drawnP <= freqOfKGram) {
			return [charKey charValue];
		}
		else {
			drawnP -= freqOfKGram;
		}
	}
	return ' ';
}

- (NSString *)generateStringWithSeed:(NSString *)kgramseed length:(int)stringLength
{
	NSMutableString *generatedString = [NSMutableString stringWithString:kgramseed];
	
	NSString *currentKGram = kgramseed;
	while (generatedString.length < stringLength) {
		char nextChar = [self generateRandomCharAfterKGram:currentKGram];
		[generatedString appendFormat:@"%c", nextChar];
		currentKGram = [currentKGram substringFromIndex:1];
		currentKGram = [currentKGram stringByAppendingFormat:@"%c", nextChar];
	}
	
	return generatedString;
}

- (NSString *)generateStringWithRandomSeedAndLength:(int)stringLength
{
	NSUInteger randomIndex = (int)(((float)rand() / RAND_MAX) * [self.kGramCounts.allKeys count]);
	NSString *randomSeed = [self.kGramCounts.allKeys objectAtIndex:randomIndex];
	return [self generateStringWithSeed:randomSeed length:stringLength];
}
@end
