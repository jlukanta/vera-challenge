//
//  main.m
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-26.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "runner.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSUInteger frequentWordsCount;
        NSString* text;
        BOOL validArguments = parseArgumentsFromCommandLine(argc, argv, &frequentWordsCount, &text);
        if (validArguments) {
            NSArray* frequentWords = mostFrequentWordsInText(text, frequentWordsCount);
            NSLog(@"Top %tu most frequent words: %@", frequentWordsCount, frequentWords);
        }
        else {
             NSLog(@"Description: This program will print n most frequently occuring words in provided text, n has to be more than 0\nUsage: popularWords <n> <text>\nExample: ./PopularWords 1 \"test tEst TEST Text\"");
        }
    }
    return 0;
}

