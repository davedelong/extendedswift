//
//  MachO.h
//  
//
//  Created by Dave DeLong on 7/22/23.
//

#import <Foundation/Foundation.h>
#import <mach-o/fat.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>

NS_ASSUME_NONNULL_BEGIN

#define ReadInt32(_x, _s) ((_s) ? ntohl(_x): (_x))
#define ReadInt64(_x, _s) ((_s) ? ntohll(_x): (_x))

#if __DARWIN_BYTE_ORDER == __DARWIN_LITTLE_ENDIAN
#define ReadBigInt32(_x) ntohl(_x)
#define ReadBigInt64(_x) ntohll(_x)
#else
#define ReadBigInt32(_x) (_x)
#define ReadBigInt64(_x) (_x)
#endif

void dyld_enumerateImages(void(^iterator)(const char *name, intptr_t slide, const struct mach_header *mh, BOOL *keepGoing));

#define fat_isSwapped(_fh) ((_fh)->magic == FAT_CIGAM || (_fh)->magic == FAT_CIGAM_64)
#define fat_is32Bit(_fh) ((_fh)->magic == FAT_MAGIC || (_fh)->magic == FAT_CIGAM)
#define fat_is64Bit(_fh) ((_fh)->magic == FAT_MAGIC_64 || (_fh)->magic == FAT_CIGAM_64)
#define fat_isValid(_fh) (fat_is32Bit(_fh) || fat_is64Bit(_fh))

void fat_enumerateMachHeaders(const struct fat_header *fh, void(^iterator)(const struct mach_header *mh, BOOL *keepGoing));

#define mach_isSwapped(_mh) ((_mh)->magic == MH_CIGAM || (_mh)->magic == MH_CIGAM_64)
#define mach_is32Bit(_mh) ((_mh)->magic == MH_MAGIC || (_mh)->magic == MH_CIGAM)
#define mach_is64Bit(_mh) ((_mh)->magic == MH_MAGIC_64 || (_mh)->magic == MH_CIGAM_64)
#define mach_isValid(_mh) (mach_is32Bit(_mh) || mach_is64Bit(_mh))

#define mach_magic(_mh) ReadInt32((_mh)->magic, mach_isSwapped(_mh))
#define mach_filetype(_mh) ReadInt32((_mh)->filetype, mach_isSwapped(_mh))
#define mach_ncmds(_mh) ReadInt32((_mh)->ncmds, mach_isSwapped(_mh))

void mach_enumerateSegments(const struct mach_header *mh, void(^iterator)(const struct segment_command *segment, BOOL *keepGoing));
void mach_enumerateSections(const struct mach_header *mh, void(^iterator)(const struct segment_command *segment, const struct section *section, BOOL *keepGoing));

const struct segment_command * _Nullable mach_findSegmentByCommand(const struct mach_header *mh, uint32_t command);
const struct segment_command * _Nullable mach_findSegmentByName(const struct mach_header *mh, const char *name);

const struct section * _Nullable mach_findSection(const struct mach_header *mh, const char *segment, const char *section);

NS_ASSUME_NONNULL_END
