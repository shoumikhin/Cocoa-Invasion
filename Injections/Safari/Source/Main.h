#import <Cocoa/Cocoa.h>

//==================================================================================================
@interface Main : NSObject
{
    NSMenuItem *_autohideDownloadsMenu;
}

@property(nonatomic, readonly) NSMenuItem *autohideDownloadsMenu;

+ (Main *)sharedInstance;

@end
//==================================================================================================