#import "Agent.h"

#import <ScriptingBridge/ScriptingBridge.h>
#import <Carbon/Carbon.h>

#define INSTALLATION_DIRECTORY "/Library/Application Support/Intruder"
#define APPLICATION_NAME "IntruderAgent"
#define PLIST_NAME "com.intruder.Agent"

//==================================================================================================
@implementation Agent
//--------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching: (NSNotification *)notification
{
	if ([(NSString*)[[[NSProcessInfo processInfo] arguments] lastObject] hasPrefix:@"-psn"])
	{
		NSTask* task = [NSTask launchedTaskWithLaunchPath: @"/bin/launchctl" arguments: [NSArray arrayWithObjects: @"load", @"-F", @"-S", @"Aqua", @INSTALLATION_DIRECTORY"/"APPLICATION_NAME".app/Contents/Resources/"PLIST_NAME".plist", nil]];

		[task waitUntilExit];
		[NSApp terminate: nil];
	}
	else
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector:@selector(intrude:) name: NSWorkspaceDidLaunchApplicationNotification object: nil];
}
//--------------------------------------------------------------------------------------------------
- (void)intrude: (NSNotification *)notification
{	
	SBApplication* app = [SBApplication applicationWithProcessIdentifier: [[[notification userInfo] objectForKey: @"NSApplicationProcessIdentifier"] intValue]];
    SInt32 version;

    Gestalt(gestaltSystemVersion, &version);
	[app setDelegate:self];
    [app setSendMode: kAEWaitReply | kAENeverInteract | kAEDontRecord];
	[app sendEvent: kASAppleScriptSuite id: kGetAEUT parameters: 0];
	[app setSendMode: kAENoReply | kAENeverInteract | kAEDontRecord];
	[app sendEvent:'int-' id: (version >= 0x1060 ? 'load' : 'leop') parameters: 0];
}
//--------------------------------------------------------------------------------------------------
- (void)eventDidFail: (AppleEvent const *)event withError: (NSError *)error
{}
//--------------------------------------------------------------------------------------------------
@end
//==================================================================================================
int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (char const **)argv);
}
//==================================================================================================
