//
//  MDDragView.h
//  Make DVD
//
//  Created by Scott Jann on 6/19/12.
//  Copyright (c) 2012 Scott Jann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDAppDelegate.h"

@class MDAppDelegate;

@interface MDDragView : NSView

@property () MDAppDelegate *appDelegate;
@property () NSArray *dirs;

@end
