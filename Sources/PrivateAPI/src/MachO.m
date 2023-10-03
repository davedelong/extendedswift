//
//  MachO.m
//  
//
//  Created by Dave DeLong on 7/22/23.
//

#import "MachO.h"

void dyld_enumerateImages(void(^iterator)(const char *name, intptr_t slide, const struct mach_header *mh, BOOL *keepGoing)) {
    BOOL keepGoing = YES;
    for (uint32_t i = 0; i < _dyld_image_count() && keepGoing == YES; i++) {
        const char *name = _dyld_get_image_name(i);
        intptr_t slide = _dyld_get_image_vmaddr_slide(i);
        const struct mach_header *header = _dyld_get_image_header(i);
        iterator(name, slide, header, &keepGoing);
    }
}

void fat_enumerateMachHeaders(const struct fat_header *fh, void(^iterator)(const struct mach_header *mh, BOOL *keepGoing)) {
    if (fat_isValid(fh) == NO) { return; }
    
    // FAT headers are always written in Big-Endian:
    // mach-o/fat.h: "All structures defined here are always written and read to/from disk in big-endian order."
    uintptr_t raw = fh;
    
    BOOL is32Bit = fat_is32Bit(fh);
    uint32_t archCount = ReadBigInt32(fh->nfat_arch);
    size_t headerSize = sizeof(struct fat_header);
    size_t archSize = is32Bit ? sizeof(struct fat_arch) : sizeof(struct fat_arch_64);
    
    uintptr_t archCursor = raw + headerSize;
    BOOL keepGoing = YES;
    for (uint32_t i = 0; i < archCount && keepGoing == YES; i++) {
        uintptr_t headerOffset;
        if (is32Bit) {
            const struct fat_arch *arch = (const struct fat_arch *)archCursor;
            uint32_t offset = ReadBigInt32(arch->offset);
            headerOffset = raw + offset;
        } else {
            const struct fat_arch_64 *arch = (const struct fat_arch_64 *)archCursor;
            uint64_t offset = ReadBigInt64(arch->offset);
            headerOffset = raw + offset;
        }
        
        const struct mach_header *mh = (const struct mach_header *)headerOffset;
        iterator(mh, &keepGoing);
        
        archCursor += archSize;
    }
}

void mach_enumerateSegments(const struct mach_header *mh, void(^iterator)(const struct segment_command *segment, BOOL *keepGoing)) {
    BOOL needsSwap = mach_isSwapped(mh);
    
    uintptr_t headerSize = mach_is32Bit(mh) ? sizeof(struct mach_header) : sizeof(struct mach_header_64);
    uintptr_t segmentCursor = (uintptr_t)mh + headerSize;
    
    BOOL keepGoing = YES;
    uint32_t numberOfCommands = mach_ncmds(mh);
    
    for (uint32_t i = 0; i < numberOfCommands && keepGoing == YES; i++) {
        struct segment_command *segment = segmentCursor;
        iterator(segment, &keepGoing);
        segmentCursor += ReadInt32(segment->cmdsize, needsSwap);
    }
}

void _mach_enumerateSections(const struct mach_header *mh, const struct segment_command *segment, void(^iterator)(const struct segment_command *segment, const struct section *section, BOOL *keepGoing)) {
    if (mh == NULL) { return; }
    if (segment == NULL) { return; }
    
    BOOL is32Bit = mach_is32Bit(mh);
    BOOL needsSwap = mach_isSwapped(mh);
    
    uint32_t segmentSize = is32Bit ? sizeof(struct segment_command) : sizeof(struct segment_command_64);
    uintptr_t *cursor = (uintptr_t)segment + segmentSize;
    
    uint32_t nsections = ReadInt32(segment->nsects, needsSwap);
    
    BOOL keepGoing = YES;
    for (uint32_t i = 0; i < nsections && keepGoing == YES; i++) {
        const struct section *section = (const struct section *)cursor;
        iterator(segment, section, &keepGoing);
        
        cursor += ReadInt32(section->size, needsSwap);
    }
}

void mach_enumerateSections(const struct mach_header *mh, void(^iterator)(const struct segment_command *segment, const struct section *section, BOOL *keepGoing)) {
    mach_enumerateSegments(mh, ^(const struct segment_command *segment, BOOL *keepGoingSegment) {
        _mach_enumerateSections(mh, segment, ^(const struct segment_command *segment, const struct section *section, BOOL *keepGoingSections) {
            BOOL keepGoing = YES;
            iterator(segment, section, &keepGoing);
            *keepGoingSections = keepGoing;
            *keepGoingSegment = keepGoing;
        });
    });
}

const struct segment_command * _Nullable mach_findSegmentByCommand(const struct mach_header *mh, uint32_t command) {
    BOOL needsSwap = mach_isSwapped(mh);
    
    __block const struct segment_command *final = NULL;
    mach_enumerateSegments(mh, ^(const struct segment_command *segment, BOOL *keepGoing) {
        if (ReadInt32(segment->cmd, needsSwap) == command) {
            final = segment;
            *keepGoing = NO;
        }
    });
    return final;
}

const struct segment_command * _Nullable mach_findSegmentByName(const struct mach_header *mh, const char *name) {
    size_t n = MIN(strlen(name), 16);
    __block const struct segment_command *final = NULL;
    mach_enumerateSegments(mh, ^(const struct segment_command *segment, BOOL *keepGoing) {
        if (strncmp(segment->segname, name, n) == 0) {
            final = segment;
            *keepGoing = NO;
        }
    });
    return final;
}

const struct section * _Nullable mach_findSection(const struct mach_header *mh, const char *segmentName, const char *sectionName) {
    BOOL is32Bit = mach_is32Bit(mh);
    BOOL needsSwap = mach_isSwapped(mh);
    
    const struct segment_command *segment = mach_findSegmentByName(mh, segmentName);
    if (segment == NULL) { return NULL; }
    
    size_t n = MIN(strlen(sectionName), 16);
    __block const struct section *final = NULL;
    _mach_enumerateSections(mh, segment, ^(const struct segment_command *segment, const struct section *section, BOOL *keepGoing) {
        if (strncmp((char *)section->sectname, sectionName, n) == 0) {
            final = section;
            *keepGoing = NO;
        }
    });
    return final;
}
