//
//  WordToFrequency.m
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-26.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "WordToFrequency.h"

@interface WordToFrequency()
@property (nonatomic) NSMutableDictionary* wordToFrequency;
@property (nonatomic) NSUInteger maxFrequency;
@end

@implementation WordToFrequency

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self) {
        self.wordToFrequency = [NSMutableDictionary dictionaryWithCapacity:capacity];
        self.maxFrequency = 0;
    }
    return self;
}

- (void)enumerateWordsAndFrequencyUsingBlock:(void (^)(NSString* word, NSUInteger frequency, BOOL *stop))block
{
    [self.wordToFrequency enumerateKeysAndObjectsUsingBlock:^(NSString* word, NSNumber* frequencyVal, BOOL *stop) {
        NSUInteger wordFrequency = [frequencyVal unsignedIntegerValue];
        block(word, wordFrequency, stop);
    }];
}

- (void)increaseWordFrequency:(NSString*)word by:(NSUInteger)increment
{
    if (word && word.length) {
        NSUInteger wordFrequency = [self wordFrequency:word];
        NSUInteger updatedWordFrequency = wordFrequency + increment;
        NSNumber* wordFrequencyValue = [NSNumber numberWithUnsignedInteger:updatedWordFrequency];
        self.wordToFrequency[word] = wordFrequencyValue;
        [self updateMaximumWordFrequencyIfNeeded:updatedWordFrequency];
    }
}

- (NSUInteger)wordFrequency:(NSString*)word
{
    if (word) {
        NSNumber* frequency = self.wordToFrequency[word];
        return [frequency unsignedIntegerValue];
    }
    return 0;
}

- (NSUInteger)uniqueWordsCount {
    return self.wordToFrequency.count;
}

- (NSUInteger)maximumWordFrequency {
    return self.maxFrequency;
}

- (void)updateMaximumWordFrequencyIfNeeded:(NSUInteger)value {
    if (value > self.maxFrequency) {
        self.maxFrequency = value;
    }
}

@end
