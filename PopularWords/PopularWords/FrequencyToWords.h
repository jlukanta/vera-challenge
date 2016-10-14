//
//  FrequencyToWords.h
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-26.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrequencyToWords : NSObject

@property (nonatomic, readonly) NSUInteger maximumFrequency;

- (id)initWithMaximumFrequency:(NSUInteger)maxFrequency;

// frequency = 0 and lower is invalid because that means the word never appears
- (void)addWord:(NSString*)word frequency:(NSUInteger)frequency;

// If there are more than maxCount words that matches, we only return maxCount words
// eg. Suppose we are asking for words with frequency = 4, maxCount 3.
//     There are 10 words matching this description. Then we will just return 3 words, not 10.
//     If there are 2 words matching this description, then we will return 2.
- (NSArray*)wordsWithFrequency:(NSUInteger)frequency maxCount:(NSUInteger)maxCount;
@end
