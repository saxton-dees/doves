
# Build configuration.
CC = gcc
CFLAGS = -O2 -fPIC -shared
INCLUDES = /usr/include/lua5.1
MODULE_NAME = lua_pid

# Targets
.PHONY: all clean

all: $(MODULE_NAME).so

$(MODULE_NAME).so: $(MODULE_NAME).c
	$(CC) $(CFLAGS) -I$(INCLUDES) -o $@ $<

clean:
	rm -f $(MODULE_NAME).so

