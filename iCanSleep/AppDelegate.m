
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



#import "AppDelegate.h"

/* TODO
 
 activity no-sleep: folder browser
 activity no-sleep: time to prevent sleep (& save it)
 
 */


static NSString* const kPreventSleep = @" Allowed to Sleep: NO";
static NSString* const kAllowSleep = @" Allowed to Sleep: YES";
static NSString* const kStatusItemTitle = @"iCanSleep";
static NSString* lastActivityTime = nil;

void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
	AppDelegate *ac = (__bridge AppDelegate*)userData;
	
	CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
	lastActivityTime = [NSString stringWithFormat:@"%02d:%02d:%02d on %04d-%02d-%02d", currentDate.hour, currentDate.minute,
						(int)currentDate.second, currentDate.year, currentDate.month, currentDate.day];
	
	size_t i;
	for (i = 0; i < numEvents; i++)
	{
		[ac updateLastEventId:eventIds[i]];
		[ac preventSleep];
		ac.label.stringValue = [NSString stringWithFormat:@"%@\n %@\n Modified: %@",
								ac.currentLabelText, [[(__bridge NSArray *)eventPaths objectAtIndex:i] description], lastActivityTime];
	}
}



@implementation AppDelegate

-(void) updateSetActivityNoSleepItemTitle
{
	if (activityNoSleepTime > 0)
	{
		_setActivityNoSleepItem.title = [NSString stringWithFormat:@"Set No-Sleep Duration on Activity (%li min)", activityNoSleepTime / 60];
	}
	else
	{
		_setActivityNoSleepItem.title = @"Set No-Sleep Duration on Activity";
	}
}

-(void) updateActivityStatusItemTitle
{
	_activityStatus.title = [NSString stringWithFormat:@"Last Activity: %@", lastActivityTime == nil ? @"none" : lastActivityTime];
	
	if (activityMonitoringEnabled == NO)
	{
		_activityStatus.title = @"Activity Monitoring: OFF";
	}
}

-(void) updateActivityFolderItemTitle
{
	_activityFolderItem.title = [NSString stringWithFormat:@"Folder: %@", [activityFolder stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""]];
}


-(void) loadSettings
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	customNoSleepTime = [defaults integerForKey:@"customNoSleepTime"];
	if (customNoSleepTime == 0)
	{
		customNoSleepTime = 5 * 60 * 60; // 5 hours
	}
	
	activityMonitoringEnabled = [defaults boolForKey:@"activityMonitoringEnabled"];
	activityNoSleepTime = [defaults integerForKey:@"activityNoSleepTime"];
	activityFolder = [defaults stringForKey:@"activityFolder"];
	if ([activityFolder length] == 0)
	{
		[self disableFolderActivityMonitoring];
	}
}

-(void) saveSettings
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:customNoSleepTime forKey:@"customNoSleepTime"];
	[defaults setBool:activityMonitoringEnabled forKey:@"activityMonitoringEnabled"];
	[defaults setInteger:activityNoSleepTime forKey:@"activityNoSleepTime"];
	[defaults setObject:activityFolder forKey:@"activityFolder"];
}

-(void) awakeFromNib
{
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setMenu:_statusMenu];
	[statusItem setTitle:kStatusItemTitle];
	[statusItem setHighlightMode:YES];

	[self loadSettings];
	[self updateSetActivityNoSleepItemTitle];
	[self updateActivityStatusItemTitle];
	[self updateActivityFolderItemTitle];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_label.stringValue = kAllowSleep;
	self.currentLabelText = _label.stringValue;
	assertionID = 0;
	
	[self enableFolderActivityMonitoring];
	_window.isVisible = NO;

	secondsTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(updateRemainingTime:) userInfo:nil repeats:YES];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
	[self allowSleep];
	[self saveSettings];
}

- (void) initializeEventStream
{
	if ([activityFolder length] > 0)
	{
		NSString* path = [activityFolder stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
		NSArray* pathsToWatch = [NSArray arrayWithObject:path];
		
		void* appPointer = (__bridge void*)self;
		FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
		NSTimeInterval latency = 3.0;
		
		stream = FSEventStreamCreate(NULL,
									 &fsevents_callback,
									 &context,
									 (__bridge CFArrayRef) pathsToWatch,
									 lastEventId,
									 (CFAbsoluteTime) latency,
									 kFSEventStreamCreateFlagUseCFTypes
									 );
		
		FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		FSEventStreamStart(stream);
	}
}

-(void) disableFolderActivityMonitoring
{
	lastActivityTime = nil;
	
	[self updateActivityStatusItemTitle];
	if (stream)
	{
		FSEventStreamStop(stream);
		FSEventStreamInvalidate(stream);
		FSEventStreamRelease(stream);
		stream = nil;
	}
}

- (void)updateLastEventId: (uint64_t) eventId
{
	lastEventId = eventId;
	[self updateActivityStatusItemTitle];
}

-(void) preventSleep
{
	[self preventSleepForSeconds:activityNoSleepTime];
}

-(void) preventSleepForSeconds:(NSTimeInterval)noSleepDuration
{
	if (assertionID == 0)
	{
		//  NOTE: IOPMAssertionCreateWithName limits the string to 128 characters.
		CFStringRef reasonForActivity = CFSTR("iCanSleep detected folder activity ...");
		
		IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoIdleSleep,
													   kIOPMAssertionLevelOn,
													   reasonForActivity,
													   &assertionID);
		
		if (success == kIOReturnSuccess)
		{
			_label.stringValue = kPreventSleep;
			statusItem.title = [NSString stringWithFormat:@"%@: NO", kStatusItemTitle];
		}
		else
		{
			assertionID = 0;
			_label.stringValue = @"failed to enable sleep prevention!";
			statusItem.title = [NSString stringWithFormat:@"%@: ERROR", kStatusItemTitle];
		}
		self.currentLabelText = _label.stringValue;
	}
	
	if (assertionID != 0)
	{
		NSTimer* newTimer = [NSTimer scheduledTimerWithTimeInterval:noSleepDuration
															 target:self
														   selector:@selector(endSleepPrevention:)
														   userInfo:nil
															repeats:NO];

		// only use new timer if it prevents sleep for a longer time period
		if ([newTimer.fireDate compare:preventSleepTimer.fireDate] == NSOrderedDescending || preventSleepTimer == nil)
		{
			[preventSleepTimer invalidate];
			preventSleepTimer = newTimer;
		}
		else
		{
			[newTimer invalidate];
		}
	}
}

-(void) endSleepPrevention:(NSTimer*)timer
{
	[self allowSleep];
}

-(void) allowSleep
{
	[preventSleepTimer invalidate];
	preventSleepTimer = nil;
	
	if (assertionID != 0)
	{
		IOReturn success = IOPMAssertionRelease(assertionID);
		if (success == kIOReturnSuccess)
		{
			CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
			NSString* now = [NSString stringWithFormat:@"%02d:%02d:%02d on %04d-%02d-%02d", currentDate.hour, currentDate.minute,
							 (int)currentDate.second, currentDate.year, currentDate.month, currentDate.day];

			_label.stringValue = [NSString stringWithFormat:@"%@\n Since: %@", kAllowSleep, now];
			statusItem.title = [NSString stringWithFormat:@"%@: YES", kStatusItemTitle];
		}
		else
		{
			_label.stringValue = @"failed to allow sleeping!";
			statusItem.title = [NSString stringWithFormat:@"%@: ERROR", kStatusItemTitle];
		}
		self.currentLabelText = _label.stringValue;
		
		assertionID = 0;
	}
}

-(void) updateRemainingTime:(NSTimer*)timer
{
	if (preventSleepTimer.isValid)
	{
		NSTimeInterval remaining = [preventSleepTimer.fireDate timeIntervalSinceDate:[NSDate date]];
		
		if (remaining > 0)
		{
			//NSLog(@"can't sleep for another: %.0f seconds", remaining);
			statusItem.title = [NSString stringWithFormat:@"%@: NO (%.0f min remaining)", kStatusItemTitle, remaining / 60.0];
		}
		else
		{
			// fix issue of waking up from manual sleep showing negative remaining time
			[self allowSleep];
		}
	}
}

- (IBAction)toggleAllowSleep:(id)sender
{
	[self allowSleep];
}
- (IBAction)preventSleepHalfHour:(id)sender
{
	[preventSleepTimer invalidate];
	[self preventSleepForSeconds:30 * 60];
}
- (IBAction)preventSleepOneHour:(id)sender
{
	[preventSleepTimer invalidate];
	[self preventSleepForSeconds:60 * 60];
}
- (IBAction)preventSleepTwoHours:(id)sender
{
	[preventSleepTimer invalidate];
	[self preventSleepForSeconds:120 * 60];
}
- (IBAction)preventSleepThreeHours:(id)sender
{
	[preventSleepTimer invalidate];
	[self preventSleepForSeconds:180 * 60];
}
- (IBAction)preventSleepCustomTime:(id)sender
{
	NSAlert* alert = [NSAlert alertWithMessageText:@"Enter time (in minutes) to prevent Mac from sleeping:"
									 defaultButton:@"OK"
								   alternateButton:@"Cancel"
									   otherButton:nil
						 informativeTextWithFormat:@""];
	
	NSTextField* input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 60, 24)];
	input.stringValue = [NSString stringWithFormat:@"%li", (long)customNoSleepTime / 60];
	[alert setAccessoryView:input];
	
	NSInteger button = [alert runModal];
	if (button == NSAlertDefaultReturn)
	{
		[input validateEditing];
		NSString* inputString = [input stringValue];
		NSInteger noSleepTime = [inputString integerValue];
		
		if (noSleepTime > 0)
		{
			customNoSleepTime = noSleepTime * 60;
			[self saveSettings];
			
			[self preventSleepForSeconds:customNoSleepTime];
		}
	}
}
- (IBAction) toggleWindow:(id)sender
{
	_window.isVisible = !_window.isVisible;
}
- (IBAction)helpAndAbout:(id)sender
{
	NSString* message = @"iCanSleep v1.01\niCanSleep is a free, open source status bar tool to prevent your Mac from sleeping for a while.\n\nCopyright (C) 2013 Steffen Itterheim";
	NSAlert* alert = [NSAlert alertWithMessageText:message
									 defaultButton:@"Close"
								   alternateButton:@"Help, Updates & Source Code"
									   otherButton:nil
						 informativeTextWithFormat:@""];

	if ([alert runModal] == NSAlertAlternateReturn)
	{
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.koboldtouch.com/display/ICS"]];
	}
}

-(void) enableFolderActivityMonitoring
{
	activityMonitoringEnabled = (activityNoSleepTime > 0);
	[self updateActivityStatusItemTitle];
	[self disableFolderActivityMonitoring];
	[self initializeEventStream];
}

- (IBAction)browseActivityFolder:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setDirectoryURL:[NSURL URLWithString:activityFolder]];
	
	NSInteger button = [openPanel runModal];
	
	if (button == NSAlertDefaultReturn)
	{
		activityFolder = [[openPanel.URL absoluteString] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]; // fix spaces
		activityNoSleepTime = 5 * 60; // 5 minutes
		[self saveSettings];
		[self updateActivityFolderItemTitle];
		[self enableFolderActivityMonitoring];
	}
}

- (IBAction)setActivityNoSleepTime:(id)sender
{
	NSAlert* alert = [NSAlert alertWithMessageText:@"Enter time (in minutes) to prevent Mac from sleeping after disk activity was detected (enter 0 to disable activity monitoring):"
									 defaultButton:@"OK"
								   alternateButton:@"Cancel"
									   otherButton:nil
						 informativeTextWithFormat:@""];
	
	NSTextField* input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 60, 24)];
	input.stringValue = [NSString stringWithFormat:@"%li", (long)activityNoSleepTime / 60];
	[alert setAccessoryView:input];
	
	NSInteger button = [alert runModal];
	if (button == NSAlertDefaultReturn)
	{
		[input validateEditing];
		NSString* inputString = [input stringValue];
		NSInteger noSleepTime = [inputString integerValue];

		if (noSleepTime == 0)
		{
			[self allowSleep];
		}
		
		activityNoSleepTime = noSleepTime * 60;
		[self saveSettings];
		[self updateSetActivityNoSleepItemTitle];
		[self enableFolderActivityMonitoring];
	}
}

- (IBAction)quit:(id)sender
{
	[NSApp terminate:self];
}

@end
