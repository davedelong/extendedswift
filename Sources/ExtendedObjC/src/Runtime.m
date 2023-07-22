//
//  Runtime.m
//  _ExtendedKit
//
//  Created by Dave DeLong on 1/29/22.
//  Copyright © 2022 Syzygy. All rights reserved.
//

#import "Runtime.h"

void objc_enumerateImages(void(^iterator)(const char *imageName, BOOL *keepGoing)) {
    unsigned int count = 0;
    const char **list = objc_copyImageNames(&count);
    if (list != NULL) {
        BOOL keepGoing = YES;
        for (unsigned int i = 0; i < count && keepGoing == YES; i++) {
            iterator(list[i], &keepGoing);
        }
        free(list);
    }
}

SEL sel_fromString(NSString *s) {
    return sel_getUid(s.UTF8String);
}

void class_enumerateIvars(Class c, void(^iterator)(Ivar i, BOOL *keepGoing)) {
    unsigned int count = 0;
    Ivar *list = class_copyIvarList(c, &count);
    if (list != NULL) {
        BOOL keepGoing = YES;
        for (unsigned int i = 0; i < count && keepGoing == YES; i++) {
            iterator(list[i], &keepGoing);
        }
        free(list);
    }
}

void class_enumerateClassMethods(Class c, void(^iterator)(Method m, BOOL *keepGoing)) {
    Class metaclass = object_getClass(c);
    class_enumerateInstanceMethods(metaclass, iterator);
}

void class_enumerateInstanceMethods(Class c, void(^iterator)(Method m, BOOL *keepGoing)) {
    unsigned int count = 0;
    Method *list = class_copyMethodList(c, &count);
    if (list != NULL) {
        BOOL keepGoing = YES;
        for (unsigned int i = 0; i < count && keepGoing == YES; i++) {
            iterator(list[i], &keepGoing);
        }
        free(list);
    }
}

BOOL class_instancesRespondToSelector(Class c, SEL s) {
    return class_getInstanceMethod(c, s) != nil;
}

BOOL class_instanceMethodMatchesTypeEncoding(Class c, SEL s, const char *encoding) {
    Method m = class_getInstanceMethod(c, s);
    if (m == nil) { return NO; }
    return method_matchesTypeEncoding(m, encoding);
}

BOOL class_classRespondsToSelector(Class c, SEL s) {
    Class metaclass = object_getClass(c);
    return class_instancesRespondToSelector(metaclass, s);
}

BOOL class_classMethodMatchesTypeEncoding(Class c, SEL s, const char *encoding) {
    Class metaclass = object_getClass(c);
    return class_instanceMethodMatchesTypeEncoding(metaclass, s, encoding);
}

BOOL method_matchesTypeEncoding(Method m, const char *encoding) {
    size_t typeCount = strlen(encoding);
    if (typeCount < 3) { return NO; } // all methods must have a return type and (at least) take `self` and `_cmd`
    size_t argCount = typeCount - 1; // don't count the return type
    
    char type = 0;
    method_getReturnType(m, &type, 1);
    if (type != encoding[0]) { return NO; }
    
    if (method_getNumberOfArguments(m) != argCount) { return NO; }
    
    for (int argIndex = 0; argIndex < argCount; argIndex++) {
        method_getArgumentType(m, argIndex, &type, 1);
        char expectedType = encoding[argIndex+1];
        if (type != expectedType) { return NO; }
    }
    
    return YES;
}

_Nullable IMP class_getInstanceMethodIMP(Class c, SEL s) {
    Method m = class_getInstanceMethod(c, s);
    if (m == nil) { return NULL; }
    return method_getImplementation(m);
}

_Nullable IMP class_getClassMethodIMP(Class c, SEL s) {
    Method m = class_getClassMethod(c, s);
    if (m == nil) { return NULL; }
    return method_getImplementation(m);
}

void typeEncoding_enumerateTypes(const char *encoding, void(^iterator)(const char *, BOOL *)) {
    @try {
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
        
        const char *next = encoding;
        const void *end = (void *)encoding + strlen(encoding);
        while (true) {
            // some encoding strings (those for Objective-C methods) can include numbers
            // that indicate the stack offset for where the values are located, such as:
            // "B48@0:8{CGRect={CGPoint=dd}{CGSize=dd}}16"
            // Offsets are not considered part of the type encoding string, and so
            // this code will skip over any numeric segments of the encoding string
            while ((void *)next < end && *next >= '0' && *next <= '9') { next = next + 1; }
            
            // NSGetSizeAndAlignment will skip over bitfields, such as "b1"
            // so we manually check for it:
            if (*next == 'b') {
                BOOL keepGoing = YES;
                iterator("b", &keepGoing);
                if (keepGoing == NO) { break; }
                next = next + 1;
            } else {
                const char *startOfNext = NSGetSizeAndAlignment(next, NULL, NULL);
                
                size_t length = (uintptr_t)startOfNext - (uintptr_t)next;
                if (length == 0) { break; }
                
                NSString *type = [[NSString alloc] initWithBytesNoCopy:(void *)next
                                                                length:length
                                                              encoding:NSASCIIStringEncoding
                                                          freeWhenDone:NO];
                
                BOOL keepGoing = YES;
                iterator(type.UTF8String, &keepGoing);
                
                if (keepGoing == NO) { break; }
                next = startOfNext;
            }
        }
    } @catch (NSException *exception) {
        
    }
}
