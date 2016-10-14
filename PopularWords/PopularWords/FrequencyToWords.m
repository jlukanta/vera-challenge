//
//  FrequencyToWords.m
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-26.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "FrequencyToWords.h"

@interface WordNode : NSObject
@property (nonatomic, readonly) NSString* word;
@property (nonatomic) WordNode* next;

- (id)initWithWord:(NSString*)word;
@end

@implementation WordNode
- (id)initWithWord:(NSString *)word
{
    self = [super init];
    if (self) {
        _word = word;
    }
    return self;
}
@end

@interface FrequencyToWords()
@property (nonatomic) NSMutableArray* frequencyBuckets; // words indexed by frequency
@end

@implementation FrequencyToWords
- (id)initWithMaximumFrequency:(NSUInteger)maxFrequency
{
    self = [super init];
    if (self) {
        _maximumFrequency = maxFrequency;
        self.frequencyBuckets = [self createBucketsArrayWithSize:maxFrequency+1];
    }
    return self;
}

- (void)addWord:(NSString*)word frequency:(NSUInteger)frequency
{
    if (frequency && frequency <= self.maximumFrequency) {
        WordNode* node = [[WordNode alloc] initWithWord:word];
        WordNode* head = [self headWordNodeWithFrequency:frequency];
        node.next = head;
        self.frequencyBuckets[frequency] = node;
    }
}

- (NSMutableArray*)createBucketsArrayWithSize:(NSUInteger)size
{
    // NSMutableArray or NSArray get/set operations usually take O(1), but there is no guarantee.
    // It can take log N in worst case.
    //
    // So I have two options:
    // 1. Roll out my own array implementation (backed by C array)
    // 2. Use NSMutableArray / NSArray
    //
    // I decided to use NSArray / NSMutableArray because in practise their performance is rarely
    // a problem. I could roll out my own array implementation, but it is very messy, especially
    // with ARC and is a bad practise in general.
    //
    // For the sake of this exercise, I will pretend that NSMutableArray/NSArray will have O(1)
    // run time complexity for get/set operation.
    //
    // If you feel I should implement this custom array class, please let me know and I will
    // spend some time to do it.
    
    NSMutableArray* buckets = [NSMutableArray arrayWithCapacity:size];
    
    // We need to populate the array with NSNull object
    // before setting element at any index within the bounds of (0, size-1) otherwise
    // it will crash. This concept is important for bucket sort.
    
    for (NSUInteger i = 0; i < size; i++) {
        [buckets addObject:[NSNull null]];
    }
    return buckets;
}

- (WordNode*)headWordNodeWithFrequency:(NSUInteger)frequency
{
    if (frequency && frequency <= self.maximumFrequency) {
        id obj = self.frequencyBuckets[frequency];
        if ([obj isEqual:[NSNull null]]) {
            return nil;
        }
        return (WordNode*)obj;
    }
    return nil;
}

- (NSArray*)wordsWithFrequency:(NSUInteger)frequency maxCount:(NSUInteger)maxCount
{
    NSMutableArray* wordsList = nil;
    WordNode* head = [self headWordNodeWithFrequency:frequency];
    
    if (head) {
        // We don't want to allocate too much in case maxCount is something ridiculously big like MAX_INT
        NSUInteger capacity = MIN(maxCount, 5);
        wordsList = [[NSMutableArray alloc] initWithCapacity:capacity];

        NSUInteger count = 0;
        while (head && count < maxCount) {
            [wordsList addObject:head.word];
            head = head.next;
            count ++;
        }
    }
    
    return wordsList;
}

@end
