#import <UIKit/UIApplication.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface ScramblePassPreferencesListController: PSListController
@end

static NSString *settingsPath = @"/var/mobile/Library/Preferences/com.expetelek.scramblepasspreferences.plist";

@implementation ScramblePassPreferencesListController

- (id)specifiers
{
	if(_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"ScramblePassPreferences" target:self] retain];
	
	return _specifiers;
}

- (void)scrambleButtons:(id)arg1
{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	
	if (!prefs)
		prefs = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *unusedNumbers = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i <= 9; i++)
		[unusedNumbers addObject:[NSString stringWithFormat:@"%d", i]];
	
	NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
	for (NSUInteger i = 0; i <= 9; i++)
	{
		int index = arc4random_uniform(unusedNumbers.count);
		[positions setObject:unusedNumbers[index] forKey:[NSString stringWithFormat:@"%d", i]];
		[unusedNumbers removeObjectAtIndex:index];
	}
	
	[prefs setObject:positions forKey:@"buttonPositions"];
	if ([prefs writeToFile:settingsPath atomically:YES])
	{
		UIAlertView *alert = [[UIAlertView alloc]
			initWithTitle:@"Scrambled"
			message:@"The order of the buttons have been rescrambled."
			delegate:nil
			cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
		[alert show];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc]
			initWithTitle:@"Failed"
			message:@"Failed to rescramble for an unknown reason."
			delegate:nil
			cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
		[alert show];
	}
}

- (void)openTwitter:(id)arg1
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/hetelek"]];   
}

- (void)openGithub:(id)arg1
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/hetelek/ScramblePass"]];   
}

@end
