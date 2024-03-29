//
//  AppSession.m
//  
//
//  Created by Dave DeLong on 2/24/23.
//

#import "AppSession.h"
#import "JSON.h"
#import "JSON+Serialize.h"
#import "SignalSafe.h"
#import "GregorianDate.h"
#import "GregorianDate+Format.h"
#import "NSUUID+Time.h"
#import "ExtendedObjC.h"

#import <signal.h>
#import <sys/signal.h>
#import <dlfcn.h>
#import <stdlib.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <pthread.h>
#import <objc/runtime.h>
#import <execinfo.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

// handler declarations
void app_session_set_signal_handler(int32_t signal, struct sigaction *action);

void app_session_signal_handler(int32_t signal, struct __siginfo *, void *);
void app_session_exception_handler(NSException *exception);
void app_session_write_log();

void _app_session_track_loaded_image(const struct mach_header* mh, intptr_t vmaddr_slide);
void _app_session_provide_backtrace(JSONCustom *);
void _app_session_provide_issue(JSONCustom *custom);

#define SIG_MAX SIGUSR2+1

// MARK: - Session
typedef struct AppSession {
    NSUUID *uuid;
    NSURL *logFolder;
    time_t launchTime;
    
    char *crashFilePathTemplate;
    JSON *crashLogRoot;
    JSON *metadata;
    JSON *images;
    
    NSInteger tzoffset;
    
    NSUncaughtExceptionHandler *previousExceptionHandler;
    struct sigaction previousSignalHandlers[SIG_MAX];
    
    int32_t signal;
    NSException *exception;
} AppSession;

AppSession session;

NSUUID *_Nonnull app_session_initialize(NSURL * _Nonnull logFolder) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session.uuid = [NSUUID extended_timedUUID];
        session.logFolder = logFolder;
        session.crashLogRoot = JSONCreateObject();
        session.metadata = JSONCreateObject();
        session.images = JSONCreateArray();
        
        JSONObjectAppend(session.crashLogRoot, "metadata", session.metadata);
        JSONObjectAppend(session.crashLogRoot, "issue", JSONCreateCustom(_app_session_provide_issue));
        JSONObjectAppend(session.crashLogRoot, "backtrace", JSONCreateCustom(_app_session_provide_backtrace));
        JSONObjectAppend(session.crashLogRoot, "images", session.images);
        
        [[NSFileManager defaultManager] createDirectoryAtURL:session.logFolder withIntermediateDirectories:YES attributes:nil error:nil];
        
        // Locate the crash file
        NSURL *crashFileURL = [session.logFolder URLByAppendingPathComponent:@"crash-yyyy-MM-dd-HH-mm-ss.json"];
        session.crashFilePathTemplate = strdup(crashFileURL.fileSystemRepresentation);
        
        // track initial metadata
        session.launchTime = time(NULL);
        JSONObjectAppend(session.metadata, "id", JSONCreateNSString(session.uuid.UUIDString));
        JSONObjectAppend(session.metadata, "launch", JSONCreateNSString([[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]));
        
        id app = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"?";
        JSONObjectAppend(session.metadata, "app", JSONCreateNSString([app description]));
        JSONObjectAppend(session.metadata, "tz", JSONCreateNSString([NSTimeZone defaultTimeZone].name));
        JSONObjectAppend(session.metadata, "calendar", JSONCreateNSString([NSCalendar currentCalendar].calendarIdentifier));
        JSONObjectAppend(session.metadata, "locale", JSONCreateNSString([NSLocale currentLocale].localeIdentifier));
        
        session.tzoffset = [NSTimeZone defaultTimeZone].secondsFromGMT;
        
#if TARGET_OS_IOS
        JSONObjectAppend(session.metadata, "device", JSONCreateNSString([UIDevice currentDevice].model));
        JSONObjectAppend(session.metadata, "device", JSONCreateNSString([UIDevice currentDevice].model));
        JSONObjectAppend(session.metadata, "device_name", JSONCreateNSString([UIDevice currentDevice].name));
        JSONObjectAppend(session.metadata, "os", JSONCreateNSString([UIDevice currentDevice].systemVersion));
        JSONObjectAppend(session.metadata, "os_name", JSONCreateNSString([UIDevice currentDevice].systemName));
#endif
        
        // install signal+exception handlers
        struct sigaction action;
        action.sa_sigaction = app_session_signal_handler;
        action.sa_flags = SA_SIGINFO | SA_ONSTACK;
        sigemptyset(&action.sa_mask);
        
        app_session_set_signal_handler(SIGABRT, &action);
        app_session_set_signal_handler(SIGILL, &action);
        app_session_set_signal_handler(SIGSEGV, &action);
        app_session_set_signal_handler(SIGFPE, &action);
        app_session_set_signal_handler(SIGBUS, &action);
        app_session_set_signal_handler(SIGPIPE, &action);
        app_session_set_signal_handler(SIGTRAP, &action);
        
        session.previousExceptionHandler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(&app_session_exception_handler);
        
        // track all images that get loaded. for science!
        _dyld_register_func_for_add_image(_app_session_track_loaded_image);
    });
    
    return session.uuid;
}

// MARK: - Log File Information

void app_session_crash_metadata_add_string(NSString * _Nonnull key, NSString * _Nonnull value) {
    JSONObjectAppend(session.metadata, key.UTF8String, JSONCreateNSString(value));
}

void app_session_crash_metadata_add_int(NSString * _Nonnull key, NSInteger value) {
    JSONObjectAppend(session.metadata, key.UTF8String, JSONCreateInt(value));
}

void app_session_crash_metadata_add_bool(NSString * _Nonnull key, BOOL value) {
    JSONObjectAppend(session.metadata, key.UTF8String, JSONCreateBool(value));
}

void app_session_crash_metadata_add_double(NSString * _Nonnull key, double value) {
    JSONObjectAppend(session.metadata, key.UTF8String, JSONCreateDouble(value));
}

NSArray<NSURL *> *_Nonnull app_session_all_crash_files() {
    NSArray *urls = nil;
    NSURL *folder = session.logFolder;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folder includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    if (contents == nil) {
        urls = @[];
    } else {
        NSMutableArray *filtered = [NSMutableArray array];
        for (NSURL *url in contents) {
            if ([url.lastPathComponent hasPrefix:@"crash-"] && [url.pathExtension isEqual:@"json"]) {
                [filtered addObject:url];
            }
        }
        urls = filtered;
    }
    return urls;
}

// MARK: - Signals

void app_session_set_signal_handler(int32_t sig, struct sigaction *action) {
    struct sigaction previous;
    if (sigaction(sig, action, &previous) != 0) {
        NSLog(@"Couldn't set signal %d", sig);
    } else {
        if (0 <= sig && sig < SIG_MAX) {
            session.previousSignalHandlers[sig] = previous;
        }
    }
}

void app_session_signal_handler(int32_t signal, siginfo_t *something, void *somethingElse) {
    /*
     When inside a signal handler, there are very very very few things that are safe to do.
     See `man sigaction` for the specific list.
     
     But basically:
     - you cannot take locks
     - you cannot allocate memory
     - you cannot rely on mutable global state
     - you cannot call code that is interruptible by a signal
     
     */
    session.signal = signal;
    
    app_session_write_log();
    
    if (0 <= signal && signal < SIG_MAX) {
        struct sigaction previous = session.previousSignalHandlers[signal];
        sigaction(signal, &previous, NULL);
        raise(signal);
    } else {
        exit(signal);
    }
}

// MARK: - Exceptions

void app_session_exception_handler(NSException *exception) {
    session.exception = exception;
    app_session_write_log();
    
    if (session.previousExceptionHandler != NULL) {
        session.previousExceptionHandler(exception);
    }
}

// MARK: - Images

#define ReadInt32(_x, _s) ((_s) ? ntohl(_x): (_x))
const struct uuid_command*_findUUIDCommand(const struct mach_header *mh) {
    BOOL needsSwap = (mh->magic == MH_CIGAM || mh->magic == MH_CIGAM_64);
    BOOL is64Bit = (mh->magic == MH_MAGIC_64 || mh->magic == MH_CIGAM_64);
    
    uint32_t ncmds = ReadInt32(mh->ncmds, needsSwap);
    
    struct load_command *nextCommand = (uintptr_t)mh + (is64Bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
    for (uint32_t i = 0; i < ncmds; i++) {
        uint32_t cmd = ReadInt32(nextCommand->cmd, needsSwap);
        if (cmd == LC_UUID) { return (const struct uuid_command *)nextCommand; }
        uint32_t cmdsize = ReadInt32(nextCommand->cmdsize, needsSwap);
        nextCommand = (uintptr_t)nextCommand + cmdsize;
    }
    
    return NULL;
}

void _app_session_track_loaded_image(const struct mach_header* mh, intptr_t vmaddr_slide) {
    Dl_info info;
    dladdr(mh, &info);
    
    JSON *imageObject = JSONCreateObject();
    JSONObjectAppend(imageObject, "path", JSONCreateString(info.dli_fname));
    
    const struct uuid_command *uuidCommand = _findUUIDCommand(mh);
    if (uuidCommand != NULL) {
        JSONObjectAppend(imageObject, "uuid", JSONCreateUUID((unsigned char *)uuidCommand->uuid));
    }
    
    JSONArrayAppend(session.images, imageObject);
}

// MARK: - Writing Crash File

bool _app_session_parse_backtrace(char *str, JSONCustomObject *obj) {
    size_t totalLength = strlen(str);
    char *beyondTheString = str + totalLength;
    
    // go through the string and replace all spaces with NULL
    for (int i = 0; i < totalLength; i++) {
        if (str[i] == ' ') { str[i] = 0; }
    }
    
    char *frame = str;
    
    char *library = str + strlen(frame);
    while (*library == 0) { library++; }
    
    char *address = library + strlen(library);
    while (*address == 0) { address++; }
    
    char *function = address + strlen(address);
    while (*function == 0) { function++; }
    
    char *plus = function + strlen(function);
    while (*plus == 0) { plus++; }
    
    char *offset = plus + strlen(plus);
    while (*offset == 0) { offset++; }
    
    // check to make sure we haven't overrun the buffer AND that we're exactly as long as we're expecting
    // this check would fail if the function name has a space in it, because then our guesses about where
    // the plus and offset are would be incorrect
    if (frame < beyondTheString && library < beyondTheString && address < beyondTheString && function < beyondTheString && offset < beyondTheString && (offset + strlen(offset)) == beyondTheString) {
        JSONCustomObjectProvideString(obj, "frame", frame);
        JSONCustomObjectProvideString(obj, "library", library);
        JSONCustomObjectProvideString(obj, "address", address);
        JSONCustomObjectProvideString(obj, "function", function);
        JSONCustomObjectProvideString(obj, "offset", offset);
        return true;
    } else {
        // reset the nulls back to spaces for normal logging
        for (int i = 0; i < totalLength; i++) {
            if (str[i] == 0) { str[i] = ' '; }
        }
        return false;
    }
    
}

void _app_session_provide_backtrace(JSONCustom *custom) {
    void *callstack[128];
    struct image_offset offsets[128];
    uint32_t taskID = 0;
    
    // capture the current backtrace
    size_t frames = backtrace_async(callstack, 128, &taskID);
    
    // symbolicate the backtrace as an array of strings
    char **strs = backtrace_symbols(callstack, (int)frames);
    
    // get the images and offsets of the backtrace
    backtrace_image_offsets(callstack, offsets, 128);
    
    // closures cannot capture a fixed-length array
    // so we'll re-declare the array as an arbitrary length buffer
    // and we'll capture the buffer pointer instead
    struct image_offset *offsetBuffer = offsets;
    
    JSONCustomProvideArray(custom, ^(JSONCustom * arr) {
        for (int i = 0; i < frames; i++) {
            JSONCustomProvideObject(arr, ^(JSONCustomObject * obj) {
                JSONCustomObjectProvideUUID(obj, "image", offsetBuffer[i].uuid);
                JSONCustomObjectProvideInt(obj, "image_offset", offsetBuffer[i].offset);
                if (_app_session_parse_backtrace(strs[i], obj) == false) {
                    JSONCustomObjectProvideString(obj, "symbol", strs[i]);
                }
            });
        }
        free(strs);
    });
#if DEBUG
    backtrace_symbols_fd(callstack, (int)frames, STDERR_FILENO);
#endif
}

void _app_session_provide_issue(JSONCustom *custom) {
    JSONCustomProvideObject(custom, ^(JSONCustomObject * obj) {
        
        time_t now = time(NULL);
        JSONCustomObjectProvideInt(obj, "timestamp", now);
        JSONCustomObjectProvideInt(obj, "elapsed", now - session.launchTime);
        JSONCustomObjectProvideTimestamp(obj, "date", time(NULL), (int64_t)session.tzoffset);
        
        if (session.signal > 0) {
            JSONCustomObjectProvideString(obj, "type", "signal");
            JSONCustomObjectProvideInt(obj, "signal", session.signal);
            const char *signalName = "UNKNOWN";
            switch (session.signal) {
                case SIGABRT: signalName = "SIGABRT"; break;
                case SIGILL: signalName = "SIGILL"; break;
                case SIGSEGV: signalName = "SIGSEGV"; break;
                case SIGFPE: signalName = "SIGFPE"; break;
                case SIGBUS: signalName = "SIGBUS"; break;
                case SIGPIPE: signalName = "SIGPIPE"; break;
                case SIGTRAP: signalName = "SIGTRAP"; break;
                default: break;
            }
            JSONCustomObjectProvideString(obj, "name", signalName);
        } else if (session.exception != nil) {
            JSONCustomObjectProvideString(obj, "type", "exception");
            JSONCustomObjectProvideObject(obj, "exception", ^(JSONCustomObject *inner) {
                // technically it's not strictly safe to access this information inside the exception handler
                // but so far it seems to be ok, and if it goes wrong … too bad. the process is *already crashing*.
                JSONCustomObjectProvideString(inner, "name", session.exception.name.UTF8String);
                JSONCustomObjectProvideString(inner, "reason", session.exception.reason.UTF8String);
                
                NSDictionary *userinfo = session.exception.userInfo;
                if (userinfo.count > 0) {
                    JSONCustomObjectProvideObject(inner, "userInfo", ^(JSONCustomObject * info) {
                        for (NSString *key in userinfo) {
                            const char *rawKey = key.UTF8String;
                            id obj = userinfo[key];
                            if ([obj respondsToSelector:@selector(description)]) {
                                JSONCustomObjectProvideString(info, rawKey, [obj description].UTF8String);
                            } else {
                                Class c = object_getClass(obj);
                                JSONCustomObjectProvideString(info, rawKey, class_getName(c));
                            }
                        }
                    });
                }
            });
        } else {
            JSONCustomObjectProvideString(obj, "type", "UNKNOWN");
        }
        
    });
}

void app_session_write_log() {
    if (session.crashFilePathTemplate == NULL) { return; }
    
    // modify current.crashFilePathTemplate to format the current timestamp
    char *path = session.crashFilePathTemplate;
    size_t length = strlen(path);
    size_t nameOffset = length - 5 - 19;
    char *timeStart = path + nameOffset;
    
    time_t now = time(NULL);
    GregorianDate nowDate = GregorianDateParseTimestamp(now, 0);
    
    GregorianDateFormatBuffer(nowDate, "yyyy-MM-dd-HH-mm-ss", timeStart);
    
    int fd = open(path, O_CREAT | O_TRUNC | O_WRONLY, S_IRWXU | S_IRWXG);
    
    if (fd == 0 && errno == EACCES) {
        // permission issue; try deleting the file and trying again
        unlink(path);
        fd = open(path, O_CREAT | O_TRUNC | O_WRONLY, S_IRWXU | S_IRWXG);
    }
    
    if (fd <= 0) {
        write(STDOUT_FILENO, "couldn't open file: ", 20);
        char *errstr = strerror(errno);
        write(STDOUT_FILENO, errstr, strlen(errstr));
        return;
    }
    
    JSONSerializationOptions opts;
    opts.prettyPrint = true;
    opts.includeNullByte = false;
    opts.requireSignalSafety = true;
    
    JSONSerializeToFile(session.crashLogRoot, fd, opts);
    
    close(fd);
}
