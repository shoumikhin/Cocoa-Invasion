#import <objc/objc-class.h>
#import <Cocoa/Cocoa.h>

#define INJECTIONS_PATH @"/Library/Application Support/Intruder/Injections"
#define VICTIM_IDENTIFIER_SAFARI @"com.apple.Safari"
#define INJECTION_NAME_SAFARI @"Safari.bundle"

//==================================================================================================
void inject(NSBundle *bundle)
{
	@try
	{
		if (bundle)
		{
			Class principalClass = [bundle principalClass];
			
			if (principalClass && class_getClassMethod(principalClass, @selector(inject)))
				[principalClass inject];
		}
	}
	@catch (NSException *exception)
	{
		NSLog(@"Failed to inject: %@", [exception reason]);
	}
}
//==================================================================================================
OSErr intrude(AppleEvent const *event, AppleEvent *reply, long refcon)
{
	OSErr resultCode = noErr;
	
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	
	if ([identifier isEqualToString: VICTIM_IDENTIFIER_SAFARI])
		inject([NSBundle bundleWithPath: [INJECTIONS_PATH stringByAppendingPathComponent: INJECTION_NAME_SAFARI]]);
				
	return resultCode;
}
//==================================================================================================