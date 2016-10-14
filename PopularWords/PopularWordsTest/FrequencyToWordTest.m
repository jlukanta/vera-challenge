//
//  FrequencyToWordTest.m
//  
//
//  Created by Vera Lukman on 2015-07-28.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "FrequencyToWords.h"

@interface FrequencyToWordTest : XCTestCase

@end

@implementation FrequencyToWordTest

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

- (void)testNoData {
    FrequencyToWords* frequencyToWords = [[FrequencyToWords alloc] initWithMaximumFrequency:5];
    NSArray* results;
    
    results = [frequencyToWords wordsWithFrequency:0 maxCount:10];
    XCTAssert(results.count == 0);
    results = [frequencyToWords wordsWithFrequency:2 maxCount:10];
    XCTAssert(results.count == 0);
}

- (void)testSomeData {
    FrequencyToWords* frequencyToWords = [[FrequencyToWords alloc] initWithMaximumFrequency:5];
    NSArray* frequency2Words = @[@"test", @"abc"];
    NSArray* frequency1Words = @[@"abcd"];
    NSArray* frequency0Words = @[@"notSupposedToExist"];
    NSArray* results;
    
    // add words
    [frequency2Words enumerateObjectsUsingBlock:^(NSString* word, NSUInteger idx, BOOL *stop) {
        [frequencyToWords addWord:word frequency:2];
    }];
    [frequency1Words enumerateObjectsUsingBlock:^(NSString* word, NSUInteger idx, BOOL *stop) {
        [frequencyToWords addWord:word frequency:1];
    }];
    [frequency0Words enumerateObjectsUsingBlock:^(NSString* word, NSUInteger idx, BOOL *stop) {
        [frequencyToWords addWord:word frequency:0];
    }];
    
    // test frequency = 1, more maxCount than available words
    results = [frequencyToWords wordsWithFrequency:1 maxCount:10];
    XCTAssert(results.count == 1);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:frequency1Words]);
    
    // test frequency = 2, more maxCount than available words
    results = [frequencyToWords wordsWithFrequency:2 maxCount:10];
    XCTAssert(results.count == 2);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:frequency2Words]);
    
    // test frequency = 1, less maxCount than available words
    results = [frequencyToWords wordsWithFrequency:1 maxCount:0];
    XCTAssert(results.count == 0);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:frequency1Words]);
    
    // test frequency = 2, less maxCount than available words
    results = [frequencyToWords wordsWithFrequency:2 maxCount:1];
    XCTAssert(results.count == 1);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:frequency2Words]);
    
    // test frequency = 0, should return empty array (invalid frequency)
    results = [frequencyToWords wordsWithFrequency:0 maxCount:1];
    XCTAssert(results.count == 0);

}

- (void)testAddingMoreThatMaxFrequency {
    FrequencyToWords* frequencyToWords = [[FrequencyToWords alloc] initWithMaximumFrequency:1];
    NSArray* frequency2Words = @[@"test", @"abc"];
    NSArray* results;
    
    // add words, words shouldn't get stored
    [frequency2Words enumerateObjectsUsingBlock:^(NSString* word, NSUInteger idx, BOOL *stop) {
        [frequencyToWords addWord:word frequency:2];
    }];
    
    // test frequency = 2, should return nothing
    results = [frequencyToWords wordsWithFrequency:2 maxCount:10];
    XCTAssert(results.count == 0);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:@[]]);
    
    // test frequency = 3, should return nothing
    results = [frequencyToWords wordsWithFrequency:3 maxCount:10];
    XCTAssert(results.count == 0);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:@[]]);
}

@end
