//
//  SymbolTableTest.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "SymbolTable.h"
#import "SymbolTable_Private.h"

#import "SymbolInfo.h"

@interface SymbolTableTest : XCTestCase

@end

@implementation SymbolTableTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - symbolNameOfMemoryAddress
- (void)testSymbolNameWithEmptySymbolTable {
    NSArray* symbolInfos = nil;
    MemoryAddress address = 0x000000002d3d16c0;
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:symbolInfos];
    NSString* symbolName = [symbolTable symbolNameOfMemoryAddress:address];
    XCTAssert(symbolName == nil);
}

- (void)testSymbolNameWithEmptyArraySymbolTable {
    NSArray* symbolInfos = @[];
    MemoryAddress address = 0x000000002d3d16c0;
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:symbolInfos];
    NSString* symbolName = [symbolTable symbolNameOfMemoryAddress:address];
    XCTAssertEqualObjects(symbolName, nil);
}

- (void)testSymbolNameValidRangeOneSymbol {
    SymbolInfo* symInfo = [[SymbolInfo alloc] initWithSymbolName:@"_CFRetain" startAddress:0x000000002d3c8ab4 endAddress:0x000000002d3c9038];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:@[symInfo]];
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x000000002d3c8ab4], symInfo.symbolName);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x000000002d3c9038], symInfo.symbolName);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x000000002d3c9000], symInfo.symbolName);
}

- (void)testSymbolNameInvalidRangeOneSymbol {
    SymbolInfo* symInfo = [[SymbolInfo alloc] initWithSymbolName:@"_CFRetain" startAddress:0x000000002d3c8ab4 endAddress:0x000000002d3c9038];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:@[symInfo]];
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x000000002d3c8ab4-1], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x000000002d3c0000], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x0000000000000000], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x000000002d3c9038+1], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0x000000002d3ca000], nil);
}

- (void)testSymbolNameTwoSymbols {
    NSArray* symbolInfos = @[[[SymbolInfo alloc] initWithSymbolName:@"Test1" startAddress:10 endAddress:19],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test2" startAddress:20 endAddress:27]
                             ];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:symbolInfos];
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:10], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:14], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:19], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:20], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:23], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:27], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:9], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:28], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:40], nil);
}

- (void)testSymbolNameFourSymbols {
    NSArray* symbolInfos = @[[[SymbolInfo alloc] initWithSymbolName:@"Test1" startAddress:10 endAddress:19],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test2" startAddress:20 endAddress:27],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test3" startAddress:28 endAddress:39],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test4" startAddress:40 endAddress:47]
                             ];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:symbolInfos];
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:10], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:14], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:19], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:20], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:23], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:27], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:28], @"Test3");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:34], @"Test3");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:39], @"Test3");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:40], @"Test4");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:45], @"Test4");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:47], @"Test4");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:9], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:48], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:90], nil);
}

- (void)testSymbolNameFiveSymbols {
    NSArray* symbolInfos = @[[[SymbolInfo alloc] initWithSymbolName:@"Test1" startAddress:10 endAddress:19],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test2" startAddress:20 endAddress:27],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test3" startAddress:28 endAddress:39],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test4" startAddress:40 endAddress:47],
                             [[SymbolInfo alloc] initWithSymbolName:@"Test5" startAddress:48 endAddress:60]
                             ];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:symbolInfos];
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:10], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:14], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:19], @"Test1");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:20], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:23], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:27], @"Test2");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:28], @"Test3");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:34], @"Test3");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:39], @"Test3");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:40], @"Test4");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:45], @"Test4");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:47], @"Test4");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:48], @"Test5");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:54], @"Test5");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:60], @"Test5");
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:0], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:9], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:61], nil);
    XCTAssertEqualObjects([symbolTable symbolNameOfMemoryAddress:90], nil);
}

#pragma mark - compareMemoryAddress:toSymbolAddressRange

- (void)testCompareAddressesInRange {
    SymbolInfo* symInfo = [[SymbolInfo alloc] initWithSymbolName:@"_CFRetain" startAddress:0x000000002d3c8ab4 endAddress:0x000000002d3c9038];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:@[symInfo]];
    XCTAssertTrue([symbolTable compareMemoryAddress:0x000000002d3c8ab4 toSymbolAddressRange:symInfo] == RelativeAddressPositionIn);
    XCTAssertTrue([symbolTable compareMemoryAddress:0x000000002d3c9038 toSymbolAddressRange:symInfo] == RelativeAddressPositionIn);
    XCTAssertTrue([symbolTable compareMemoryAddress:0x000000002d3c9000 toSymbolAddressRange:symInfo] == RelativeAddressPositionIn);
}

- (void)testCompareAddressesSmallerRange {
    SymbolInfo* symInfo = [[SymbolInfo alloc] initWithSymbolName:@"_CFRetain" startAddress:0x000000002d3c8ab4 endAddress:0x000000002d3c9038];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:@[symInfo]];
    XCTAssertTrue([symbolTable compareMemoryAddress:0x000000002d3c8ab4-1 toSymbolAddressRange:symInfo] == RelativeAddressPositionLess);
    XCTAssertTrue([symbolTable compareMemoryAddress:0x000000002d3c0000 toSymbolAddressRange:symInfo] == RelativeAddressPositionLess);
    XCTAssertTrue([symbolTable compareMemoryAddress:0x0000000000000000 toSymbolAddressRange:symInfo] == RelativeAddressPositionLess);
}

- (void)testCompareAddressesBiggerRange {
    SymbolInfo* symInfo = [[SymbolInfo alloc] initWithSymbolName:@"_CFRetain" startAddress:0x000000002d3c8ab4 endAddress:0x000000002d3c9038];
    SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:@[symInfo]];
    XCTAssertTrue([symbolTable compareMemoryAddress:0x000000002d3c9038+1 toSymbolAddressRange:symInfo] == RelativeAddressPositionGreater);
    XCTAssertTrue([symbolTable compareMemoryAddress:0x000000002d3ca000 toSymbolAddressRange:symInfo] == RelativeAddressPositionGreater);
}

@end
