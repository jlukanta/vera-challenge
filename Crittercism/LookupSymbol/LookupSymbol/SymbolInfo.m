//
//  SymbolInfo.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "SymbolInfo.h"

@implementation SymbolInfo

- (id)initWithSymbolName:(NSString *)symName startAddress:(MemoryAddress)startAddr endAddress:(MemoryAddress)endAddr
{
    self = [super init];
    if (self) {
        _symbolName = symName;
        _startAddress = startAddr;
        _endAddress = endAddr;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<SymbolInfo: %@, start: %llu, end: %llu>", self.symbolName, self.startAddress, self.endAddress];
}
@end
