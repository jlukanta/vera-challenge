//
//  SymbolDumpParser.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "SymbolDumpParser.h"
#import "SymbolDumpParser_Private.h"
#import "SymbolInfo.h"

@implementation SymbolDumpParser

// [NOTE] We are assuming symbol dump file content can fit memory (ie. the file size won't exceed, say, 1 GB)

- (void)parseSymbolDumpWithPath:(NSString*)filePath successBlock:(void (^)(NSArray* symbolsArray))successBlock failBlock:(void (^)(NSError* error))failBlock {
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        NSError* error = nil;
        NSString *fh = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            NSArray* lines = [fh componentsSeparatedByString:@"\n"];
            [self parseSymbolDumpWithLines:lines successBlock:successBlock failBlock:failBlock];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failBlock(error);
            });
        }
    });
}

// Symbol dump file format:
// The first line of the file contains the last valid address of code within the program, on a line by itself.
// Subsequent lines contain a function name, and a hexadecimal address, separated by a comma, one per line.
- (void)parseSymbolDumpWithLines:(NSArray*)lines successBlock:(void (^)(NSArray* symbolsArray))successBlock failBlock:(void (^)(NSError* error))failBlock {
    __block NSError* error = nil;
    NSMutableArray* symbolsArray = [NSMutableArray arrayWithCapacity:lines.count];
    
    __block BOOL parsedLastCodeAddress = NO;
    __block MemoryAddress lastCodeAddress = 0;
    
    __block MemoryAddress prevSymbolStartAddr = 0;
    __block NSString* prevSymbolName = nil;
    
    // We are going to add all symbols except the last one
    
    [lines enumerateObjectsUsingBlock:^(NSString* line, NSUInteger index, BOOL *stop) {
        if (line.length > 0) {
            NSString* symbolName = nil;
            MemoryAddress startAddr = 0;
            
            // First line is the last valid address of code
            if (!parsedLastCodeAddress) {
                [self parseFirstLine:line toLastCodeAddress:&lastCodeAddress error:&error];
                parsedLastCodeAddress = YES;
            }
            else {
                // Subsequent lines contain a function name, and a hexadecimal address, separated by a comma, one per line
                [self parseSymbolLine:line toSymbol:&symbolName toStartAddress:&startAddr error:&error];
            }
            
            if (error) {
                *stop = YES;
            }
            else {
                if (prevSymbolName.length) {
                    // Add previous symbol name that we found, set symbol end address as current symbol start address - 1
                    MemoryAddress prevSymbolEndAddr = startAddr - 1;
                    SymbolInfo* prevSymInfo = [[SymbolInfo alloc] initWithSymbolName:prevSymbolName
                                                                        startAddress:prevSymbolStartAddr
                                                                          endAddress:prevSymbolEndAddr];
                    [symbolsArray addObject:prevSymInfo];
                }
                prevSymbolName = symbolName;
                prevSymbolStartAddr = startAddr;
            }
        }
    }];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failBlock(error);
        });
    }
    else {
        // Add the last symbol here, set symbol end address as the last valid address of code
        if (parsedLastCodeAddress && prevSymbolName.length) {
            SymbolInfo* symInfo = [[SymbolInfo alloc] initWithSymbolName:prevSymbolName
                                                            startAddress:prevSymbolStartAddr
                                                              endAddress:lastCodeAddress];
            [symbolsArray addObject:symInfo];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(symbolsArray);
        });
    }
}

- (void)parseFirstLine:(NSString*)firstLine toLastCodeAddress:(MemoryAddress*)lastAddress error:(NSError**)error {
    BOOL result = [SymbolDumpParser convertString:firstLine toMemoryAddress:lastAddress];
    if (result) {
        *error = nil;
    }
    else {
        *error = [NSError errorWithDomain:kLookupSymbolErrorDomain code:kLastCodeAddressParseErrorCode userInfo:@{kOriginalStringToParseKey : firstLine}];
    }
}

- (void)parseSymbolLine:(NSString*)line toSymbol:(NSString* *)symbol toStartAddress:(MemoryAddress *)startAddress error:(NSError**)error {
    NSArray* components = [line componentsSeparatedByString:@","];
    if (components.count == 2) {
        NSString* symName = components[0];
        if (symName.length) {
            // remove leading and trailing whitespace
            *symbol = [symName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            BOOL result = [SymbolDumpParser convertString:components[1] toMemoryAddress:startAddress];
            if (result) {
                *error = nil;
                return;
            }
        }
    }
    *error = [NSError errorWithDomain:kLookupSymbolErrorDomain code:kSymbolLineInvalidFormatParseErrorCode userInfo:@{kOriginalStringToParseKey : line}];
}

+ (BOOL)convertString:(NSString*)string toMemoryAddress:(MemoryAddress*)memoryAddress
{
    NSScanner* scanner = [NSScanner scannerWithString:string];
    return [scanner scanHexLongLong:memoryAddress];
}
@end
