#import "Swizzle.h"
#import <objc/objc-class.h>

@implementation NSObject (Swizzle)

+ (BOOL)swizzleMethod: (SEL)origSel withMethod: (SEL)altSel
{
#if OBJC_API_VERSION >= 2
    Method origMethod = class_getInstanceMethod(self, origSel);
    
    if (!origMethod)
    {
        NSLog(@"Original method %@ not found for class %@", NSStringFromSelector(origSel), [self className]);
        
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(self, altSel);
    
    if (!altMethod)
    {
        NSLog(@"Alternate method %@ not found for class %@", NSStringFromSelector(altSel), [self className]);
        
        return NO;
    }
    
    class_addMethod(self, origSel, class_getMethodImplementation(self, origSel), method_getTypeEncoding(origMethod));
    class_addMethod(self, altSel, class_getMethodImplementation(self, altSel), method_getTypeEncoding(altMethod));
    method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
    
    return YES;
#else
    Method directOriginalMethod = NULL, directAlternateMethod = NULL;
    
    void *iterator = NULL;
    struct objc_method_list *mlist = class_nextMethodList(self, &iterator);
    
    while (mlist)
    {
        int method_index = 0;
        
        for (; method_index < mlist->method_count; ++method_index)
        {
            if (mlist->method_list[method_index].method_name == origSel)
            {
                assert(!directOriginalMethod);
                directOriginalMethod = &mlist->method_list[method_index];
            }
            
            if (mlist->method_list[method_index].method_name == altSel)
            {
                assert(!directAlternateMethod);
                directAlternateMethod = &mlist->method_list[method_index];
            }
        }
        
        mlist = class_nextMethodList(self, &iterator);
    }
    
    if (!directOriginalMethod || !directAlternateMethod)
    {
        Method inheritedOriginalMethod = NULL, inheritedAlternateMethod = NULL;
        
        if (!directOriginalMethod)
        {
            inheritedOriginalMethod = class_getInstanceMethod(self, origSel);
            
            if (!inheritedOriginalMethod)
            {
                NSLog(@"Original method %@ not found for class %@", NSStringFromSelector(origSel), [self className]);
                
                return NO;
            }
        }
        
        if (!directAlternateMethod)
        {
            inheritedAlternateMethod = class_getInstanceMethod(self, altSel);
            
            if (!inheritedAlternateMethod)
            {
                NSLog(@"Alternate method %@ not found for class %@", NSStringFromSelector(altSel), [self className]);
                
                return NO;
            }
        }
        
        int hoisted_method_count = !directOriginalMethod && !directAlternateMethod ? 2 : 1;
        struct objc_method_list *hoisted_method_list = malloc(sizeof(struct objc_method_list) + (sizeof(struct objc_method) * (hoisted_method_count-1)));
        
        hoisted_method_list->method_count = hoisted_method_count;
        Method hoisted_method = hoisted_method_list->method_list;
        
        if (!directOriginalMethod)
        {
            bcopy(inheritedOriginalMethod, hoisted_method, sizeof(struct objc_method));
            directOriginalMethod = hoisted_method++;
        }
        
        if (!directAlternateMethod)
        {
            bcopy(inheritedAlternateMethod, hoisted_method, sizeof(struct objc_method));
            directAlternateMethod = hoisted_method;
        }
        
        class_addMethods(self, hoisted_method_list);
    }
    
    IMP temp = directOriginalMethod->method_imp;
    directOriginalMethod->method_imp = directAlternateMethod->method_imp;
    directAlternateMethod->method_imp = temp;
    
    return YES;
#endif
}

@end
