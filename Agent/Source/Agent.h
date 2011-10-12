#import <Cocoa/Cocoa.h>
#import <ScriptingBridge/ScriptingBridge.h>

//==================================================================================================
@interface Agent : NSObject <SBApplicationDelegate>
{
}

- (void)applicationDidFinishLaunching: (NSNotification *)notification;
- (void)intrude: (NSNotification *)notification;
- (void)eventDidFail: (AppleEvent const *)event withError: (NSError *)error;

@end
//==================================================================================================