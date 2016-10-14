//
//  SymbolDumpParser_Private.h
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "SymbolDumpParser.h"

@interface SymbolDumpParser ()

- (void)parseSymbolDumpWithLines:(NSArray*)lines successBlock:(void (^)(NSArray* symbolsArray))successBlock failBlock:(void (^)(NSError* error))failBlock;
- (void)parseFirstLine:(NSString*)firstLine toLastCodeAddress:(MemoryAddress*)lastAddress error:(NSError**)error;
- (void)parseSymbolLine:(NSString*)line toSymbol:(NSString* *)symbol toStartAddress:(MemoryAddress *)startAddress error:(NSError**)error;

@end
