OBJ_FILES := \
termcap.o \
tparam.o \
version.o

TARGET := libtermcap.so

override CFLAGS += -I. -fPIC \
-DHAVE_STRING_H=1 \
-DHAVE_UNISTD_H=1 \
-DSTDC_HEADERS=1 \
-DTERMCAP_FILE=\"/etc/termcap\"

override LDFLAGS += -shared

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) $(OBJ_FILES) $(TARGET)

