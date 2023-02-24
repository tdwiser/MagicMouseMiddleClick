.DEFAULT_GOAL = all
.PHONY: all, clean

CC = gcc
CFLAGS = -O2
LDFLAGS = -F/System/Library/PrivateFrameworks -framework MultitouchSupport -framework CoreFoundation -framework ApplicationServices -lobjc

all: mmmc

mmmc: mmmc.m
	$(CC) -o mmmc mmmc.m $(CFLAGS) $(LDFLAGS)

clean:
	rm mmmc
