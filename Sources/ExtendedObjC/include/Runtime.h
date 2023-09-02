//
//  Runtime.h
//  _ExtendedKit
//
//  Created by Dave DeLong on 1/29/22.
//  Copyright © 2022 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

SEL sel_fromString(NSString *s);

void objc_enumerateImages(void(^iterator)(const char *imageName, BOOL *keepGoing));

void class_enumerateIvars(Class c, void(^iterator)(Ivar i, BOOL *keepGoing));
void class_enumerateClassMethods(Class c, void(^iterator)(Method m, BOOL *keepGoing));
void class_enumerateInstanceMethods(Class c, void(^iterator)(Method m, BOOL *keepGoing));

BOOL class_instancesRespondToSelector(Class c, SEL s);
BOOL class_classRespondsToSelector(Class c, SEL s);
BOOL class_instanceMethodMatchesTypeEncoding(Class c, SEL s, const char *encoding);
BOOL class_classMethodMatchesTypeEncoding(Class c, SEL s, const char *encoding);
BOOL method_matchesTypeEncoding(Method m, const char *encoding);

_Nullable IMP class_getInstanceMethodIMP(Class c, SEL s);
_Nullable IMP class_getClassMethodIMP(Class c, SEL s);

void object_enumerateIvars(id obj, void(^iterator)(Ivar i, BOOL *keepGoing));

void typeEncoding_enumerateTypes(const char *encoding, void(^iterator)(const char *type, size_t size, BOOL *keepGoing));

/// Enumerate the potentially-swizzled methods of a class
///
/// This method does not *definitively* identifiy swizzled methods. It works by locating method implementations that come from a loaded binary that is different from
/// the binary that declares the class. That could indicate a swizzled method, or it could indicate a method that was *added* to the class via an extension from another image.
///
/// - Parameter c: The `Class` whose methods will be inspected
/// - Parameter iterator: A block that is invoked when a potentially-swizzled method is located. The block is provided with 4 parameters:
///     - Parameter isClassMethod: Indicates whether the method is a class method or an instance method on the class
///     - Parameter m: the Method that has potentially been swizzled
///     - Parameter image: the path of the image where the method's implementation exists. This value may be `NULL` if the source image cannot be determined, such as with dynamically-created method implementations
///     - Parameter keepGoing: a Bool pointer that can be used to halt enumeration
/// - Returns: the count of potentially-swizzled methods that were located before enumeration was halted, or `NSNotFound` if an internal error occurred.
unsigned int class_enumerateSwizzledMethods(Class c, void(^iterator)(BOOL isClassMethod, Method m, const char * _Nullable image, BOOL *keepGoing));

NS_ASSUME_NONNULL_END
