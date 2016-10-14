//
//  RunnerTest.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "LookupJob.h"
#import "LookupJob_Private.h"

@interface RunnerTests : XCTestCase

@end

@implementation RunnerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - parseArgumentsFromCommandLineWithSymbolDumpPath:memoryAddressStrings:

- (void)testParseCommandLineArgumentsNoArg {
    int argc = 1;
    const char* argv[] = {"lookup"};
    LookupJob* lookupJob = [[LookupJob alloc] initWithCommandLineArgc:argc argv:argv];
    NSString* symbolDumpPath;
    NSArray* addresses;
    BOOL validArguments = [lookupJob parseArgumentsFromCommandLineWithSymbolDumpPath:&symbolDumpPath memoryAddressStrings:&addresses];
    XCTAssertFalse(validArguments);
}

- (void)testParseCommandLineArgumentsNoSymbolDumpPath {
    int argc = 2;
    const char* argv[] = {"lookup", "0x2d3c8cf9"};
    LookupJob* lookupJob = [[LookupJob alloc] initWithCommandLineArgc:argc argv:argv];
    NSString* symbolDumpPath;
    NSArray* addresses;
    BOOL validArguments = [lookupJob parseArgumentsFromCommandLineWithSymbolDumpPath:&symbolDumpPath memoryAddressStrings:&addresses];
    XCTAssertFalse(validArguments);
}

- (void)testParseCommandLineArgumentsNoAddresses {
    int argc = 2;
    const char* argv[] = {"lookup", "symbolDumps.txt"};
    LookupJob* lookupJob = [[LookupJob alloc] initWithCommandLineArgc:argc argv:argv];
    NSString* symbolDumpPath;
    NSArray* addresses;
    BOOL validArguments = [lookupJob parseArgumentsFromCommandLineWithSymbolDumpPath:&symbolDumpPath memoryAddressStrings:&addresses];
    XCTAssertFalse(validArguments);
}

- (void)testParseCommandLineArgumentsValidArguments {
    int argc = 4;
    const char* argv[] = {"lookup", "symbolDump.txt", "0x2d3c8cf9", "0x2d3c7bb8"};
    LookupJob* lookupJob = [[LookupJob alloc] initWithCommandLineArgc:argc argv:argv];
    NSString* symbolDumpPath;
    NSArray* addresses;
    BOOL validArguments = [lookupJob parseArgumentsFromCommandLineWithSymbolDumpPath:&symbolDumpPath memoryAddressStrings:&addresses];
    XCTAssertTrue(validArguments);
    XCTAssertEqualObjects(symbolDumpPath, @"symbolDump.txt");
    XCTAssertEqual(addresses.count, 2);
    XCTAssertEqualObjects(addresses[0], @"0x2d3c8cf9");
    XCTAssertEqualObjects(addresses[1], @"0x2d3c7bb8");
}

- (void)testParseCommandLineArgumentsValidArgumentsWithTilde {
    int argc = 4;
    const char* argv[] = {"lookup", "~/symbolDump.txt", "0x2d3c8cf9", "0x2d3c7bb8"};
    LookupJob* lookupJob = [[LookupJob alloc] initWithCommandLineArgc:argc argv:argv];
    NSString* symbolDumpPath;
    NSArray* addresses;
    BOOL validArguments = [lookupJob parseArgumentsFromCommandLineWithSymbolDumpPath:&symbolDumpPath memoryAddressStrings:&addresses];
    XCTAssertTrue(validArguments);
    XCTAssertEqualObjects(symbolDumpPath, @"~/symbolDump.txt".stringByExpandingTildeInPath);
    XCTAssertEqual(addresses.count, 2);
    XCTAssertEqualObjects(addresses[0], @"0x2d3c8cf9");
    XCTAssertEqualObjects(addresses[1], @"0x2d3c7bb8");
}

@end
