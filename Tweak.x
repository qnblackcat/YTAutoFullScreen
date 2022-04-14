#import "../YouTubeHeader/YTPlayerViewController.h"
#import "../YouTubeHeader/YTWatchController.h"
#import "../YouTubeHeader/YTSettingsSectionItem.h"

@interface YTPlayerViewController (YTAFS)
- (void)autoFullscreen;
@end

// Settings
%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *>*)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
	if (category == 1) {
		        NSUInteger defaultautoFullIndex = [sectionItems indexOfObjectPassingTest:^BOOL (YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) { 
            return item.settingItemId == 265;
		}];
		if (defaultautoFullIndex != NSNotFound) {
			YTSettingsSectionItem *autoFUll = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Auto Full Screen" titleDescription:@"Autoplay videos at full screen"];
			autoFUll.hasSwitch = YES;
			autoFUll.switchVisible = YES;
			autoFUll.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"autofull_enabled"];
			autoFUll.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"autofull_enabled"];
				return YES;
			};
            
			[sectionItems insertObject:autoFUll atIndex:defaultautoFullIndex + 1];
		}
	}
	%orig;
}
%end


%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autofull_enabled"]) {
    %orig;
    [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(autoFullscreen) userInfo:nil repeats:NO];
   } else { return %orig; }
}

%new
- (void)autoFullscreen {
    YTWatchController *watchController = [self valueForKey:@"_UIDelegate"];
    [watchController showFullScreen];
}
%end
