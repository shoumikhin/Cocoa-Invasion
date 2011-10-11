#import "Main.h"
#import "Swizzle.h"

//==================================================================================================
static BOOL g_hideDownloads;
//==================================================================================================
@interface NSObject (Main)
- (void)swizzledShowDownloads: (id)sender;
- (void)swizzledDownloadDidFinish: (id)sender;
- (void)swizzledDownload: (id)sender didFailWithError: (id)error;
- (void)tryHide;
@end
//==================================================================================================
@implementation NSObject (Main)
//--------------------------------------------------------------------------------------------------
- (void)swizzledShowDownloads: (id)sender
{
    if ([sender isEqual: [[Main sharedInstance] autohideDownloadsMenu]])
    {
        NSString *path = [[NSBundle bundleForClass: [Main class]] bundlePath];
        NSString *filename = [path stringByAppendingPathComponent: @"Contents/Resources/flag"];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if (NSOnState == [[[Main sharedInstance] autohideDownloadsMenu] state])
        {
            [[[Main sharedInstance] autohideDownloadsMenu] setState: NSOffState];
            [fm removeItemAtPath: filename error: nil];
        }
        else
        {
            [[[Main sharedInstance] autohideDownloadsMenu] setState: NSOnState];
            [fm createSymbolicLinkAtPath: filename withDestinationPath: path error: nil];
        }
        
        g_hideDownloads = [fm fileExistsAtPath: filename] ? YES : NO;
    }
    else
        [self swizzledShowDownloads: sender];
}
//--------------------------------------------------------------------------------------------------
- (void)swizzledDownloadDidFinish: (id)sender
{ 
    if (g_hideDownloads)
        [self tryHide];
    
    [self swizzledDownloadDidFinish: sender];
}
//--------------------------------------------------------------------------------------------------
- (void)swizzledDownload: (id)sender didFailWithError: (id)error
{ 
    if (g_hideDownloads)
        [self tryHide];
    
    [self swizzledDownload: sender didFailWithError: error];
}
//--------------------------------------------------------------------------------------------------
- (void)tryHide
{
    if (1 == [[NSClassFromString(@"DownloadMonitor") sharedDownloadMonitor] totalBusy])
    {
        [[NSClassFromString(@"DownloadWindowController") sharedDownloadWindowController] close];
    }    
}
//--------------------------------------------------------------------------------------------------
@end
//==================================================================================================
@implementation Main
@synthesize autohideDownloadsMenu = _autohideDownloadsMenu;
//--------------------------------------------------------------------------------------------------
+ (void)inject
{
    NSString *path = [[NSBundle bundleForClass: [Main class]] bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    g_hideDownloads = [fm fileExistsAtPath: [path stringByAppendingPathComponent: @"Contents/Resources/flag"]] ? YES : NO;
    
    [Main sharedInstance];
    
    NSLog(@"Injecting Safari from: %s", [path UTF8String]);
}
//--------------------------------------------------------------------------------------------------
+ (Main *)sharedInstance
{
    static Main *injection = nil;
    
    if (nil == injection)
        injection = [[Main alloc] init];
    
    return injection;
}
//--------------------------------------------------------------------------------------------------
- (id)init
{
    if (self = [super init])
    {
        _autohideDownloadsMenu = [[NSMenuItem alloc] initWithTitle: @"Auto hide downloads" action: @selector(showDownloads:) keyEquivalent: @""];
        [_autohideDownloadsMenu setState: g_hideDownloads ? NSOnState : NSOffState];
        [[NSApp windowsMenu] insertItem: _autohideDownloadsMenu atIndex: 11];
        [_autohideDownloadsMenu release];
        
        [NSClassFromString(@"AppController") swizzleMethod: @selector(showDownloads:) withMethod: @selector(swizzledShowDownloads:)];
        [NSClassFromString(@"DownloadMonitor") swizzleMethod: @selector(downloadDidFinish:) withMethod: @selector(swizzledDownloadDidFinish:)];
        [NSClassFromString(@"DownloadMonitor") swizzleMethod: @selector(download:didFailWithError:) withMethod: @selector(swizzledDownload:didFailWithError:)];
    }
    
    return self;
}
//--------------------------------------------------------------------------------------------------
@end
//==================================================================================================