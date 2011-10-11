#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)
+ (BOOL)swizzleMethod: (SEL)origSel withMethod: (SEL)altSel;
@end
