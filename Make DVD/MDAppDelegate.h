//
//  MDAppDelegate.h
//  Make DVD
//
//  Created by Scott Jann on 6/17/12.
//  Copyright (c) 2012 Scott Jann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDDragView.h"

@class MDDragView;

@interface MDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *currentFile;
@property (weak) IBOutlet NSProgressIndicator *currentProgress;
@property () dispatch_queue_t taskQ;
@property (weak) IBOutlet MDDragView *dragView;

@end
