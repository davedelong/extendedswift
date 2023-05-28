//
//  Header.h
//  
//
//  Created by Dave DeLong on 5/27/23.
//

#import <Foundation/Foundation.h>

CF_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint8_t, JSONType) {
    JSONTypeNull = 0,
    JSONTypeBool = 1,
    JSONTypeString = 2,
    JSONTypeInt = 3,
    JSONTypeDouble = 4,
    JSONTypeArray = 5,
    JSONTypeObject = 6,
    JSONTypeCustom = 7
};

typedef struct JSON JSON;
typedef struct JSONCustom JSONCustom;

// Create
JSON *JSONCreateNull(void);
JSON *JSONCreateBool(bool b);
JSON *JSONCreateString(const char * _Nonnull string);
JSON *JSONCreateInt(int64_t i);
JSON *JSONCreateDouble(double d);
JSON *JSONCreateArray(void);
JSON *JSONCreateObject(void);
JSON *JSONCreateCustom(void(*)(JSONCustom *));

// Destroy
void JSONDestroy(JSON *json CF_CONSUMED);

// Get Info
JSONType JSONGetType(const JSON *json);
int64_t JSONArrayCount(const JSON *json);
int64_t JSONObjectCount(const JSON *json);

// Mutate
bool JSONArrayAppend(JSON *json, JSON *value);
bool JSONObjectAppend(JSON *json, const char *key, JSON *value);

// Visit

typedef struct JSONVisitor {
    void(*visitNull)(void * _Nullable context);
    void(*visitBool)(bool boolean, void * _Nullable context);
    void(*visitString)(const char *string, void * _Nullable context);
    void(*visitInt)(int64_t integer, void * _Nullable context);
    void(*visitDouble)(double number, void * _Nullable context);
    void(*enterArray)(void * _Nullable context);
    void(*leaveArray)(void * _Nullable context);
    void(*enterObject)(void * _Nullable context);
    void(*visitKey)(const char *key, void * _Nullable context);
    void(*leaveObject)(void * _Nullable context);
} JSONVisitor;

void JSONVisit(JSON *json, JSONVisitor visitor, void * _Nullable context);

typedef struct JSONCustomObject JSONCustomObject;

typedef void (^JSONCustomArrayCallback)(JSONCustom *);
typedef void (^JSONCustomObjectCallback)(JSONCustomObject *);

void JSONCustomProvideNull(JSONCustom *);
void JSONCustomProvideBool(JSONCustom *, bool);
void JSONCustomProvideInt(JSONCustom *, int64_t);
void JSONCustomProvideDouble(JSONCustom *, double);
void JSONCustomProvideString(JSONCustom *, const char *);
void JSONCustomProvideArray(JSONCustom *, JSONCustomArrayCallback);
void JSONCustomProvideObject(JSONCustom *, JSONCustomObjectCallback);

void JSONCustomObjectProvideNull(JSONCustomObject *, const char *);
void JSONCustomObjectProvideBool(JSONCustomObject *, const char *, bool);
void JSONCustomObjectProvideInt(JSONCustomObject *, const char *, int64_t);
void JSONCustomObjectProvideDouble(JSONCustomObject *, const char *, double);
void JSONCustomObjectProvideString(JSONCustomObject *, const char *, const char *);
void JSONCustomObjectProvideArray(JSONCustomObject *, const char *, CF_NOESCAPE JSONCustomArrayCallback);
void JSONCustomObjectProvideObject(JSONCustomObject *, const char *, CF_NOESCAPE JSONCustomObjectCallback);

// CONVENIENCE TYPES

JSON *JSONCreateNSString(NSString * _Nonnull string);
JSON *JSONCreateUUID(uuid_t _Nonnull);

void JSONCustomProvideUUID(JSONCustom *, uuid_t _Nonnull);

void JSONCustomObjectProvideTimestamp(JSONCustomObject *, const char *, time_t, int64_t);
void JSONCustomObjectProvideUUID(JSONCustomObject *, const char *, uuid_t _Nonnull);

CF_ASSUME_NONNULL_END
