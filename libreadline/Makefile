OBJ_FILES := \
readline.o \
vi_mode.o \
funmap.o \
keymaps.o \
parens.o \
search.o \
rltty.o \
complete.o \
bind.o \
isearch.o \
display.o \
signals.o \
util.o \
kill.o \
undo.o \
macro.o \
input.o \
callback.o \
terminal.o \
text.o \
nls.o \
misc.o \
compat.o \
xfree.o \
xmalloc.o \
history.o \
histexpand.o \
histfile.o \
histsearch.o \
shell.o \
mbutil.o \
tilde.o

TARGET := libreadline.so

override CFLAGS += -I. -fPIC -DHAVE_CONFIG_H -DRL_LIBRARY_VERSION='"6.2"'

override LDFLAGS += -shared \
-L../libncurses -lncurses

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) $(OBJ_FILES) $(TARGET)

