//
//  Entitlements.m
//  
//
//  Created by Dave DeLong on 7/9/23.
//

#import "Entitlements.h"
#import "ExtendedObjC.h"
#import <mach-o/fat.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>

// adapted from https://opensource.apple.com/source/Security/Security-55471/sec/Security/Tool/codesign.c

/*
 * Structure of an embedded-signature MultiBlob (called a SuperBlob in the codesign source)
 */
typedef struct __BlobIndex {
    uint32_t type;                   /* type of entry */
    uint32_t offset;                 /* offset of entry */
} CS_Blob;

typedef struct __MultiBlob {
    uint32_t magic;                  /* magic number */
    uint32_t length;                 /* total length of SuperBlob */
    uint32_t count;                  /* number of index entries following */
    CS_Blob index[];                 /* (count) entries */
    /* followed by Blobs in no particular order as indicated by offsets in index */
} CS_MultiBlob;

NSData *_ReadEntitlementsFromTEXT(const struct mach_header *mh) {
    BOOL needsSwap = mach_isSwapped(mh);
    const struct section *section = mach_findSection(mh, "__TEXT", "__entitlements");
    if (section == NULL) { return nil; }
    
    uint32_t offset = ReadInt32(section->offset, needsSwap);
    uint64_t length = ReadInt64(section->size, needsSwap);
    
    uintptr_t dataStart = (uintptr_t)mh + offset;
    return [NSData dataWithBytes:(const void *)dataStart length:length];
}

NSData *_ReadEntitlementsFromCodeSignature(const struct mach_header *mh) {
    BOOL needsSwap = mach_isSwapped(mh);
    
    const struct linkedit_data_command *dataCommand = (const struct linkedit_data_command *)mach_findSegmentByCommand(mh, LC_CODE_SIGNATURE);
    if (dataCommand == NULL) { return nil; }
    
    uint32_t offset = ReadInt32(dataCommand->dataoff, needsSwap);
    
    // the MultiBlobs always use big endianness
    // the .c file linked above uses ntohl() to swap the numbers
    // from big endian to host endian
    uintptr_t dataStart = (uintptr_t)mh + offset;
    CS_MultiBlob *multiBlob = (CS_MultiBlob *)dataStart;
    
    uint32_t multiBlobMagic = ReadBigInt32(multiBlob->magic);
    if (multiBlobMagic != 0xfade0cc0) { return nil; }
    
    uint32_t count = ReadInt32(multiBlob->count, YES);
    for (uint32_t i = 0; i < count; i++) {
        uint32_t blobOffset = ReadBigInt32(multiBlob->index[i].offset);
        uintptr_t blobBytes = dataStart + blobOffset;
        
        uint32_t blobMagic = ReadBigInt32(*(uint32_t *)blobBytes);
        if (blobMagic != 0xfade7171) { continue; }
        
        // the first 4 bytes are the magic
        // the next 4 are the length
        // after that is the encoded plist
        uint32_t *blobLengthStart = blobBytes + 4;
        
        uint32_t blobLength = ReadBigInt32(*blobLengthStart);
        return [NSData dataWithBytes:(const void *)(blobBytes + 8) length:(blobLength - 8)];
    }
    return nil;
}

NSDictionary<NSString *, id> * _Nullable _ReadEntitlementsFromHeader(const struct mach_header *executable) {
    if (mach_isValid(executable) == NO) { return nil; }
    
    NSData *entitlements = _ReadEntitlementsFromCodeSignature(executable);
    if (entitlements == nil) {
        entitlements = _ReadEntitlementsFromTEXT(executable);
    }
    
    if (entitlements != nil) {
        id plist = [NSPropertyListSerialization propertyListWithData:entitlements options:0 format:nil error:nil];
        if ([plist isKindOfClass:[NSDictionary class]]) { return plist; }
    }
    
    return nil;
}

NSDictionary<NSString *, id> * _Nullable EntitlementsPlistForCurrentProcess() {
    
    // we don't care about mach_header vs mach_header_64 because we only care about the filetype field,
    // which is at the same offset in both structs
    __block NSDictionary *entitlements = nil;
    dyld_enumerateImages(^(const char * _Nonnull name, intptr_t slide, const struct mach_header * _Nonnull mh, BOOL * _Nonnull keepGoing) {
        if (mach_filetype(mh) == MH_EXECUTE) {
            entitlements = _ReadEntitlementsFromHeader(mh);
            if (entitlements != nil) { *keepGoing = NO; }
        }
    });
    
    return entitlements;
}

NSDictionary<NSString *, id> * _Nullable EntitlementsPlistForBinary(NSData * _Nonnull data) {
    const void *raw = data.bytes;
    
    const struct fat_header *fatHeader = raw;
    __block NSDictionary *final = nil;
    
    fat_enumerateMachHeaders(fatHeader, ^(const struct mach_header * _Nonnull mh, BOOL * _Nonnull keepGoing) {
        final = _ReadEntitlementsFromHeader(mh);
        if (final != nil) { *keepGoing = NO; }
    });
    
    if (final == nil) {
        // if we get here, it's not a fat Mach-O binary
        // see if it's a single-arch Mach-O file:
        const struct mach_header *mh = raw;
        final = _ReadEntitlementsFromHeader(mh);
    }
    
    return final;
    
}
