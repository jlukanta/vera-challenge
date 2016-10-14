//
//  FrequencyWordAnalyzerTest.m
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-28.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "FrequentWordsAnalyzer.h"

@interface FrequentWordsAnalyzerTest : XCTestCase

@end

@implementation FrequentWordsAnalyzerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (BOOL)testResultsInArrayIsExpected:(NSArray*)results expectedResults:(NSArray*)expectedResults
{
    NSSet* resultsSet = [NSSet setWithArray:results];
    NSSet* expectedSet = [NSSet setWithArray:expectedResults];
    return [resultsSet isSubsetOfSet:expectedSet];
}

- (void)testNilWords {
    
    // test nil word array
    
    BOOL caseInsensitive = YES;
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 0;
    NSArray* expectedFrequentWords = @[];
    FrequentWordsAnalyzer* analyzer = [[FrequentWordsAnalyzer alloc] initWithWords:nil caseInsensitive:caseInsensitive];
    [analyzer analyze];
    NSArray* frequentWords = [analyzer mostFrequentWords:frequentWordsCount];
    XCTAssert(frequentWords.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:frequentWords expectedResults:expectedFrequentWords]);
}

- (void)testEmptyWord {
    
    // test empty word array
    BOOL caseInsensitive = YES;
    NSArray* words = @[];
    NSArray* expectedFrequentWords = @[];
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 0;
    FrequentWordsAnalyzer* analyzer = [[FrequentWordsAnalyzer alloc] initWithWords:words caseInsensitive:caseInsensitive];
    [analyzer analyze];
    NSArray* frequentWords = [analyzer mostFrequentWords:frequentWordsCount];
    XCTAssert(frequentWords.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:frequentWords expectedResults:expectedFrequentWords]);
}

- (void)testUniqueWords {
    
    // test some unique words array
    BOOL caseInsensitive = YES;
    NSArray* words = @[@"a", @"bb", @"ccc", @"ddd", @"eeee"];
    NSArray* expectedFrequentWords = words;
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 5;
    FrequentWordsAnalyzer* analyzer = [[FrequentWordsAnalyzer alloc] initWithWords:words caseInsensitive:caseInsensitive];
    [analyzer analyze];
    NSArray* frequentWords = [analyzer mostFrequentWords:frequentWordsCount];
    XCTAssert(frequentWords.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:frequentWords expectedResults:expectedFrequentWords]);
}

- (void)testUniqueWordsTop5 {
    // test some unique words array, more unique words than requested words
    BOOL caseInsensitive = YES;
    NSArray* words = @[@"a", @"bb", @"ccc", @"dddd", @"eeeee", @"ffffff", @"gggggggg"];
    NSArray* expectedFrequentWords = words;
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 5;
    FrequentWordsAnalyzer* analyzer = [[FrequentWordsAnalyzer alloc] initWithWords:words caseInsensitive:caseInsensitive];
    [analyzer analyze];
    NSArray* frequentWords = [analyzer mostFrequentWords:frequentWordsCount];
    XCTAssert(frequentWords.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:frequentWords expectedResults:expectedFrequentWords]);
    
}

- (void)testRepeatedWords {
    // test some repeated words array
    BOOL caseInsensitive = YES;
    NSArray* words = @[@"ab", @"bc", @"cd", @"ab", @"ab", @"ab", @"bc"];
    NSArray* expectedFrequentWords = @[@"ab", @"bc", @"cd"];
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 3;
    FrequentWordsAnalyzer* analyzer = [[FrequentWordsAnalyzer alloc] initWithWords:words caseInsensitive:caseInsensitive];
    [analyzer analyze];
    NSArray* frequentWords = [analyzer mostFrequentWords:frequentWordsCount];
    XCTAssert(frequentWords.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:frequentWords expectedResults:expectedFrequentWords]);
    
}

- (void)testRepeatedWordsTop3 {
    // test some repeated words array, more unique words than requested words
    BOOL caseInsensitive = YES;
    NSArray* words = @[@"ab", @"bc", @"bc", @"cd", @"ab", @"ab", @"ab", @"bc", @"cd", @"cddd", @"cd", @"cd", @"cddd", @"123", @"bcde", @"", @"xayz", @"cddd"];
    NSArray* expectedFrequentWords = @[@"ab", @"bc", @"cd", @"cddd"];
    NSUInteger frequentWordsCount = 3;
    NSUInteger expectedResultWordsCount = 3;
    FrequentWordsAnalyzer* analyzer = [[FrequentWordsAnalyzer alloc] initWithWords:words caseInsensitive:caseInsensitive];
    [analyzer analyze];
    NSArray* frequentWords = [analyzer mostFrequentWords:frequentWordsCount];
    XCTAssert(frequentWords.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:frequentWords expectedResults:expectedFrequentWords]);
}

@end
