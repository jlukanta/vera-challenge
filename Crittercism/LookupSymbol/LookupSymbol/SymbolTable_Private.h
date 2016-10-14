//
//  SymbolTable_Private.h
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "SymbolTable.h"

typedef enum {
    RelativeAddressPositionLess = 0,
    RelativeAddressPositionIn,
    RelativeAddressPositionGreater
} RelativeAddressPosition;

@class SymbolInfo;
@interface SymbolTable ()

// RelativeAddressPositionIn        if address is in symbol address range
// RelativeAddressPositionLess      if address is in smaller memory address than the symbol
// RelativeAddressPositionGreater   if address is in greater memory address than the symbol
- (RelativeAddressPosition)compareMemoryAddress:(MemoryAddress)address toSymbolAddressRange:(SymbolInfo*)symInfo;

@end
