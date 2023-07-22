//
//  JSON+Serialize.h
//  
//
//  Created by Dave DeLong on 5/27/23.
//

#import "JSON.h"

typedef struct JSONSerializationOptions {
    bool prettyPrint;
    bool includeNullByte;
    bool requireSignalSafety;    
} JSONSerializationOptions;

void *JSONSerialize(JSON *json, JSONSerializationOptions opts);

void JSONSerializeToFile(JSON *json, int fd, JSONSerializationOptions opts);
NSString *JSONSerializeToString(JSON *json, JSONSerializationOptions opts);
