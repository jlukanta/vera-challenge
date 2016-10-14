//
//  LookupJob_Private.h
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-19.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "LookupJob.h"

@class SymbolTable;

@interface LookupJob ()

- (BOOL)parseArgumentsFromCommandLineWithSymbolDumpPath:(NSString* *)symbolDumpString memoryAddressStrings:(NSArray* *)memoryAddressStrings;
- (void)printSymbolNamesOfMemoryAddresses:(NSArray*)memoryAddressStrings withSymbolTable:(SymbolTable*)symbolTable;
- (void)printMemoryAddress:(NSString*)memoryAddress symbolName:(NSString*)symbolName;

@end
