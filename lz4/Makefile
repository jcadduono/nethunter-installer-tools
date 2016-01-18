OBJ_FILES := lz4cli.o lz4io.o lz4frame.o lz4hc.o lz4.o xxhash.o

override CFLAGS += -DLZ4_VERSION=\"r131\"

all: lz4

lz4: $(OBJ_FILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) $(OBJ_FILES) lz4

