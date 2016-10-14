//
//  SymbolInfo.h
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface SymbolInfo : NSObject

@property (nonatomic, readonly) NSString* symbolName;
@property (nonatomic, readonly) MemoryAddress startAddress;
@property (nonatomic, readonly) MemoryAddress endAddress;

- (id)initWithSymbolName:(NSString*)symbolName startAddress:(MemoryAddress)startAddress endAddress:(MemoryAddress)endAddress;

@end
