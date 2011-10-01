#import <Cocoa/Cocoa.h>

//==================================================================================================
@interface Agent : NSObject
{
}

- (void)applicationDidFinishLaunching: (NSNotification *)notification;
- (void)intrude: (NSNotification *)notification;
- (void)eventDidFail: (AppleEvent const *)event withError: (NSError *)error;

@end
//==================================================================================================