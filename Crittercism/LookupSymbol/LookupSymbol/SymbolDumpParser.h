//
//  SymbolDumpParser.h
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class SymbolTableParseInfo;

@interface SymbolDumpParser : NSObject

- (void)parseSymbolDumpWithPath:(NSString*)filePath successBlock:(void (^)(NSArray* symbolsArray))successBlock failBlock:(void (^)(NSError* error))failBlock;
+ (BOOL)convertString:(NSString*)string toMemoryAddress:(MemoryAddress*)memoryAddress;
@end
