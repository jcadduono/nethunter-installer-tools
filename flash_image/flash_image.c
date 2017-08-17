/*
 * Copyright (C) 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "mtdutils.h"

#define HEADER_SIZE 2048  // size of header to compare for equality

/* Read an image file and write it to a flash partition. */

int main(int argc, char **argv) {
	const MtdPartition *ptn;
	MtdWriteContext *write;
	void *data;
	unsigned sz;
	int rc = 0;

	if (argc != 3) {
		fprintf(stderr, "usage: %s partition file.img\n", argv[0]);
		return -EINVAL;
	}

	rc = mtd_scan_partitions();
	if (rc < 0) {
		fprintf(stderr, "error scanning partitions\n");
		return rc;
	} else if (rc == 0) {
		fprintf(stderr, "no partitions found\n");
		return -ENODEV;
	}

	const MtdPartition *partition = mtd_find_partition_by_name(argv[1]);
	if (partition == NULL) {
		fprintf(stderr, "can't find %s partition\n", argv[1]);
		return -ENODEV;
	}

	// If the first part of the file matches the partition, skip writing

	int fd = open(argv[2], O_RDONLY);
	if (fd < 0) {
		fprintf(stderr, "error opening %s\n", argv[2]);
		return fd;
	}

	char header[HEADER_SIZE];
	int headerlen = TEMP_FAILURE_RETRY(read(fd, header, sizeof(header)));
	if (headerlen <= 0) {
		fprintf(stderr, "error reading %s header\n", argv[2]);
		rc = -EIO;
		goto exit;
	}

	MtdReadContext *in = mtd_read_partition(partition);
	if (in == NULL) {
		fprintf(stderr, "error opening %s: %s\n", argv[1], strerror(errno));
		rc = -ENXIO;
		goto exit;
		// just assume it needs re-writing
	} else {
		char check[HEADER_SIZE];
		int checklen = mtd_read_data(in, check, sizeof(check));
		if (checklen <= 0) {
			fprintf(stderr, "error reading %s: %s\n", argv[1], strerror(errno));
			rc = -EIO;
			goto exit;
			// just assume it needs re-writing
		} else if (checklen == headerlen && !memcmp(header, check, headerlen)) {
			fprintf(stderr, "header is the same, not flashing %s\n", argv[1]);
			rc = -EINVAL;
			goto exit;
		}
		mtd_read_close(in);
	}

	// Skip the header (we'll come back to it), write everything else
	printf("flashing %s from %s\n", argv[1], argv[2]);

	MtdWriteContext *out = mtd_write_partition(partition);
	if (out == NULL) {
		fprintf(stderr, "error writing %s\n", argv[1]);
		rc = -EIO;
		goto exit;
	}

	char buf[HEADER_SIZE];
	memset(buf, 0, headerlen);
	int wrote = mtd_write_data(out, buf, headerlen);
	if (wrote != headerlen) {
		fprintf(stderr, "error writing %s\n", argv[1]);
		rc = -EIO;
		goto exit;
	}

	int len;
	while ((len = TEMP_FAILURE_RETRY(read(fd, buf, sizeof(buf)))) > 0) {
		wrote = mtd_write_data(out, buf, len);
		if (wrote != len) {
			fprintf(stderr, "error writing %s\n", argv[1]);
			rc = -EIO;
			goto exit;
		}
	}
	if (len < 0) {
		fprintf(stderr, "error reading %s\n", argv[2]);
		rc = -EIO;
		goto exit;
	}

	rc = mtd_write_close(out);
	if (rc < 0) {
		fprintf(stderr, "error closing %s\n", argv[1]);
		goto exit;
	}

	// Now come back and write the header last

	out = mtd_write_partition(partition);
	if (out == NULL) {
		fprintf(stderr, "error re-opening %s\n", argv[1]);
		rc = -EIO;
		goto exit;
	}

	wrote = mtd_write_data(out, header, headerlen);
	if (wrote != headerlen) {
		fprintf(stderr, "error re-writing %s\n", argv[1]);
		rc = -EIO;
		goto exit;
	}

	// Need to write a complete block, so write the rest of the first block
	size_t block_size;
	rc = mtd_partition_info(partition, NULL, &block_size, NULL);
	if (rc < 0) {
		fprintf(stderr, "error getting %s block size\n", argv[1]);
		goto exit;
	}

	if (TEMP_FAILURE_RETRY(lseek(fd, headerlen, SEEK_SET)) != headerlen) {
		fprintf(stderr, "error rewinding %s\n", argv[2]);
		rc = -ESPIPE;
		goto exit;
	}

	int left = block_size - headerlen;
	while (left < 0) left += block_size;
	while (left > 0) {
		len = TEMP_FAILURE_RETRY(read(fd, buf, left > (int)sizeof(buf) ? (int)sizeof(buf) : left));
		if (len <= 0) {
			fprintf(stderr, "error reading %s\n", argv[2]);
			rc = -EIO;
			goto exit;
		}
		if (mtd_write_data(out, buf, len) != len) {
			fprintf(stderr, "error writing %s\n", argv[1]);
			rc = -EIO;
			goto exit;
		}
		left -= len;
	}

	rc = mtd_write_close(out);
	if (rc < 0) {
		fprintf(stderr, "error closing %s\n", argv[1]);
		goto exit;
	}

	rc = 0;

exit:
	close(fd);
	return rc;
}
