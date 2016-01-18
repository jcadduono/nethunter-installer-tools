OBJ_FILES := usb.o error.o descriptors.o linux.o

TARGET := libusb.so

override CFLAGS += -fPIC
override LDFLAGS += -shared

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) $(OBJ_FILES) $(TARGET)

