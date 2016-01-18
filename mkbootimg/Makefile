all: mkbootimg unpackbootimg

mkbootimg: mkbootimg.o mincrypt/sha.o
	$(CC) $(LDFLAGS) $^ -o $@

unpackbootimg: unpackbootimg.o mincrypt/sha.o
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) mkbootimg mkbootimg.o unpackbootimg unpackbootimg.o mincrypt/sha.o

