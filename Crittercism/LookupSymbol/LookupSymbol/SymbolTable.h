//
//  SymbolTable.h
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface SymbolTable : NSObject

// Note that SymbolInfos has to be sorted in the array
// symbolInfos[i].endAddress < symbolInfos[i+1].startAddress for all i

- (id)initWithSortedSymbolInfos:(NSArray*)sortedSymbolInfos;

// returns null if specified memory address is out of range
- (NSString*)symbolNameOfMemoryAddress:(MemoryAddress)address;

@end
