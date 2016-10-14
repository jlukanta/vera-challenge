//
//  main.m
//  LookupSymbol
//
//  Created by Vera Lukman on 2015-08-18.
//  Copyright (c) 2015 Vera Lukman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LookupJob.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // SymbolDumpParser parsing methods runs in a background thread in case the file takes a long time
        // to parse. This will be useful if we want to let users interact with the program or if we want to
        // run other operations concurrently.
        //
        // We need main thread to wait until the parser is done with its job before it quits the program.
        // NSRunLoop is perfect for this job.
        //
        // From the Apple docs:
        // You use the NSTimer class to create timer objects or, more simply, timers.
        // A timer waits until a certain time interval has elapsed and then fires, sending a specified
        // message to a target object. For example, you could create an NSTimer object that sends a message
        // to a window, telling it to update itself after a certain time interval
        //
        // Our program doesn't have any keyboard or touch events. Thus, NSTimer is required to execute
        // the job on the NSRunLoop.
        //
        // Since we use timer, the [runloop run] method won't return / terminate even if the timer has
        // finished executing. Therefore, to quit the program, we must call exit() inside [lookupJob runLookup].
        
        LookupJob* lookupJob = [[LookupJob alloc] initWithCommandLineArgc:argc argv:argv];
        NSTimer* timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:0.1
                                                    target:lookupJob
                                                  selector:@selector(runLookup)
                                                  userInfo:nil
                                                   repeats:NO];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        [runLoop run];
        return 0;
    }
}