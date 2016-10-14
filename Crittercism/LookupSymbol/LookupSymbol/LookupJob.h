//
//  LookupJob.h
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-19.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LookupJob : NSObject
- (id)initWithCommandLineArgc:(int)argc argv:(const char* *)argv;
- (void)runLookup;
@end
