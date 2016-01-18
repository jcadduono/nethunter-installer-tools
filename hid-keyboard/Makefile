all: hid-keyboard

hid-keyboard: hid-gadget-test.o
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	$(RM) hid-gadget-test.o hid-keyboard

