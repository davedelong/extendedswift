//
//  AppSession.h
//  
//
//  Created by Dave DeLong on 2/24/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NSUUID *_Nonnull app_session_initialize(const char *scope);

NSURL *_Nonnull app_session_log_folder(void);

void app_session_crash_metadata_add_bool(NSString * _Nonnull key, BOOL value);
void app_session_crash_metadata_add_int(NSString * _Nonnull key, NSInteger value);
void app_session_crash_metadata_add_double(NSString * _Nonnull key, double value);
void app_session_crash_metadata_add_string(NSString * _Nonnull key, NSString * _Nonnull value);

NSArray<NSURL *> *_Nonnull app_session_all_crash_files(void);


NS_ASSUME_NONNULL_END
