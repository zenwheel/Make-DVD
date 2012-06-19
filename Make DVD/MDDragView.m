//
//  MDDragView.m
//  Make DVD
//
//  Created by Scott Jann on 6/19/12.
//  Copyright (c) 2012 Scott Jann. All rights reserved.
//

#import "MDDragView.h"

@implementation MDDragView

@synthesize appDelegate, dirs;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
	NSPasteboard *pboard = [sender draggingPasteboard];
	
    if([[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		BOOL allDirs = YES;
		for(NSString *path in files) {
			BOOL isDir = NO;
			[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
			if(isDir == NO)
				allDirs = NO;
		}
		if(allDirs) {
			[self setDirs:files];
			return NSDragOperationCopy;
		}
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
	[self setDirs:nil];
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
	if([self dirs])
		[[self appDelegate] application:nil openFiles:[self dirs]];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
	return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
	return YES;
}

@end
