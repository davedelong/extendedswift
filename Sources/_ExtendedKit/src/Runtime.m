//
//  Runtime.m
//  _ExtendedKit
//
//  Created by Dave DeLong on 1/29/22.
//  Copyright © 2022 Syzygy. All rights reserved.
//

#import "Runtime.h"

SEL sel_fromString(NSString *s) {
    return sel_getUid(s.UTF8String);
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
