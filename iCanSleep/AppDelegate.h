
/* This software is distributed under MIT License:
 
==================================================================================================
Copyright (C) 2013 Steffen Itterheim
 http://www.learn-cocos2d.com
 http://www.koboldtouch.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
==================================================================================================
*/


#import <Cocoa/Cocoa.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	FSEventStreamRef stream;
	uint64_t lastEventId;
	IOPMAssertionID assertionID;
	
	NSTimer* secondsTimer;
	NSTimer* preventSleepTimer;
	NSTimeInterval remainingNoSleepTime;
	
	NSStatusItem* statusItem;
	
	// saved settings
	NSInteger customNoSleepTime;
	NSString* activityFolder;
	NSInteger activityNoSleepTime;
	BOOL activityMonitoringEnabled;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;
@property (copy) NSString* currentLabelText;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *activityStatus;
@property (weak) IBOutlet NSMenuItem *setActivityNoSleepItem;
@property (weak) IBOutlet NSMenuItem *activityFolderItem;

- (IBAction)preventSleepCustomTime:(id)sender;

- (void)updateLastEventId: (uint64_t) eventId;
-(void) preventSleep;
- (IBAction)toggleWindow:(id)sender;
- (IBAction)helpAndAbout:(id)sender;
- (IBAction)browseActivityFolder:(id)sender;
- (IBAction)setActivityNoSleepTime:(id)sender;
- (IBAction)quit:(id)sender;

@end
