//
//  runner.h
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-29.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#ifndef __PopularWords__runner__
#define __PopularWords__runner__

#import <Foundation/Foundation.h>

BOOL parseArgumentsFromCommandLine(int argc, const char* argv[], NSUInteger* frequentWordsCount, NSString* *text);
NSArray* parseWordsFromText(NSString* text, NSString* delimiters);
NSArray* mostFrequentWordsInText(NSString* text, NSUInteger frequentWordsCount);


#endif /* defined(__PopularWords__runner__) */
