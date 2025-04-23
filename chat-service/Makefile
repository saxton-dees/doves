
# Build configuration.
CC = gcc
CFLAGS = -O2 -fPIC -shared
INCLUDES = /usr/include/lua5.1
MODULE_NAME = lua_pid

.PHONY: run

# Build the shared library.
lua_pid.so: lua_pid.c
	$(CC) $(CFLAGS) -o $(MODULE_NAME).so $(MODULE_NAME).c -I$(INCLUDES)

