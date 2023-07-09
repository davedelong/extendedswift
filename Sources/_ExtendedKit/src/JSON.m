//
//  JSON.c.c
//  
//
//  Created by Dave DeLong on 5/27/23.
//

#import "JSON.h"
#import "GregorianDate+Format.h"
#import "SignalSafe.h"

typedef struct _JSONArray _JSONArray;
typedef struct _JSONObject _JSONObject;
typedef struct _JSONCustom _JSONCustom;

typedef union _JSONPayload {
    void *nothing;
    bool boolean;
    int64_t integer;
    double number;
    char *string;
    _JSONArray *array;
    _JSONObject *object;
    void(*custom)(JSONCustom *);
} _JSONPayload;

typedef struct _JSON {
    JSONType _type;
    _JSONPayload _payload;
} _JSON;

struct _JSONArray {
    int64_t count;
    int64_t bufferSize;
    _JSON **buffer;
};

struct _JSONObject {
    _JSONArray *keys;
    _JSONArray *values;
};

_JSON *_JSONCreate(JSONType type) {
    _JSON *j = calloc(1, sizeof(_JSON));
    j->_type = type;
    return j;
}

void _JSONFreeArray(_JSONArray *array) {
    if (array == NULL) { return; }
    for (int64_t i = 0; i < array->bufferSize; i++) {
        _JSON *item = array->buffer[i];
        JSONDestroy((JSON *)item);
    }
    free(array);
}

void JSONDestroy(JSON *json) {
    if (json == NULL) { return; }
    _JSON *j = (_JSON *)json;
    
    if (j->_type == JSONTypeString) {
        free(j->_payload.string);
    } else if (j->_type == JSONTypeArray) {
        _JSONArray *array = j->_payload.array;
        _JSONFreeArray(array);
    } else if (j->_type == JSONTypeObject) {
        _JSONObject *obj = j->_payload.object;
        if (obj != NULL) {
            _JSONFreeArray(obj->keys);
            _JSONFreeArray(obj->values);
            free(obj);
        }
    }
    j->_payload.nothing = NULL;
    free(j);
}

JSON *JSONCreateNull(void) {
    return (JSON *)_JSONCreate(JSONTypeNull);
}

JSON *JSONCreateBool(bool b) {
    _JSON *j = _JSONCreate(JSONTypeBool);
    j->_payload.boolean = b;
    return (JSON *)j;
}

JSON *JSONCreateString(const char *string) {
    _JSON *j = _JSONCreate(JSONTypeString);
    j->_payload.string = strdup(string);
    return (JSON *)j;
}

JSON *JSONCreateInt(int64_t i) {
    _JSON *j = _JSONCreate(JSONTypeInt);
    j->_payload.integer = i;
    return (JSON *)j;
}

JSON *JSONCreateDouble(double d) {
    _JSON *j = _JSONCreate(JSONTypeDouble);
    j->_payload.number = d;
    return (JSON *)j;
}

JSON *JSONCreateArray(void) {
    _JSON *j = _JSONCreate(JSONTypeArray);
    j->_payload.array = NULL;
    return (JSON *)j;
}

JSON *JSONCreateObject(void) {
    _JSON *j = _JSONCreate(JSONTypeObject);
    j->_payload.object = NULL;
    return (JSON *)j;
}

JSON *JSONCreateCustom(void(*callback)(JSONCustom *)) {
    _JSON *j = _JSONCreate(JSONTypeCustom);
    j->_payload.custom = callback;
    return (JSON *)j;
}

JSONType JSONGetType(const JSON *json) {
    return ((_JSON *)json)->_type;
}

// MARK: - Array Functions

int64_t _JSONArrayCount(_JSONArray *array) {
    return array->count;
}

bool _JSONArrayAppend(_JSONArray *array, JSON *value) {
    if (array == NULL) { return false; }
    if (value == NULL) { return false; }
    
    int64_t currentBufferCount = _JSONArrayCount(array);
    if (currentBufferCount == array->bufferSize) {
        // not enough space; grow the buffer
        if (array->bufferSize == 0) {
            // there is no buffer; make one
            array->bufferSize = 4;
            array->buffer = calloc(array->bufferSize, sizeof(JSON *));
        } else {
            // there is a buffer; need to realloc a new one
            array->bufferSize = (array->bufferSize * 2);
            array->buffer = realloc(array->buffer, sizeof(JSON *) * array->bufferSize);
        }
    }
    array->buffer[currentBufferCount] = (_JSON *)value;
    array->count += 1;
    
    return true;
}

JSON *_JSONArrayRemoveLast(_JSONArray *array) {
    if (array == NULL) { return NULL; }
    
    int64_t count = _JSONArrayCount(array);
    if (count > 0) {
        _JSON *last = array->buffer[count-1];
        array->buffer[count-1] = NULL;
        return (JSON *)last;
    }
    return NULL;
}

int64_t JSONArrayCount(const JSON *json) {
    if (json == NULL) { return 0; }
    _JSON *j = (_JSON *)json;
    if (j->_type != JSONTypeArray) { return 0; }
    _JSONArray *array = j->_payload.array;
    return _JSONArrayCount(array);
}

bool JSONArrayAppend(JSON *json, JSON *value) {
    if (json == NULL) { return false; }
    if (value == NULL) { return false; }
    _JSON *j = (_JSON *)json;
    if (j->_type != JSONTypeArray) { return false; }
    
    _JSONArray *array = j->_payload.array;
    if (array == NULL) {
        array = calloc(1, sizeof(_JSONArray));
        array->bufferSize = 0;
        array->buffer = NULL;
        j->_payload.array = array;
    }
    
    return _JSONArrayAppend(array, value);
}

// MARK: - Object Functions

int64_t JSONObjectCount(const JSON *json) {
    if (json == NULL) { return 0; }
    _JSON *j = (_JSON *)json;
    if (j->_type != JSONTypeObject) { return 0; }
    
    _JSONObject *obj = j->_payload.object;
    return _JSONArrayCount(obj->keys);
}

bool JSONObjectAppend(JSON *json, const char *key, JSON *value) {
    if (json == NULL) { return false; }
    if (key == NULL) { return false; }
    if (value == NULL) { return false; }
    _JSON *j = (_JSON *)json;
    if (j->_type != JSONTypeObject) { return false; }
    
    _JSONObject *obj = j->_payload.object;
    if (obj == NULL) {
        obj = calloc(1, sizeof(_JSONObject));
        obj->keys = calloc(1, sizeof(_JSONArray));
        obj->values = calloc(1, sizeof(_JSONArray));
        j->_payload.object = obj;
    }
    
    JSON *jsonKey = (JSON *)JSONCreateString(key);
    if (_JSONArrayAppend(obj->keys, jsonKey) == false) { return false; }
    if (_JSONArrayAppend(obj->values, value) == false) {
        // we couldn't append the value, but we already added the key!
        // revert the key appending and destroy the key
        _JSONArrayRemoveLast(obj->keys);
        JSONDestroy(jsonKey);
        return false;
    }
    return true;
}

// MARK: - Visitor

struct _JSONCustom {
    JSONVisitor visitor;
    void *context;
    int callCount;
};

void JSONVisit(JSON *json, JSONVisitor visitor, void *context) {
    if (json == NULL) { return; }
    _JSON *j = (_JSON *)json;
    
    switch (j->_type) {
        case JSONTypeNull: {
            visitor.visitNull(context);
            break;
        }
            
        case JSONTypeBool: {
            visitor.visitBool(j->_payload.boolean, context);
            break;
        }
            
        case JSONTypeString: {
            visitor.visitString(j->_payload.string, context);
            break;
        }
            
        case JSONTypeInt: {
            visitor.visitInt(j->_payload.integer, context);
            break;
        }
            
        case JSONTypeDouble: {
            visitor.visitDouble(j->_payload.number, context);
            break;
        }
            
        case JSONTypeArray: {
            visitor.enterArray(context);
            _JSONArray *values = j->_payload.array;
            if (values != NULL) {
                int64_t count = _JSONArrayCount(values);
                for (int64_t i = 0; i < count; i++) {
                    JSONVisit((JSON *)values->buffer[i], visitor, context);
                }
            }
            visitor.leaveArray(context);
            break;
        }
            
        case JSONTypeObject: {
            visitor.enterObject(context);
            _JSONObject *object = j->_payload.object;
            if (object != NULL) {
                int64_t count = _JSONArrayCount(object->keys);
                for (int64_t i = 0; i < count; i++) {
                    _JSON *key = object->keys->buffer[i];
                    visitor.visitKey(key->_payload.string, context);
                    
                    _JSON *value = object->values->buffer[i];
                    JSONVisit((JSON *)value, visitor, context);
                }
            }
            visitor.leaveObject(context);
            break;
        }
            
        case JSONTypeCustom: {
            void(*callback)(JSONCustom *) = j->_payload.custom;
            if (callback != NULL) {
                _JSONCustom custom;
                custom.visitor = visitor;
                custom.context = context;
                custom.callCount = 0;
                
                JSONCustom *publicCustom = (JSONCustom *)&custom;
                callback(publicCustom);
                
                if (custom.callCount == 0) {
                    // there was nothing provided; assume null
                    visitor.visitNull(context);
                }
            }
            break;
        }
            
        default: {
            break;
        }
    }
}

void JSONCustomProvideNull(JSONCustom *custom) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitNull(c->context);
}

void JSONCustomProvideBool(JSONCustom *custom, bool boolean) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitBool(boolean, c->context);
}
void JSONCustomProvideInt(JSONCustom *custom, int64_t integer) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitInt(integer, c->context);
}
void JSONCustomProvideDouble(JSONCustom *custom, double number) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitDouble(number, c->context);
}
void JSONCustomProvideString(JSONCustom *custom, const char *string) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitString(string, c->context);
}
void JSONCustomProvideArray(JSONCustom *custom, JSONCustomArrayCallback array) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.enterArray(c->context);
    array(custom);
    c->visitor.leaveArray(c->context);
}
void JSONCustomProvideObject(JSONCustom *custom, JSONCustomObjectCallback object) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.enterObject(c->context);
    object((JSONCustomObject *)custom);
    c->visitor.leaveObject(c->context);
}

void JSONCustomObjectProvideNull(JSONCustomObject *custom, const char *key) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitKey(key, c->context);
    c->visitor.visitNull(c->context);
}
void JSONCustomObjectProvideBool(JSONCustomObject *custom, const char *key, bool boolean) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitKey(key, c->context);
    c->visitor.visitBool(boolean, c->context);
}
void JSONCustomObjectProvideInt(JSONCustomObject *custom, const char *key, int64_t integer) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitKey(key, c->context);
    c->visitor.visitInt(integer, c->context);
}
void JSONCustomObjectProvideDouble(JSONCustomObject *custom, const char *key, double number) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitKey(key, c->context);
    c->visitor.visitDouble(number, c->context);
}
void JSONCustomObjectProvideString(JSONCustomObject *custom, const char *key, const char *string) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitKey(key, c->context);
    c->visitor.visitString(string, c->context);
}
void JSONCustomObjectProvideArray(JSONCustomObject *custom, const char *key, JSONCustomArrayCallback array) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitKey(key, c->context);
    c->visitor.enterArray(c->context);
    array((JSONCustom *)custom);
    c->visitor.leaveArray(c->context);
}
void JSONCustomObjectProvideObject(JSONCustomObject *custom, const char *key, JSONCustomObjectCallback object) {
    _JSONCustom *c = (_JSONCustom *)custom;
    c->callCount += 1;
    c->visitor.visitKey(key, c->context);
    c->visitor.enterObject(c->context);
    object(custom);
    c->visitor.leaveObject(c->context);
}

// MARK: - CONVENIENCE TYPES

JSON *JSONCreateNSString(NSString * _Nonnull string) {
    return JSONCreateString(string.UTF8String);
}

JSON *JSONCreateUUID(uuid_t uuid) {
    __darwin_uuid_string_t uuidBuffer = {0};
    SafeFormatUUID(uuidBuffer, uuid);
    return JSONCreateString(uuidBuffer);
}

void JSONCustomProvideUUID(JSONCustom *custom, uuid_t uuid) {
    __darwin_uuid_string_t uuidBuffer = {0};
    SafeFormatUUID(uuidBuffer, uuid);
    JSONCustomProvideString(custom, uuidBuffer);
}

void JSONCustomProvideTimestamp(JSONCustom *custom, time_t timestamp, int16_t tzoffset) {
    GregorianDate date = GregorianDateParseTimestamp(timestamp, tzoffset);
    char timeString[26] = "yyyy-MM-dd HH:mm:ss +0000";
    GregorianDateFormatBuffer(date, "yyyy-MM-dd HH:mm:ss xx", timeString);
    JSONCustomProvideString(custom, timeString);
}

void JSONCustomObjectProvideUUID(JSONCustomObject *custom, const char *key, uuid_t uuid) {
    __darwin_uuid_string_t uuidBuffer = {0};
    SafeFormatUUID(uuidBuffer, uuid);
    JSONCustomObjectProvideString(custom, key, uuidBuffer);
}

void JSONCustomObjectProvideTimestamp(JSONCustomObject *custom, const char *key, time_t timestamp, int16_t tzoffset) {
    GregorianDate date = GregorianDateParseTimestamp(timestamp, tzoffset);
    char timeString[26] = "yyyy-MM-dd HH:mm:ss +0000";
    GregorianDateFormatBuffer(date, "yyyy-MM-dd HH:mm:ss xx", timeString);
    JSONCustomObjectProvideString(custom, key, timeString);
}
