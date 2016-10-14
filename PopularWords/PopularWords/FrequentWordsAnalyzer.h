//
//  PopularWordsManager.h
//  PopularWords
//
//  Created by Vera Lukman on 2015-07-26.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrequentWordsAnalyzer : NSObject

@property (nonatomic, readonly) BOOL caseInsensitive;

- (id)initWithWords:(NSArray*)words caseInsensitive:(BOOL)caseInsensitive;
- (void)analyze;
- (NSArray*)mostFrequentWords:(NSUInteger)count;

@end
