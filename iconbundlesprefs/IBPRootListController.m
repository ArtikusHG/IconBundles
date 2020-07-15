#include <spawn.h>
#include <signal.h>
#include <Preferences/PSSpecifier.h>
#include "IBPRootListController.h"

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.artikus.iconbundlesprefs.plist"

@implementation IBPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	return _specifiers;
}

// thanks julioverne. never forget to include these, the stock methods suck
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:@PLIST_PATH_Settings] mutableCopy] ? : [NSMutableDictionary dictionary];
	[dict setObject:value forKey:[specifier propertyForKey:@"key"]];
	[dict writeToFile:@PLIST_PATH_Settings atomically:YES];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@PLIST_PATH_Settings] ? : [NSMutableDictionary dictionary];
	return dict[[specifier propertyForKey:@"key"]] ? : NO;
}

- (void)respring {
	pid_t pid;
	int status;
	const char *backboardd[] = { "killall", "backboardd", NULL };
	const char *springboard[] = { "killall", "-9", "SpringBoard", NULL };
	if (kCFCoreFoundationVersionNumber <= 793.00) posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char * const *)backboardd, NULL);
	else posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char * const *)springboard, NULL);
	waitpid(pid, &status, WEXITED);
}

@end
