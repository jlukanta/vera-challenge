//
//  PopularWordsManager.m
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-26.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "FrequentWordsAnalyzer.h"
#import "WordToFrequency.h"
#import "FrequencyToWords.h"

@interface FrequentWordsAnalyzer()
@property (nonatomic, readonly) NSArray* words;
@property (nonatomic, readonly) NSArray* sortedWords;
@end

@implementation FrequentWordsAnalyzer

- (id)initWithWords:(NSArray *)words caseInsensitive:(BOOL)caseInsensitive
{
    self = [super init];
    if (self) {
        _caseInsensitive = caseInsensitive;
        _words = words;
    }
    return self;
}

- (NSArray*)mostFrequentWords:(NSUInteger)count
{
    // user might ask for more words than available
    NSUInteger sortedWordsCount = self.sortedWords.count;
    count = MIN(count, sortedWordsCount);
    
    NSRange range = NSMakeRange(0, count);
    return [self.sortedWords subarrayWithRange:range];
}

#pragma mark - analyze
- (void)analyze
{
    WordToFrequency* wordToFrequency = [self countWordsFrequency:self.words caseInsensitive:self.caseInsensitive];
    FrequencyToWords* frequencyToWords = [self groupWordsByFrequency:wordToFrequency];
    _sortedWords = [self sortWordsByFrequency:frequencyToWords];
}

- (WordToFrequency*)countWordsFrequency:(NSArray *)words caseInsensitive:(BOOL)caseInsensitive {
    WordToFrequency* wordSeenFrequency = [[WordToFrequency alloc] initWithCapacity:words.count];
    [words enumerateObjectsUsingBlock:^(NSString* word, NSUInteger idx, BOOL *stop) {
        if (word.length) {
            if (caseInsensitive) {
                word = [self desensitizeString:word];
            }
            [wordSeenFrequency increaseWordFrequency:word by:1];
        }
    }];
    return wordSeenFrequency;
}

- (FrequencyToWords*)groupWordsByFrequency:(WordToFrequency*)wordToFrequency
{
    NSUInteger maximumFrequency = wordToFrequency.maximumWordFrequency;
    
    // fill the buckets
    FrequencyToWords* frequencyToWords = [[FrequencyToWords alloc] initWithMaximumFrequency:maximumFrequency];
    [wordToFrequency enumerateWordsAndFrequencyUsingBlock:^(NSString *word, NSUInteger frequency, BOOL *stop) {
        [frequencyToWords addWord:word frequency:frequency];
    }];
    return frequencyToWords;
}

- (NSArray*)sortWordsByFrequency:(FrequencyToWords*)frequencyToWords {
    NSMutableArray* mostFrequentWords = [NSMutableArray array];
    NSUInteger currentFrequency = frequencyToWords.maximumFrequency;
    
    // frequency = 0 is invalid, so stop at 1
    while (currentFrequency > 0) {
        NSArray* wordsWithFrequency = [frequencyToWords wordsWithFrequency:currentFrequency maxCount:INT_MAX];
        [mostFrequentWords addObjectsFromArray:wordsWithFrequency];
        currentFrequency--;
    }
    
    return mostFrequentWords;
}

- (NSString*)desensitizeString:(NSString*)word
{
    return [word lowercaseString];
}

@end
