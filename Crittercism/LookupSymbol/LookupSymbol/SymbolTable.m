//
//  SymbolTable.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "SymbolTable.h"
#import "SymbolTable_Private.h"

#import "SymbolInfo.h"

@interface SymbolTable()
@property (nonatomic) NSArray* sortedSymbolInfos;
@end

@implementation SymbolTable

- (id)initWithSortedSymbolInfos:(NSArray*)sortedSymbolInfos
{
    self = [super init];
    if (self) {
        self.sortedSymbolInfos = sortedSymbolInfos;
    }
    return self;
}

- (NSString*)symbolNameOfMemoryAddress:(MemoryAddress)address
{
    NSInteger low = 0;
    NSInteger high = self.sortedSymbolInfos.count - 1;
    while (low <= high) {
        NSInteger mid = (low + high)/2;
        SymbolInfo* symInfo = self.sortedSymbolInfos[mid];
        RelativeAddressPosition relativePos = [self compareMemoryAddress:address toSymbolAddressRange:symInfo];
        switch (relativePos) {
            case RelativeAddressPositionLess:
                high = mid - 1;
                break;
            case RelativeAddressPositionIn:
                return symInfo.symbolName;
            case RelativeAddressPositionGreater:
                low = mid + 1;
                break;
            default:
                // This shouldn't happen but just in case ...
                return nil;
        }
    }
    return nil;
}

- (RelativeAddressPosition)compareMemoryAddress:(MemoryAddress)address toSymbolAddressRange:(SymbolInfo*)symInfo
{
    if (address < symInfo.startAddress) {
        return RelativeAddressPositionLess;
    }
    else if (address > symInfo.endAddress) {
        return RelativeAddressPositionGreater;
    }
    else {
        return RelativeAddressPositionIn;
    }
}

@end
