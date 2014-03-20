#import <UIKit/UIKit.h>

@interface SBNumberPadWithDelegate
@property NSMutableArray *buttons;

// new
- (void)scrambleButtons;
@end

@interface SBPasscodeNumberPadButton : UIControl
@property unsigned int character;
- (NSString *)stringCharacter;
@end

static NSString *settingsPath = @"/var/mobile/Library/Preferences/com.expetelek.scramblepasspreferences.plist";
static BOOL enabled, automaticallyScramble;

%hook SBNumberPadWithDelegate

- (void)_layoutGrid
{
	%orig;
	
	// if enabled, scramble the buttons
	if (enabled)
		[self scrambleButtons];
}

%new
- (void)scrambleButtons
{
	// retrieve all the valid buttons
	NSMutableArray *validButtons = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < self.buttons.count; i++)
	{
		id object = self.buttons[i];
		// number pad button?
		if ([object isMemberOfClass:[%c(SBPasscodeNumberPadButton) class]])
		{
			SBPasscodeNumberPadButton *button = (SBPasscodeNumberPadButton *)object;
			
			// guest mode compatibility
			if (button.character != 821)
				[validButtons addObject:button];
		}
	}
	
	// initialize the positions dictionary
	NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
	for (NSUInteger i = 0; i < validButtons.count; i++)
	{
		SBPasscodeNumberPadButton *button = (SBPasscodeNumberPadButton *)validButtons[i];
		positions[[button stringCharacter]] = [button stringCharacter];
	}
	
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	if (!prefs)
		prefs = [[NSMutableDictionary alloc] init];
	
	// check if we should scramble
	if (automaticallyScramble || !prefs[@"buttonPositions"])
	{
		// setup the array (0-9)
		NSMutableArray *unusedNumbers = [[NSMutableArray alloc] init];
		for (NSUInteger i = 0; i <= 9; i++)
			[unusedNumbers addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
	
		// setup the positions
		NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
		for (NSUInteger i = 0; i <= 9; i++)
		{
			// get a random index
			int index = arc4random_uniform(unusedNumbers.count);
			
			// set the number equal to the current button
			[positions setObject:unusedNumbers[index] forKey:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
			
			// remove it from the unused numbers
			[unusedNumbers removeObjectAtIndex:index];
		}
		
		// write the changes
		[prefs setObject:positions forKey:@"buttonPositions"];
		if (![prefs writeToFile:settingsPath atomically:YES])
			NSLog(@"scramblepass: failed to save button positions");
	}
	
	// store the original frames
	NSMutableDictionary *originalFrames = [[NSMutableDictionary alloc] init];
	for (NSUInteger i = 0; i < validButtons.count; i++)
	{
		SBPasscodeNumberPadButton *button = (SBPasscodeNumberPadButton *)validButtons[i];
		originalFrames[[button stringCharacter]] = [NSValue valueWithCGRect:button.frame];
	}
	
	// update the frames
	for (NSUInteger i = 0; i < validButtons.count; i++)
	{
		SBPasscodeNumberPadButton *button = (SBPasscodeNumberPadButton *)validButtons[i];
		button.frame = [originalFrames[prefs[@"buttonPositions"][[button stringCharacter]]] CGRectValue];
	}
}

%end

static void loadSettings()
{
	// kind of useless since we open the preferences everytime anyway, but whatever
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:settingsPath];
    enabled = (prefs[@"isEnabled"] == nil || [prefs[@"isEnabled"] boolValue]);
	automaticallyScramble = (prefs[@"scrambleTrigger"] == nil || [prefs[@"scrambleTrigger"] integerValue] == 0);
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	// load the settings
    loadSettings();
}

%ctor
{
    // listen for changes in settings
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.expetelek.scramblepass/settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadSettings();
}