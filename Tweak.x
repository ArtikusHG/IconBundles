static NSMutableArray *IBActiveThemes;

BOOL precomposed;
BOOL masks;
BOOL fixShadow;

@interface UIImage (Private)
- (UIImage *)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed scale:(CGFloat)scale;
@end

UIImage *IBGetThemedIcon(NSString *bundleID, int format, CGFloat scale) {
  NSMutableArray *potentialFilenames = [NSMutableArray new];
  [potentialFilenames addObject:[bundleID stringByAppendingString:@"-large.png"]];
  NSString *device = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"~ipad" : @"~iphone";
  for (int i = floorf(scale) - 1; i < 3; i++) {
    NSString *scaleString = [@[@"", @"@2x", @"@3x"] objectAtIndex:i];
    [potentialFilenames addObject:[NSString stringWithFormat:@"%@%@%@.png", bundleID, device, scaleString]];
    [potentialFilenames addObject:[NSString stringWithFormat:@"%@%@%@.png", bundleID, scaleString, device]];
    [potentialFilenames addObject:[NSString stringWithFormat:@"%@%@.png", bundleID, scaleString]];
    [potentialFilenames addObject:[NSString stringWithFormat:@"%@%@.png", bundleID, device]];
  }
  [potentialFilenames addObject:[bundleID stringByAppendingString:@".png"]]; // yes, this format somehow exists

  for (NSString *theme in IBActiveThemes) {
    for (NSString *filename in potentialFilenames) {
      NSString *path = [theme stringByAppendingPathComponent:filename];
      if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIImage *icon = [UIImage imageWithContentsOfFile:path];
        UIImage *formattedIcon = [icon _applicationIconImageForFormat:format precomposed:precomposed scale:[UIScreen mainScreen].scale];
        if (!fixShadow && masks) return formattedIcon;
        else {
          UIGraphicsBeginImageContextWithOptions(formattedIcon.size, NO, [UIScreen mainScreen].scale);
          if (masks) CGContextClipToMask(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, formattedIcon.size.width, formattedIcon.size.height), formattedIcon.CGImage);
          [icon drawInRect:CGRectMake(0, 0, formattedIcon.size.width, formattedIcon.size.height)];
          icon = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();
          return icon;
        }
      }
    }
  }
  return nil;
}

%hook SBIconImageCrossfadeView
- (void)setMasksCorners:(BOOL)masksCorners {
  // Prevent icons from being rounded on launch
  %orig(NO);
}
%end

%hook UIImage

+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier roleIdentifier:(NSString *)roleIdentifier format:(int)format scale:(CGFloat)scale {
  return IBGetThemedIcon(bundleIdentifier, format, [UIScreen mainScreen].scale) ? : %orig;
}

+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale {
  return IBGetThemedIcon(bundleIdentifier, format, [UIScreen mainScreen].scale) ? : %orig;
}

%end

@interface SBIcon : NSObject
- (NSString *)applicationBundleID;
@end

@interface SBClockApplicationIconImageView : UIView
- (SBIcon *)icon;
@end

%hook SBClockApplicationIconImageView

- (UIImage *)contentsImage {
  // Quick hack for iOS 7 "live" clock icon
  if ([self respondsToSelector:@selector(icon)]) {
    SBIcon *sbIcon = [self icon];
    return IBGetThemedIcon([sbIcon applicationBundleID], 2, [UIScreen mainScreen].scale) ? : %orig;
  }
  return %orig;
}

%end

%ctor {
  NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.saurik.WinterBoard.plist"];
  NSArray *themes = [settings objectForKey:@"Themes"];
  if (!themes && themes.count == 0) return;

  IBActiveThemes = [NSMutableArray new];
  for (NSDictionary *theme in themes) {
    BOOL active = [[theme objectForKey:@"Active"] boolValue];
    NSString *name = [theme objectForKey:@"Name"];
    if (!active || !name) continue;

    NSArray *pathChecks = @[
      [NSString stringWithFormat:@"/Library/Themes/%@.theme", name],
      [NSString stringWithFormat:@"/Library/Themes/%@", name],
      [NSString stringWithFormat:@"/User/Library/SummerBoard/Themes/%@", name],
      [NSString stringWithFormat:@"/User/Library/SummerBoard/Themes/%@.theme", name]
    ];
    for (NSString *path in pathChecks) {
      NSString *iconBundlesPath = [path stringByAppendingPathComponent:@"IconBundles"];
      if ([[NSFileManager defaultManager] fileExistsAtPath:iconBundlesPath]) [IBActiveThemes addObject:iconBundlesPath];
    }
  }
  if (IBActiveThemes.count == 0) return;

  NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.artikus.iconbundlesprefs.plist"];
  precomposed = [[prefs valueForKey:@"kPrecomposed"] boolValue];
  masks = ![[prefs valueForKey:@"kUnmasked"] boolValue];
  fixShadow = [[prefs valueForKey:@"kFixShadow"] boolValue];
}
