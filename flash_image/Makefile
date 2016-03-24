OBJ_FILES := flash_image.o mtdutils.o mounts.o

TARGET := flash_image

override CFLAGS += -I.

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) $(OBJ_FILES) $(TARGET)

