//
//  WordToFrequencyTest.m
//  
//
//  Created by Vera Lukman on 2015-07-28.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "WordToFrequency.h"

@interface WordToFrequencyTest : XCTestCase

@end

@implementation WordToFrequencyTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoWords {
    WordToFrequency* wordToFrequency = [[WordToFrequency alloc] initWithCapacity:5];
    
    // testing before adding anything
    XCTAssert(wordToFrequency.uniqueWordsCount == 0);
    XCTAssert(wordToFrequency.maximumWordFrequency == 0);
    XCTAssert([wordToFrequency wordFrequency:@"test"] == 0);
}

- (void)testEmptyString {
    WordToFrequency* wordToFrequency = [[WordToFrequency alloc] initWithCapacity:5];
    
    [wordToFrequency increaseWordFrequency:@"" by:1];
    
    // testing before adding anything
    XCTAssert(wordToFrequency.uniqueWordsCount == 0);
    XCTAssert(wordToFrequency.maximumWordFrequency == 0);
    XCTAssert([wordToFrequency wordFrequency:@"test"] == 0);
}

- (void)testAddingWords {
    WordToFrequency* wordToFrequency = [[WordToFrequency alloc] initWithCapacity:5];
    
    [wordToFrequency increaseWordFrequency:@"test" by:1];
    XCTAssert(wordToFrequency.uniqueWordsCount == 1);
    XCTAssert(wordToFrequency.maximumWordFrequency == 1);
    XCTAssert([wordToFrequency wordFrequency:@"test"] == 1);
    
    [wordToFrequency increaseWordFrequency:@"test" by:1];
    XCTAssert(wordToFrequency.uniqueWordsCount == 1);
    XCTAssert(wordToFrequency.maximumWordFrequency == 2);
    XCTAssert([wordToFrequency wordFrequency:@"test"] == 2);
    
    [wordToFrequency increaseWordFrequency:@"abc" by:1];
    XCTAssert(wordToFrequency.uniqueWordsCount == 2);
    XCTAssert(wordToFrequency.maximumWordFrequency == 2);
    XCTAssert([wordToFrequency wordFrequency:@"abc"] == 1);
    XCTAssert([wordToFrequency wordFrequency:@"test"] == 2);
    
    [wordToFrequency increaseWordFrequency:@"test" by:3];
    XCTAssert(wordToFrequency.uniqueWordsCount == 2);
    XCTAssert(wordToFrequency.maximumWordFrequency == 5);
    XCTAssert([wordToFrequency wordFrequency:@"abc"] == 1);
    XCTAssert([wordToFrequency wordFrequency:@"test"] == 5);
}


@end
