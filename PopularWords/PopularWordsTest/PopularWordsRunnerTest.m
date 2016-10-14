//
//  PopularWordsTest.m
//  PopularWordsTest
//
//  Created by Vera Lukman on 2015-07-28.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "runner.h"

@interface PopularWordsRunnerTest : XCTestCase

@end

@implementation PopularWordsRunnerTest

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

- (BOOL)testParseWordsResults:(NSArray*)parsedResults expectedResults:(NSArray*)expectedResults {
    NSUInteger expectedWordCount = expectedResults.count;
    __block NSUInteger expectedResultsIndex = 0;
    __block BOOL testPassed = YES;
    
    [parsedResults enumerateObjectsUsingBlock:^(NSString* parsedWord, NSUInteger idx, BOOL *stop) {
        // NSString:componentsSeparatedByCharactersInSet: will return NSArray with some empty strings
        // if there are consecutive delimiters or string is preceeded or ended by delimiters
        if (parsedWord.length) {
            if (expectedResultsIndex < expectedWordCount) {
                NSString* expectedWord = expectedResults[expectedResultsIndex];
                if ([parsedWord compare:expectedWord options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    expectedResultsIndex++;
                }
                else {
                    testPassed = NO;
                    *stop = YES;
                }
            }
            else {
                testPassed = NO;
                *stop = YES;
            }
        }
    }];
    return testPassed;
}

- (void)testMostFrequentWordsNilText
{
    // test nil text
    NSString* text = nil;
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 0;
    NSArray* expectedResults = @[];
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testMostFrequentWordsEmptyText
{
    // test empty text
    NSString* text = @"";
    NSArray* expectedResults = @[];
    NSUInteger expectedResultWordsCount = 0;
    NSUInteger frequentWordsCount = 5;
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testMostFrequentWordsDelimiterText
{
    // test delimiters text
    NSString* text = @" ~!@#$%^&*()_+-=`{}[]|\\;\':\"<>?,./\n";
    NSArray* expectedResults = @[];
    NSUInteger expectedResultWordsCount = 0;
    NSUInteger frequentWordsCount = 5;
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testMostFrequentWordsUniqueWordsInText
{
    // test some unique words array
    NSString* text = @"}{|a)#(* bb \nccc)@)(*# ddd)@(*$,> \teeee)@(#*";
    NSArray* expectedResults = @[@"a", @"bb", @"ccc", @"ddd", @"eeee"];
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 5;
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testMostFrequentWordsUniqueWordsInTextTop5
{
    // test some unique words array, more unique words than requested words
    NSString* text = @"  \n a bb   ccc    dddd eeeee   ffffff   gggggggg";
    NSArray* expectedResults = @[@"a", @"bb", @"ccc", @"dddd", @"eeeee", @"ffffff", @"gggggggg"];
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 5;
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testMostFrequentWordsRepeatedWords
{
    // test some repeated words array
    NSString* text = @"   ab     bc   cd   ab ab,ab bc";
    NSArray* expectedResults = @[@"ab", @"bc", @"cd"];
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 3;
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testMostFrequentWordsRepeatedWordsTop3
{
    // test some repeated words array, more unique words than requested words
    NSString* text = @"ab,bc,bc,cd,ab,ab,ab@bc cd,cddd,cd cd cddd 123 bcde xayz cddd";
    NSArray* expectedResults = @[@"ab", @"bc", @"cd", @"cddd"];
    NSUInteger frequentWordsCount = 3;
    NSUInteger expectedResultWordsCount = 3;
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testMostFrequentWordsRealParagraph
{
    // test some real paragraph
    NSString* text = @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
    NSArray* expectedResults = @[@"the", @"ipsum", @"of", @"lorem", @"it", @"and", @"dummy"];
    NSUInteger frequentWordsCount = 5;
    NSUInteger expectedResultWordsCount = 5;
    NSArray* results = mostFrequentWordsInText(text, frequentWordsCount);
    XCTAssert(results.count == expectedResultWordsCount);
    XCTAssert([self testResultsInArrayIsExpected:results expectedResults:expectedResults]);
}

- (void)testParseNoDelimiters {
    NSString* delimiters = nil;
    NSArray* parsedWords = parseWordsFromText(nil, delimiters);
    NSArray* expectedWords = @[];
    assert([self testParseWordsResults:parsedWords expectedResults:expectedWords]);
}

- (void)testParseNoText {
    NSString* delimiters = @" ~!@#$%^&*()_+-=`{}[]|\\;\':\"<>?,./\n\t";
    NSArray* parsedWords = parseWordsFromText(nil, delimiters);
    NSArray* expectedWords = @[];
    XCTAssert([self testParseWordsResults:parsedWords expectedResults:expectedWords]);
}

- (void)testParseShortText {
    NSString* delimiters = @" ~!@#$%^&*()_+-=`{}[]|\\;\':\"<>?,./\n\t";
    NSArray* parsedWords = parseWordsFromText(@"Hello//////World", delimiters);
    NSArray* expectedWords = @[@"hello", @"world"];
    XCTAssert([self testParseWordsResults:parsedWords expectedResults:expectedWords]);
}

- (void)testParseTextWithCrazyDelimiters {
    NSString* delimiters = @" ~!@#$%^&*()_+-=`{}[]|\\;\':\"<>?,./\n\t";
    NSArray* parsedWords = parseWordsFromText(@"&*@Hello/*aKnc}]21\n\\//World@*#", delimiters);
    NSArray* expectedWords = @[@"hello", @"aKnc", @"21", @"world"];
    XCTAssert([self testParseWordsResults:parsedWords expectedResults:expectedWords]);
}

- (void)testParseDelimitersText {
    NSString* delimiters = @" ~!@#$%^&*()_+-=`{}[]|\\;\':\"<>?,./\n\t";
    NSArray* parsedWords = parseWordsFromText(delimiters, delimiters);
    NSArray* expectedWords = @[];
    XCTAssert([self testParseWordsResults:parsedWords expectedResults:expectedWords]);
}

- (void)testParseCommandLineArgumentsNoArg {
    int argc = 1;
    const char* argv[] = {"popularWords"};
    NSUInteger frequentWordsCount;
    NSString* text;
    BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
    XCTAssert(!validArguments);
}

- (void)testParseCommandLineArgumentsNoCount {
    int argc = 2;
    const char* argv[] = {"popularWords", "text"};
    NSUInteger frequentWordsCount;
    NSString* text;
    BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
    XCTAssert(!validArguments);
}

- (void)testParseCommandLineArgumentsNoText {
    int argc = 2;
    const char* argv[] = {"popularWords", "1"};
    NSUInteger frequentWordsCount;
    NSString* text;
    BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
    XCTAssert(!validArguments);
}

- (void)testParseCommandLineArgumentsInvalidCount {
    int argc = 3;
    const char* argv[] = {"popularWords", "text", "1"};
    NSUInteger frequentWordsCount;
    NSString* text;
    BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
    XCTAssert(!validArguments);
}

- (void)testParseCommandLineArgumentsValidArguments {
    int argc = 3;
    const char* argv[] = {"popularWords", "1", "text"};
    NSUInteger frequentWordsCount;
    NSString* text;
    BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
    XCTAssert(validArguments);
    XCTAssert(frequentWordsCount == 1);
    XCTAssert([text compare:@"text"] == NSOrderedSame);
}

- (void)testParseCommandLineArgumentsNegativeCount {
    int argc = 3;
    const char* argv[] = {"popularWords", "-1", "text"};
    NSUInteger frequentWordsCount;
    NSString* text;
    BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
    XCTAssert(!validArguments);
}

- (void)testParseCommandLineArgumentsZeroCount {
    int argc = 3;
    const char* argv[] = {"popularWords", "0", "text"};
    NSUInteger frequentWordsCount;
    NSString* text;
    BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
    XCTAssert(!validArguments);
}
@end
