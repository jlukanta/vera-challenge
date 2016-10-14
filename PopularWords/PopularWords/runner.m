//
//  runner.c
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-29.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import "runner.h"
#import "FrequentWordsAnalyzer.h"


BOOL parseArgumentsFromCommandLine(int argc, const char* argv[], NSUInteger* frequentWordsCount, NSString* *text)
{
    if (argc == 3) {
        const char* countCString = argv[1];
        const char* textCString = argv[2];
        int count = atoi(countCString);
        if (count > 0){
            *frequentWordsCount = count;
            *text = [NSString stringWithCString:textCString encoding:NSUTF8StringEncoding];
            return YES;
        }
    }
    return NO;
}

NSArray* parseWordsFromText(NSString* text, NSString* delimiters) {
    if (text && delimiters) {
        NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiters];
        return [text componentsSeparatedByCharactersInSet:delimiterSet];
    }
    return @[];
}

NSArray* mostFrequentWordsInText(NSString* text, NSUInteger frequentWordsCount) {
    NSString* delimiters = @" ~!@#$%^&*()_+-=`{}[]|\\;\':\"<>?,./\n\t";
    NSArray* parsedWords = parseWordsFromText(text, delimiters);
    
    FrequentWordsAnalyzer* analyzer = [[FrequentWordsAnalyzer alloc] initWithWords:parsedWords caseInsensitive:YES];
    [analyzer analyze];
    NSArray* frequentWords = [analyzer mostFrequentWords:frequentWordsCount];
    
    return frequentWords;
}
