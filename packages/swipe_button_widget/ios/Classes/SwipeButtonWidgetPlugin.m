#import "SwipeButtonWidgetPlugin.h"
#if __has_include(<swipe_button_widget/swipe_button_widget-Swift.h>)
#import <swipe_button_widget/swipe_button_widget-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "swipe_button_widget-Swift.h"
#endif

@implementation SwipeButtonWidgetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSwipeButtonWidgetPlugin registerWithRegistrar:registrar];
}
@end
