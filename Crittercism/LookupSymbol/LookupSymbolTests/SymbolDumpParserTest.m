//
//  SymbolDumpParserTest.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "SymbolDumpParser.h"
#import "SymbolDumpParser_Private.h"
#import "SymbolInfo.h"
#import "Constants.h"

@interface SymbolDumpParserTest : XCTestCase

@end

@implementation SymbolDumpParserTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - parseSymbolDumpWithPath:runOnBackgroundThread:successBlock:failBlock

- (void)testParseWithDumpFileInvalidPath {
    NSString* filePath = @"./symbolDumps/symbol_dump3.txt";
    
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Test parse symbol table dump asynchronously with invalid path"];
    [parser parseSymbolDumpWithPath:filePath successBlock:^(NSArray *symbolsArray) {
        XCTAssertTrue(false, @"This test should've failed");
        [expectation fulfill];
    } failBlock:^(NSError *error) {
        XCTAssertTrue(error != nil);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testParseWithDumpFileValidPath {
    NSString* filePath = @"./symbolDumps/symbol_dump.txt".stringByExpandingTildeInPath;
    
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Test parse symbol table dump asynchronously with valid path"];
    [parser parseSymbolDumpWithPath:filePath successBlock:^(NSArray *symbolsArray) {
        // test passes
        XCTAssertTrue(symbolsArray.count > 0);
        [expectation fulfill];
    } failBlock:^(NSError *error) {
        XCTAssertEqualObjects(error, nil);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

#pragma mark - parseSymbolDumpWithLines:lines:completionBlock

- (void)testParseWithEmptyLines {
    NSArray* lines = @[@"", @"", @"", @""];
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    [parser parseSymbolDumpWithLines:lines successBlock:^(NSArray *symbolsArray) {
        XCTAssertEqual(symbolsArray.count, 0);
    } failBlock:^(NSError *error) {
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testParseWithLinesInvalidLastCodeAddress {
    NSArray* lines = @[@"", @"", @"invalid last memory address", @"", @"_CFDictionaryGetValue,0x000000002d3c7b30"];
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    [parser parseSymbolDumpWithLines:lines successBlock:^(NSArray *symbolsArray) {
        XCTAssertTrue(false, @"This test should've failed");
    } failBlock:^(NSError *error) {
        XCTAssertTrue(error != nil);
        XCTAssertEqual(error.domain, kLookupSymbolErrorDomain);
        XCTAssertEqual(error.code, kLastCodeAddressParseErrorCode);
    }];
}

- (void)testParseWithLinesInvalidSymbol {
    NSArray* lines = @[@"", @"", @"0x000000002d3ec7a0", @"", @",0x000000002d3c7b30"];
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    [parser parseSymbolDumpWithLines:lines successBlock:^(NSArray *symbolsArray) {
        XCTAssertTrue(false, @"This test should've failed");
    } failBlock:^(NSError *error) {
        XCTAssertEqualObjects(error, nil);
        XCTAssertEqual(error.domain, kLookupSymbolErrorDomain);
        XCTAssertEqual(error.code, kSymbolLineInvalidFormatParseErrorCode);
    }];
}

- (void)testParseWithLinesLastCodeAddressWithSpace {
    NSArray* lines = @[@"", @"", @"  0x000000002d3ec7a0", @"", @"    _CFDictionaryGetValue , 0x000000002d3c7b30"];
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    [parser parseSymbolDumpWithLines:lines successBlock:^(NSArray *symbolsArray) {
        XCTAssertEqual(symbolsArray.count, 1);
        SymbolInfo* symbolInfo = symbolsArray[0];
        XCTAssertEqualObjects(symbolInfo.symbolName, @"_CFDictionaryGetValue");
        XCTAssertEqual(symbolInfo.startAddress, 0x000000002d3c7b30);
        XCTAssertEqual(symbolInfo.endAddress, 0x000000002d3ec7a0);
    } failBlock:^(NSError *error) {
        XCTAssertEqualObjects(error, nil);
    }];
}

- (void)testParseWithLinesValidDump {
    NSArray* lines = @[@"0x000000002d3d16c0", @"", @"_CFRetain,0x000000002d3c8ab4", @"_CFPropertyListCreateFromXMLData,0x000000002d3c9038", @""];
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    [parser parseSymbolDumpWithLines:lines successBlock:^(NSArray *symbolsArray) {
        XCTAssertEqual(symbolsArray.count, 2);
        SymbolInfo* symbolInfo0 = symbolsArray[0];
        XCTAssertEqualObjects(symbolInfo0.symbolName, @"_CFRetain");
        XCTAssertEqual(symbolInfo0.startAddress, 0x000000002d3c8ab4);
        XCTAssertEqual(symbolInfo0.endAddress, 0x000000002d3c9038 - 1);
        
        SymbolInfo* symbolInfo1 = symbolsArray[1];
        XCTAssertEqualObjects(symbolInfo1.symbolName, @"_CFPropertyListCreateFromXMLData");
        XCTAssertEqual(symbolInfo1.startAddress, 0x000000002d3c9038);
        XCTAssertEqual(symbolInfo1.endAddress, 0x000000002d3d16c0);
    } failBlock:^(NSError *error) {
        XCTAssertEqualObjects(error, nil);
    }];
}

#pragma mark - parseFirstLine:lastCodeAddress

- (void)testParseInvalidLastCodeAddress {
    NSString* line = @"";
    MemoryAddress address;
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    NSError* error = nil;
    [parser parseFirstLine:line toLastCodeAddress:&address error:&error];
    XCTAssertTrue(error != nil);
    XCTAssertEqual(error.domain, kLookupSymbolErrorDomain);
    XCTAssertEqual(error.code, kLastCodeAddressParseErrorCode);
}

- (void)testParseLastCodeAddressWithSpaces {
    NSString* line = @"   0x000000002d3d16c0   ";
    MemoryAddress address;
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    NSError* error = nil;
    [parser parseFirstLine:line toLastCodeAddress:&address error:&error];
    XCTAssertEqualObjects(error, nil);
    XCTAssertEqual(address, 0x000000002d3d16c0);
}

#pragma mark - parseSymbolLine:symbol:startAddress

- (void)testParseEmptySymbolString {
    NSString* line = @"";
    NSString* symName;
    MemoryAddress address;
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    NSError* error = nil;
    [parser parseSymbolLine:line toSymbol:&symName toStartAddress:&address error:&error];
    XCTAssertTrue(error != nil);
    XCTAssertEqual(error.domain, kLookupSymbolErrorDomain);
    XCTAssertEqual(error.code, kSymbolLineInvalidFormatParseErrorCode);
}

- (void)testParseInvalidSymbolString {
    NSString* line = @"0x000000002d3d16c0";
    NSString* symName;
    MemoryAddress address;
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    NSError* error = nil;
    [parser parseSymbolLine:line toSymbol:&symName toStartAddress:&address error:&error];
    XCTAssertTrue(error != nil);
    XCTAssertEqual(error.domain, kLookupSymbolErrorDomain);
    XCTAssertEqual(error.code, kSymbolLineInvalidFormatParseErrorCode);
}

- (void)testParseValidSymbolString {
    NSString* line = @"_CFPropertyListCreateFromXMLData,0x000000002d3c9038";
    NSString* symName;
    MemoryAddress address;
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    NSError* error = nil;
    [parser parseSymbolLine:line toSymbol:&symName toStartAddress:&address error:&error];
    XCTAssertEqualObjects(error, nil);
    XCTAssertEqualObjects(symName, @"_CFPropertyListCreateFromXMLData");
    XCTAssertEqual(address, 0x000000002d3c9038);
}

- (void)testParseValidSymbolStringWithSpaces {
    NSString* line = @"     _CFPropertyListCreateFromXMLData   ,    0x000000002d3c9038    ";
    NSString* symName;
    MemoryAddress address;
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    NSError* error = nil;
    [parser parseSymbolLine:line toSymbol:&symName toStartAddress:&address error:&error];
    XCTAssertEqualObjects(error, nil);
    XCTAssertEqualObjects(symName, @"_CFPropertyListCreateFromXMLData");
    XCTAssertEqual(address, 0x000000002d3c9038);
}

- (void)testParseValidSymbolStringWithExtraAddress {
    NSString* line = @"_CFPropertyListCreateFromXMLData,0x000000002d3c9038,0x000000003c90382d";
    NSString* symName;
    MemoryAddress address;
    SymbolDumpParser* parser = [[SymbolDumpParser alloc] init];
    NSError* error = nil;
    [parser parseSymbolLine:line toSymbol:&symName toStartAddress:&address error:&error];
    XCTAssertTrue(error != nil);
    XCTAssertEqual(error.domain, kLookupSymbolErrorDomain);
    XCTAssertEqual(error.code, kSymbolLineInvalidFormatParseErrorCode);
}
@end