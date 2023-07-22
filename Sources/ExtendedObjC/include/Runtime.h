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

void typeEncoding_enumerateTypes(const char *encoding, void(^iterator)(const char *type, BOOL *keepGoing));

NS_ASSUME_NONNULL_END
