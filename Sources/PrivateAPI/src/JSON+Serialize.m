//
//  JSON+Serialize.m
//  
//
//  Created by Dave DeLong on 5/27/23.
//

#import "JSON+Serialize.h"

// MARK: - Serialize

typedef struct _JSONSerializationContainer {
    int64_t written;
    bool isObject;
} _JSONSerializationContainer;

typedef struct _JSONSerializationContext {
    JSONSerializationOptions opts;
    int64_t writeCount;
    int fd;
    
    int64_t bufferSize;
    uint8_t *buffer;
    
    int64_t containerSize;
    int64_t containerCount;
    _JSONSerializationContainer *containers;
} _JSONSerializationContext;

void _JSONX_Write(_JSONSerializationContext *ctx, uint8_t byte) {
    if (ctx->fd > -1) {
        write(ctx->fd, &byte, 1);
        ctx->writeCount += 1;
    } else {
        if (ctx->writeCount >= ctx->bufferSize) {
            if (ctx->opts.requireSignalSafety == true) {
                // UH OH. can't write any more
                return;
            } else if (ctx->buffer == NULL) {
                ctx->bufferSize = 1024;
                ctx->buffer = calloc(ctx->bufferSize, sizeof(uint8_t));
            } else {
                ctx->bufferSize *= 2;
                ctx->buffer = realloc(ctx->buffer, ctx->bufferSize * sizeof(uint8_t));
            }
        }
        ctx->buffer[ctx->writeCount] = byte;
        ctx->writeCount += 1;
    }
}

void _JSONX_WriteString(_JSONSerializationContext *ctx, const char *str, BOOL quoted) {
    if (quoted) { _JSONX_Write(ctx, '"'); }
    
    size_t len = strlen(str);
    for (size_t i = 0; i < len; i++) {
        if (quoted && str[i] == '"') { _JSONX_Write(ctx, '\\'); }
        _JSONX_Write(ctx, str[i]);
    }
    
    if (quoted) { _JSONX_Write(ctx, '"'); }
}

void _JSONX_Push(_JSONSerializationContext *ctx, bool isObject) {
    if (ctx->containerCount == ctx->containerSize) {
        // need to alloc/realloc the containers buffer
        if (ctx->opts.requireSignalSafety == true) {
            // UH OH. bad stuff is about to go down
            return;
        } else if (ctx->containers == NULL) {
            ctx->containerSize = 8;
            ctx->containers = calloc(ctx->containerSize, sizeof(_JSONSerializationContainer));
        } else {
            ctx->containerSize *= 2;
            ctx->containers = realloc(ctx->containers, sizeof(_JSONSerializationContainer) * ctx->containerSize);
        }
    }
    ctx->containerCount += 1;
    ctx->containers[ctx->containerCount].isObject = isObject;
}

_JSONSerializationContainer *_JSONX_Last(_JSONSerializationContext *ctx) {
    if (ctx->containerCount == 0) { return NULL; }
    
    _JSONSerializationContainer *containers = ctx->containers;
    return containers + (ctx->containerCount);
}

int64_t _JSONX_Level(_JSONSerializationContext *ctx) {
    return MAX(ctx->containerCount, 0);
}

int64_t _JSONX_WrittenCount(_JSONSerializationContext *ctx) {
    _JSONSerializationContainer *last = _JSONX_Last(ctx);
    if (last == NULL) { return 0; }
    return last->written;
}

void _JSONX_Pop(_JSONSerializationContext *ctx) {
    if (ctx->containerCount > 0) {
        bzero(_JSONX_Last(ctx), sizeof(_JSONSerializationContainer));
        ctx->containerCount -= 1;
    }
}

void _JSONX_Indent(_JSONSerializationContext *ctx) {
    if (ctx->opts.prettyPrint == false) { return; }
    _JSONX_Write(ctx, '\n');
    int64_t level = _JSONX_Level(ctx);
    for (int64_t l = 0; l < level; l++) {
        _JSONX_Write(ctx, '\t');
    }
}

void _JSONX_NextField(_JSONSerializationContext *ctx) {
    _JSONSerializationContainer *last = _JSONX_Last(ctx);
    if (last == NULL) { return; }
    
    if (last->isObject == false) {
        if (_JSONX_WrittenCount(ctx) > 0) {
            _JSONX_Write(ctx, ',');
        }
        
        _JSONX_Indent(ctx);
    }
    
    last->written += 1;
}

void _JSONX_VisitNull(void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    _JSONX_NextField(ctx);
    _JSONX_WriteString(ctx, "null", false);
}

void _JSONX_VisitBool(bool boolean, void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    _JSONX_NextField(ctx);
    if (boolean == true) {
        _JSONX_WriteString(ctx, "true", false);
    } else {
        _JSONX_WriteString(ctx, "false", false);
    }
}

void  _JSONX_VisitString(const char * _Nonnull string, void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    _JSONX_NextField(ctx);
    _JSONX_WriteString(ctx, string, true);
}

void _JSONX_WriteInt(int64_t integer, _JSONSerializationContext *ctx) {
    uint8_t ascii0 = '0';
    
    int64_t remaining = integer;
    if (remaining < 0) {
        _JSONX_Write(ctx, '-');
        remaining *= -1;
    }
    
    double magnitude = floor(log10((double)remaining));
    BOOL hasWrittenDigit = NO;
    
    while (magnitude >= 0) {
        int power = (int)pow(10, magnitude);
        int8_t digit = remaining / power;
        if (digit > 0 || hasWrittenDigit) {
            digit += ascii0;
            _JSONX_Write(ctx, digit);
            hasWrittenDigit = YES;
        }
        remaining %= power;
        magnitude -= 1;
    }
    
    if (hasWrittenDigit == NO) {
        _JSONX_Write(ctx, '0');
    }
}

void _JSONX_VisitInt(int64_t integer, void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    _JSONX_NextField(ctx);
    _JSONX_WriteInt(integer, ctx);
}

void _JSONX_VisitDouble(double number, void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    _JSONX_NextField(ctx);
    int64_t integerPortion = (int64_t)floor(number);
    _JSONX_WriteInt(integerPortion, ctx);
    _JSONX_Write(ctx, '.');
    
    int64_t writeCount = 0;
    double remainder = number - (double)integerPortion;
    while (remainder > 0.0000000001) {
        remainder *= 10;
        int64_t digit = (int64_t)floor(remainder);
        _JSONX_Write(ctx, digit + '0');
        writeCount += 1;
        remainder -= digit;
    }
    if (writeCount == 0) { _JSONX_Write(ctx, '0'); }
}

void _JSONX_VisitArrayStart(void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    _JSONX_NextField(ctx);
    _JSONX_Write(ctx, '[');
    _JSONX_Push(ctx, false);
}

void _JSONX_VisitArrayEnd(void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    
    int64_t fieldsInContainer = _JSONX_Last(ctx)->written;
    _JSONX_Pop(ctx);
    if (fieldsInContainer > 0) { _JSONX_Indent(ctx); }
    _JSONX_Write(ctx, ']');
}

void _JSONX_VisitObjectStart(void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    _JSONX_NextField(ctx);
    _JSONX_Write(ctx, '{');
    _JSONX_Push(ctx, true);
}

void _JSONX_VisitKey(const char * _Nonnull key, void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    // don't use _JSONX_NextField here because the Key isn't the field; the Value is the field
    if (_JSONX_WrittenCount(ctx) > 0) {
        _JSONX_Write(ctx, ',');
    }
    
    _JSONX_Indent(ctx);
    _JSONX_WriteString(ctx, key, true);
    _JSONX_Write(ctx, ':');
    if (ctx->opts.prettyPrint) { _JSONX_Write(ctx, ' '); }
}

void _JSONX_VisitObjectEnd(void * _Nullable context) {
    _JSONSerializationContext *ctx = (_JSONSerializationContext *)context;
    
    int64_t fieldsInContainer = _JSONX_Last(ctx)->written;
    _JSONX_Pop(ctx);
    if (fieldsInContainer > 0) { _JSONX_Indent(ctx); }
    _JSONX_Write(ctx, '}');
}

void *_JSONSerialize(JSON *json, _JSONSerializationContext *ctx) {
    JSONVisitor v;
    v.visitNull = _JSONX_VisitNull;
    v.visitBool = _JSONX_VisitBool;
    v.visitString = _JSONX_VisitString;
    v.visitInt = _JSONX_VisitInt;
    v.visitDouble = _JSONX_VisitDouble;
    v.enterArray = _JSONX_VisitArrayStart;
    v.leaveArray = _JSONX_VisitArrayEnd;
    v.enterObject = _JSONX_VisitObjectStart;
    v.visitKey = _JSONX_VisitKey;
    v.leaveObject = _JSONX_VisitObjectEnd;
    
    JSONVisit(json, v, ctx);
    
    // write final NULL byte to terminate the buffer
    if (ctx->opts.includeNullByte == true) {
        _JSONX_Write(ctx, 0);
    }
}

void JSONSerializeToFile(JSON *json, int fd, JSONSerializationOptions opts) {
    _JSONSerializationContext ctx;
    ctx.opts = opts;
    
    ctx.writeCount = 0;
    ctx.fd = fd;
    ctx.bufferSize = 0;
    ctx.buffer = NULL;
    
    if (opts.requireSignalSafety) {
        ctx.containerCount = 0;
        ctx.containerSize = 512;
        
        _JSONSerializationContainer containers[512] = { 0 };
        ctx.containers = containers;
    } else {
        ctx.containerCount = 0;
        ctx.containerSize = 0;
        ctx.containers = NULL;
    }
    
    _JSONSerialize(json, &ctx);
}

void *JSONSerialize(JSON *json, JSONSerializationOptions opts) {
    _JSONSerializationContext ctx;
    ctx.opts = opts;
    ctx.opts.includeNullByte = true;
    
    ctx.writeCount = 0;
    ctx.fd = -1;
    ctx.bufferSize = 0;
    ctx.buffer = NULL;
    
    ctx.containerCount = 0;
    ctx.containerSize = 0;
    ctx.containers = NULL;
    
    _JSONSerialize(json, &ctx);
    
    uint8_t *resizedBuffer = realloc(ctx.buffer, ctx.writeCount);
    return resizedBuffer;
}

NSString *JSONSerializeToString(JSON *json, JSONSerializationOptions opts) {
    void *buffer = JSONSerialize(json, opts);
    return [[NSString alloc] initWithCString:buffer encoding:NSUTF8StringEncoding];
}


