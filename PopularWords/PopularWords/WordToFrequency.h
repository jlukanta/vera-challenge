//
//  WordToFrequency.h
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-26.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordToFrequency : NSObject
- (id)initWithCapacity:(NSUInteger)capacity;
- (void)enumerateWordsAndFrequencyUsingBlock:(void (^)(NSString* word, NSUInteger frequency, BOOL *stop))block;
- (void)increaseWordFrequency:(NSString*)word by:(NSUInteger)increment;
- (NSUInteger)wordFrequency:(NSString*)word;
- (NSUInteger)uniqueWordsCount;
- (NSUInteger)maximumWordFrequency;
@end
