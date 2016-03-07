VERSION := 3.99.0
VERSION_DATE := 2015-05-16

C_DEFS := \
	-DVERSION=\"$(VERSION)\" -DVERSION_DATE=\"$(VERSION_DATE)\" \
	-DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_SYS_ENDIAN_H=1 -DHAVE_STDLIB_H=1 \
	-DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 \
	-DHAVE_UNISTD_H=1 -DHAVE_ERR_H=1 -DHAVE_LINUX_FD_H=1 -DHAVE_LINUX_HDREG_H=1 -DHAVE_LINUX_VERSION_H=1 \
	-DHAVE_SYS_QUEUE_H=1 -DHAVE_ENDIAN_H=1 -DHAVE_DECL_GETMNTENT=1 -DHAVE_DECL_GETMNTINFO=0

COMMON_CFLAGS := -Wall -Wextra -Wno-sign-compare -Wno-missing-field-initializers -Wmissing-prototypes -Wstrict-prototypes -Wwrite-strings $(C_DEFS)

FSCKLABEL_SOURCES := boot.c check.c common.c fat.c file.c io.c lfn.c charconv.c

MKFS_SOURCES := device_info.c blkdev/blkdev.c blkdev/linux_version.c

FATLABEL_SOURCES := fatlabel.c $(FSCKLABEL_SOURCES)
FATLABEL_CFLAGS := $(COMMON_CFLAGS) $(CFLAGS)
FSCK_FAT_SOURCES := fsck.fat.c $(FSCKLABEL_SOURCES)
FSCK_FAT_CFLAGS := $(COMMON_CFLAGS) $(CFLAGS)
MKFS_FAT_SOURCES := mkfs.fat.c msdos_fs.h $(MKFS_SOURCES)
MKFS_FAT_CFLAGS := -Iblkdev $(COMMON_CFLAGS) $(CFLAGS)

all: mkfs.fat fsck.fat fatlabel

mkfs.fat: $(MKFS_FAT_SOURCES)
	$(CC) $(LDFLAGS) $(MKFS_FAT_CFLAGS) $^ -o $@

fsck.fat: $(FSCK_FAT_SOURCES)
	$(CC) $(LDFLAGS) $(FSCK_FAT_CFLAGS) $^ -o $@

fatlabel: $(FATLABEL_SOURCES)
	$(CC) $(LDFLAGS) $(FATLABEL_CFLAGS) $^ -o $@

clean:
	$(RM) mkfs.fat fsck.fat fatlabel
