//
//  Entitlements.h
//  
//
//  Created by Dave DeLong on 7/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NSDictionary<NSString *, id> * _Nullable EntitlementsPlistForCurrentProcess();
NSDictionary<NSString *, id> * _Nullable EntitlementsPlistForBinary(NSData * _Nonnull);

NS_ASSUME_NONNULL_END
