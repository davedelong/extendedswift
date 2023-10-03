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

void object_enumerateIvars(id obj, void(^iterator)(Ivar i, BOOL *keepGoing)) {
    if (obj == NULL) { return; }
    if (object_isClass(obj)) { return; }
    
    Class currentClass = object_getClass(obj);
    
    BOOL keepGoing = YES;
    while (currentClass != NULL && keepGoing == YES) {
        unsigned int ivarCount = 0;
        Ivar *list = class_copyIvarList(currentClass, &ivarCount);
        if (list != NULL) {
            for (unsigned int i = 0; i < ivarCount && keepGoing; i++) {
                iterator(list[i], &keepGoing);
            }
            free(list);
        }
        currentClass = class_getSuperclass(currentClass);
    }
}

void typeEncoding_enumerateTypes(const char *encoding, void(^iterator)(const char *, size_t, BOOL *)) {
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
                // move to the character after the b
                const char *startOfSize = next + 1;
                const char *startOfNext = startOfSize;
                size_t size = 0;
                
                // this finds the end of the bitfield size while also doing a simple "atoi" parse
                while ((void *)startOfNext < end && *startOfNext >= '0' && *startOfNext <= '9') {
                    size *= 10;
                    size += (*startOfNext) - '0';
                    startOfNext = startOfNext + 1;
                }
                BOOL keepGoing = YES;
                
                iterator("b", size, &keepGoing);
                if (keepGoing == NO) { break; }
                
                next = startOfNext;
            } else {
                size_t size = 0;
                const char *startOfNext = NSGetSizeAndAlignment(next, &size, NULL);
                
                size_t length = (uintptr_t)startOfNext - (uintptr_t)next;
                if (length == 0) { break; }
                
                NSString *type = [[NSString alloc] initWithBytesNoCopy:(void *)next
                                                                length:length
                                                              encoding:NSASCIIStringEncoding
                                                          freeWhenDone:NO];
                
                BOOL keepGoing = YES;
                iterator(type.UTF8String, size, &keepGoing);
                
                if (keepGoing == NO) { break; }
                next = startOfNext;
            }
        }
    } @catch (NSException *exception) {
        
    }
}

@interface _EXSwiftLoadedImage : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) uintptr_t loadAddress;

@end

@implementation _EXSwiftLoadedImage

@end
/*
unsigned int class_enumerateSwizzledMethods(Class c, void(^iterator)(BOOL isClassMethod, Method m, const char * _Nullable image, BOOL *keepGoing)) {
    NSMutableArray *images = [NSMutableArray array];
    dyld_enumerateImages(^(const char * _Nonnull name, intptr_t slide, const struct mach_header * _Nonnull mh, BOOL * _Nonnull keepGoing) {
        _EXSwiftLoadedImage *image = [[_EXSwiftLoadedImage alloc] init];
        image.name = @(name);
        image.loadAddress = (uintptr_t)mh;
        
        [images addObject:image];
    });
    
    [images sortUsingComparator:^NSComparisonResult(_EXSwiftLoadedImage *obj1, _EXSwiftLoadedImage *obj2) {
        return obj1.loadAddress > obj2.loadAddress;
    }];
    
//    [images enumerateObjectsUsingBlock:^(_EXSwiftLoadedImage *obj1, NSUInteger idx, BOOL * _Nonnull stop) {
//        printf("%lX: %s\n", obj1.loadAddress, obj1.name.UTF8String);
//    }];
    
    const char *classNameRaw = class_getName(c);
    
    const char *classImageNameRaw = class_getImageName(c);
    if (classImageNameRaw == NULL) {
        printf("Class %s is not associated with a class; perhaps it's dynamically allocated?\n", class_getName(c));
        return NSNotFound;
    }
    
//    printf("Class %s is in image %s\n", classNameRaw, classImageNameRaw);
    
    NSString *classImageName = @(classImageNameRaw);
    NSInteger index = [images indexOfObjectPassingTest:^BOOL(_EXSwiftLoadedImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isEqualTo:classImageName];
    }];
    
    if (index == NSNotFound) {
        printf("Class %s cannot be located in the list of loaded images\n", classImageNameRaw);
        return NSNotFound;
    }
    
    _EXSwiftLoadedImage *classImage = [images objectAtIndex:index];
    NSRange addressRange = NSMakeRange(classImage.loadAddress, NSUIntegerMax - classImage.loadAddress);
    
    NSInteger nextImageIndex = index + 1;
    if (nextImageIndex < images.count) {
        _EXSwiftLoadedImage *nextImage = [images objectAtIndex:nextImageIndex];
        addressRange.length = nextImage.loadAddress - classImage.loadAddress;
//        printf("Image %s is followed by image %s. Using memory range of %lX ..< %lX\n", classImageNameRaw, nextImage.name.UTF8String, classImage.loadAddress, nextImage.loadAddress);
    } else {
//        printf("Image %s is the last image. Assuming full range of memory: %lX ...\n", classImageNameRaw, classImage.loadAddress);
    }
    
    __block unsigned int swizzledCount = 0;
    __block BOOL keepGoing = YES;
    
    class_enumerateClassMethods(c, ^(Method m, BOOL *keepGoingClass) {
        uintptr_t methodLocation = (uintptr_t)method_getImplementation(m);
        
        BOOL inTargetRange = NSLocationInRange(methodLocation, addressRange);
        
        if (inTargetRange == NO) {
//            printf("+[%s %s] @ %lX: not in target range of %lX ..< %lX\n", class_getName(c), sel_getName(method_getName(m)), methodLocation, addressRange.location, addressRange.location + addressRange.length);
            
            swizzledCount += 1;
            
            // see if we can figure out which image this method is coming from
            NSInteger index = [images indexOfObjectPassingTest:^BOOL(_EXSwiftLoadedImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj.loadAddress > methodLocation;
            }];
            
            if (index == NSNotFound || index == 0) {
                iterator(YES, m, NULL, &keepGoing);
            } else {
                _EXSwiftLoadedImage *sourceImage = [images objectAtIndex:index - 1];
                iterator(YES, m, sourceImage.name.UTF8String, &keepGoing);
            }
            
            *keepGoingClass = keepGoing;
        }
    });
    
    if (keepGoing == NO) { return swizzledCount; }
    
    class_enumerateInstanceMethods(c, ^(Method m, BOOL *keepGoingInstance) {
        uintptr_t methodLocation = (uintptr_t)method_getImplementation(m);
        
        BOOL inTargetRange = NSLocationInRange(methodLocation, addressRange);
        
        if (inTargetRange == NO) {
//            printf("-[%s %s] @ %lX: not in target range of %lX ..< %lX\n", class_getName(c), sel_getName(method_getName(m)), methodLocation, addressRange.location, addressRange.location + addressRange.length);
            swizzledCount += 1;
            
            // see if we can figure out which image this method is coming from
            NSInteger index = [images indexOfObjectPassingTest:^BOOL(_EXSwiftLoadedImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj.loadAddress > methodLocation;
            }];
            
            if (index == NSNotFound || index == 0) {
                iterator(NO, m, NULL, keepGoingInstance);
            } else {
                _EXSwiftLoadedImage *sourceImage = [images objectAtIndex:index - 1];
                iterator(NO, m, sourceImage.name.UTF8String, keepGoingInstance);
            }
        }
    });
    
    return swizzledCount;
}
*/
