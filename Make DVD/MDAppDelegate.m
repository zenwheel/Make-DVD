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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[[self currentFile] setStringValue:@"Drop a folder onto my icon to create an ISO."];
	[[self currentProgress] setDoubleValue:0];
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
	[self createISO:filename];
	return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	for(NSString *path in filenames) {
		[self createISO:path];
	}
}

- (void)createISO:(NSString*)path {
	if([self taskQ] == nil) {
		NSLog(@"initializing queue");
		[self setTaskQ:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
	}

	NSString *output = [path copy];
	if([output hasSuffix:@".dvdmedia"])
		output = [output substringToIndex:([output length] - 9)];
		
	dispatch_async(_taskQ, ^{
		dispatch_sync(dispatch_get_main_queue(), ^{
			[[self currentFile] setStringValue:[NSString stringWithFormat:@"Creating ISO from %@...", [path lastPathComponent]]];
			[[self currentProgress] setDoubleValue:0];
		});
				
		NSString *command = [NSString stringWithFormat:@"/bin/bash -c '/usr/bin/hdiutil makehybrid -debug -udf -udf-volume-name \"%@\" -o \"%@.iso\" \"%@\" 2>&1'", [output lastPathComponent], output, path];
		NSLog(@"Command: %@", command);
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
			[[self currentFile] setStringValue:@"Drop a folder onto my icon to create an ISO."];
			[[self currentProgress] setDoubleValue:0];
		});
	});
}
@end
