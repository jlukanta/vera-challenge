//
//  LookupJob.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-19.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "LookupJob.h"
#import "LookupJob_Private.h"

#import "SymbolDumpParser.h"
#import "SymbolTable.h"

@interface LookupJob()
@property (nonatomic, readonly) NSArray* commandLineArgs;
@end

@implementation LookupJob

- (id)initWithCommandLineArgc:(int)argc argv:(const char* *)argv
{
    self = [super init];
    if (self) {
        NSMutableArray* commandLineArgs = [NSMutableArray arrayWithCapacity:argc];
        for (int i = 0; i < argc; i++) {
            const char* argCStr = argv[i];
            NSString* argStr = [NSString stringWithCString:argCStr encoding:NSUTF8StringEncoding];
            [commandLineArgs addObject:argStr];
        }
        _commandLineArgs = commandLineArgs;
    }
    return self;
}

- (void)runLookup {
    NSString* symbolDumpPath;
    NSArray* addresses;
    BOOL validArguments = [self parseArgumentsFromCommandLineWithSymbolDumpPath:&symbolDumpPath memoryAddressStrings:&addresses];
    if (validArguments) {
        SymbolDumpParser* symbolDumpParser = [[SymbolDumpParser alloc] init];
        
        [symbolDumpParser parseSymbolDumpWithPath:symbolDumpPath successBlock:^(NSArray *symbolsArray) {
            SymbolTable* symbolTable = [[SymbolTable alloc] initWithSortedSymbolInfos:symbolsArray];
            [self printSymbolNamesOfMemoryAddresses:addresses withSymbolTable:symbolTable];
            
            // This method is executed in a runloop using a timer. We need to call exit here or the runloop won't terminate
            // Read main.m for further info
            exit(0);
        } failBlock:^(NSError *error) {
            NSLog(@"Program quit because of the following error: %@", error.description);
            exit(-1);
        }];
    }
    else {
        NSLog(@"Description: This program will print symbol name of memory addresses given a symbol table dump file. If a provided address is out of range, the program will print ! as symbol name\nUsage: ./lookup relative_path_to_dump_file address1 address2 ...\nExample: ./lookup symbolDumps/symbol_dump2.txt 0x2d3c8cf9 0x3c000");
        
        exit(-1);
    }
}

- (BOOL)parseArgumentsFromCommandLineWithSymbolDumpPath:(NSString* *)symbolDumpString memoryAddressStrings:(NSArray* *)memoryAddressStrings
{
    NSUInteger argCount = self.commandLineArgs.count;
    if (argCount >= 3) {
        NSString* filePath = ((NSString*)self.commandLineArgs[1]).stringByExpandingTildeInPath;
        *symbolDumpString = filePath;
        NSMutableArray* addresses = [[NSMutableArray alloc] initWithCapacity:argCount - 2];
        
        for (NSUInteger i = 2; i < argCount; i++) {
            NSString* addrString = self.commandLineArgs[i];
            [addresses addObject:addrString];
        }
        
        *memoryAddressStrings = addresses;
        return YES;
    }
    return NO;
}

#pragma mark - print methods

- (void)printSymbolNamesOfMemoryAddresses:(NSArray*)memoryAddressStrings withSymbolTable:(SymbolTable*)symbolTable
{
    [memoryAddressStrings enumerateObjectsUsingBlock:^(NSString* addressStr, NSUInteger idx, BOOL *stop) {
        MemoryAddress memoryAddr;
        BOOL result = [SymbolDumpParser convertString:addressStr toMemoryAddress:&memoryAddr];
        NSString* symbolName = nil;
        if (result) {
            symbolName = [symbolTable symbolNameOfMemoryAddress:memoryAddr];
        }
        [self printMemoryAddress:addressStr symbolName:symbolName];
    }];
}

- (void)printMemoryAddress:(NSString*)memoryAddress symbolName:(NSString*)symbolName
{
    if (!symbolName) {
        symbolName = @"!";
    }
    NSLog(@"%@ %@", memoryAddress, symbolName);
}

@end