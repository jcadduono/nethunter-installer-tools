OBJ_FILES := \
client/nonce2key/crapto1.o \
client/nonce2key/crypto1.o \
client/nonce2key/nonce2key.o \
common/crc16.o \
common/iso14443crc.o \
common/iso15693tools.o \
client/mifarehost.o \
client/data.o \
client/graph.o \
client/ui.o \
client/util.o \
client/cmddata.o \
client/cmdhf.o \
client/cmdhf14a.o \
client/cmdhf14b.o \
client/cmdhf15.o \
client/cmdhfepa.o \
client/cmdhflegic.o \
client/cmdhficlass.o \
client/cmdhfmf.o \
client/cmdhw.o \
client/cmdlf.o \
client/cmdlfem4x.o \
client/cmdlfhid.o \
client/cmdlfhitag.o \
client/cmdlfti.o \
client/cmdparser.o \
client/cmdmain.o \
client/guidummy.o \
client/proxusb.o \
client/proxmark3.o \
client/cmdlft55xx.o \
client/cmdlfpcf7931.o

TARGET := proxmark3

override CFLAGS += \
-std=c99 -DCMIN=1 -DCTIME=0 \
-Iinclude \
-Icommon \
-Iclient \
-I..

override LDFLAGS += \
-L../libusb -L../libtermcap -L../libreadline \
-lusb -ltermcap -lreadline

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) $(OBJ_FILES) $(TARGET)

