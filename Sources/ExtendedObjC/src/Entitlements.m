//
//  Entitlements.m
//  
//
//  Created by Dave DeLong on 7/9/23.
//

#import "Entitlements.h"
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
NSData *_ReadEntitlementsFromTEXT(const struct mach_header *executable) {
    uint32_t dataOffset;
    uint64_t dataLength;
    
    BOOL is64bit = executable->magic == MH_MAGIC_64 || executable->magic == MH_CIGAM_64;
    if (is64bit) {
        const struct section_64 *section = getsectbynamefromheader_64((const struct mach_header_64 *)executable, "__TEXT", "__entitlements");
        if (section == NULL) { return nil; }
        dataOffset = section->offset;
        dataLength = section->size;
    } else {
        const struct section *section = getsectbynamefromheader(executable, "__TEXT", "__entitlements");
        if (section == NULL) { return nil; }
        dataOffset = section->offset;
        dataLength = (uint64_t)section->size;
    }
    
    uintptr_t dataStart = (uintptr_t)executable + dataOffset;
    return [NSData dataWithBytes:(const void *)dataStart length:dataLength];
}
#pragma clang diagnostic pop

NSData *_ReadEntitlementsFromCodeSignature(const struct mach_header *executable) {
    // TODO: does this need to be more resilient about big/little endian executables?
    
    BOOL is64bit = executable->magic == MH_MAGIC_64 || executable->magic == MH_CIGAM_64;
    uintptr_t cursor = (uintptr_t)executable + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
    
    const struct segment_command *segmentCommand = NULL;
    const struct segment_command *entitlementsSegment = NULL;
    for (uint32_t i = 0; i < executable->ncmds && entitlementsSegment == NULL; i++, cursor += segmentCommand->cmdsize) {
        segmentCommand = (struct segment_command *)cursor;
        if (segmentCommand->cmd == LC_CODE_SIGNATURE) { entitlementsSegment = segmentCommand; }
    }
    
    if (entitlementsSegment == NULL) { return nil; }
    
    const struct linkedit_data_command *dataCommand = (const struct linkedit_data_command *)entitlementsSegment;
    
    uintptr_t dataStart = (uintptr_t)executable + dataCommand->dataoff;
    CS_MultiBlob *multiBlob = (CS_MultiBlob *)dataStart;
    if (ntohl(multiBlob->magic) != 0xfade0cc0) { return nil; }
    
    uint32_t count = CFSwapInt32BigToHost(multiBlob->count);
    for (int i = 0; i < count; i++) {
        uint32_t blobOffset = CFSwapInt32BigToHost(multiBlob->index[i].offset);
        uintptr_t blobBytes = dataStart + blobOffset;
        uint32_t blobMagic = CFSwapInt32BigToHost(*(uint32_t *)blobBytes);
        if (blobMagic != 0xfade7171) { continue; }
        
        // the first 4 bytes are the magic
        // the next 4 are the length
        // after that is the encoded plist
        uint32_t blobLength = CFSwapInt32BigToHost(*(uint32_t *)(blobBytes + 4));
        return [NSData dataWithBytes:(const void *)(blobBytes + 8) length:(blobLength - 8)];
    }
    return nil;
}

NSDictionary<NSString *, id> * _Nullable _ReadEntitlementsFromHeader(const struct mach_header *executable) {
    if (executable->magic != MH_MAGIC && executable->magic != MH_MAGIC_64 && executable->magic != MH_CIGAM && executable->magic != MH_CIGAM_64) {
        // does not have a Mach-O magic value, of any flavor
        return nil;
    }
    
    if (executable->filetype != MH_EXECUTE) {
        // is not an executable mach-o file
        return nil;
    }
    
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
    const struct mach_header *executable = NULL;
    for (uint32_t i = 0; i < _dyld_image_count() && executable == NULL; i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        NSDictionary *headerEntitlements = _ReadEntitlementsFromHeader(header);
        if (headerEntitlements != nil) { return headerEntitlements; }
    }
    
    return nil;
}

NSDictionary<NSString *, id> * _Nullable EntitlementsPlistForBinary(NSData * _Nonnull data) {
    const void *raw = data.bytes;
    
    const struct fat_header *fatHeader = raw;
    
    // See if it's a fat little-endian Mach-O binary
    if (fatHeader->magic == FAT_MAGIC) {
        uint32_t numberOfArches = CFSwapInt32LittleToHost(fatHeader->nfat_arch);
        // it is!
        const struct fat_arch *archStart = raw + sizeof(struct fat_header);
        for (uint32_t i = 0; i < numberOfArches; i++) {
            const struct fat_arch *thisArch = archStart + i;
            const struct mach_header *header = raw + CFSwapInt32LittleToHost(thisArch->offset);
            
            NSDictionary *archEntitlements = _ReadEntitlementsFromHeader(header);
            if (archEntitlements != nil) { return archEntitlements; }
        }
    }
    
    // See if it's a fat big-endian Mach-O binary
    if (fatHeader->magic == FAT_CIGAM) {
        uint32_t numberOfArches = CFSwapInt32BigToHost(fatHeader->nfat_arch);
        
        // it is!
        const struct fat_arch *archStart = raw + sizeof(struct fat_header);
        for (uint32_t i = 0; i < numberOfArches; i++) {
            const struct fat_arch *thisArch = archStart + i;
            const struct mach_header *header = raw + CFSwapInt32BigToHost(thisArch->offset);
            
            NSDictionary *archEntitlements = _ReadEntitlementsFromHeader(header);
            if (archEntitlements != nil) { return archEntitlements; }
        }
    }
    
    // See if it's a 64-bit fat little-endian Mach-O binary
    if (fatHeader->magic == FAT_MAGIC_64) {
        uint32_t numberOfArches = CFSwapInt32LittleToHost(fatHeader->nfat_arch);
        
        // it is!
        const struct fat_arch_64 *archStart = raw + sizeof(struct fat_header);
        for (uint32_t i = 0; i < numberOfArches; i++) {
            const struct fat_arch_64 *thisArch = archStart + i;
            const struct mach_header *header = raw + CFSwapInt64LittleToHost(thisArch->offset);
            
            NSDictionary *archEntitlements = _ReadEntitlementsFromHeader(header);
            if (archEntitlements != nil) { return archEntitlements; }
        }
    }
    
    // See if it's a 64-bit fat big-endian Mach-O binary
    if (fatHeader->magic == FAT_CIGAM_64) {
        uint32_t numberOfArches = CFSwapInt32BigToHost(fatHeader->nfat_arch);
        
        // it is!
        const struct fat_arch_64 *archStart = raw + sizeof(struct fat_header);
        for (uint32_t i = 0; i < numberOfArches; i++) {
            const struct fat_arch_64 *thisArch = archStart + i;
            const struct mach_header *header = raw + CFSwapInt64BigToHost(thisArch->offset);
            
            NSDictionary *archEntitlements = _ReadEntitlementsFromHeader(header);
            if (archEntitlements != nil) { return archEntitlements; }
        }
    }
    
    // if we get here, it's not a fat Mach-O binary
    // see if it's a single-arch Mach-O file:
    const struct mach_header *executable = raw;
    return _ReadEntitlementsFromHeader(executable);
}
