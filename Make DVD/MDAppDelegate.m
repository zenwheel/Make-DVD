//
//  MDAppDelegate.m
//  Make DVD
//
//  Created by Scott Jann on 6/17/12.
//  Copyright (c) 2012 Scott Jann. All rights reserved.
//

#import "MDAppDelegate.h"
#include <stdio.h>


@implementation MDAppDelegate

@synthesize window = _window;
@synthesize currentFile = _currentFile;
@synthesize currentProgress = _currentProgress;
@synthesize taskQ = _taskQ;
@synthesize dragView = _dragView;

- (void)initQueue {
	[[self dragView] setAppDelegate:self];
	if([self taskQ] == nil) {
		NSLog(@"initializing queue");
		[self setTaskQ:dispatch_queue_create("com.zenwheel.createQ", DISPATCH_QUEUE_SERIAL)];
	}
}

- (void)resetUI {
	[[self currentFile] setStringValue:@"Drop a folder onto my icon to create an ISO."];
	[[self currentProgress] setDoubleValue:0];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self initQueue];
	[self resetUI];
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
	[self initQueue];
	dispatch_async(_taskQ, ^{
		[self createISO:filename];
	});
	return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	[self initQueue];
	for(NSString *path in filenames) {
		dispatch_async(_taskQ, ^{
			[self createISO:path];
		});
	}
}

- (void)createISO:(NSString*)path {
	NSString *output = [path copy];
	if([output hasSuffix:@".dvdmedia"])
		output = [output substringToIndex:([output length] - 9)];
		
	dispatch_sync(dispatch_get_main_queue(), ^{
		[[self currentFile] setStringValue:[NSString stringWithFormat:@"Creating ISO from %@...", [path lastPathComponent]]];
		[[self currentProgress] setDoubleValue:0];
	});
			
	NSString *command = [NSString stringWithFormat:@"/bin/bash -c '/usr/bin/hdiutil makehybrid -debug -udf -udf-volume-name \"%@\" -o \"%@.iso\" \"%@\" 2>&1'", [output lastPathComponent], output, path];
	//NSLog(@"Command: %@", command);
	FILE *f = popen([command UTF8String], "r");
	char buf[256];
	while(fgets(buf, sizeof(buf), f)) {
		//NSLog(@"Output: %s", buf);
		if(!strncmp("DRStatusPercentCompleteKey: ", buf, 28)) {
			long double percent = strtold(buf + 28, 0);
			dispatch_sync(dispatch_get_main_queue(), ^{
				[[self currentProgress] setDoubleValue:(percent * 100.0)];
			});
		}
	}
	dispatch_sync(dispatch_get_main_queue(), ^{
		[[self currentProgress] setDoubleValue:1];
	});
	pclose(f);
	
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		[self resetUI];
	});
}
@end
