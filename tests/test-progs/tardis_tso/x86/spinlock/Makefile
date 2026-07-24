CC = gcc
CFLAGS = -O0 -ggdb3 -std=c99 -static
TARGET_DIR = bin
TARGET = $(TARGET_DIR)/spinlock
SRC = spinlock.c
OBJ = $(SRC:.c=.o)
DISASSEMBLY = $(TARGET_DIR)/spinlock.s

.PHONY: all clean disassemble

all: $(TARGET) disassemble

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJ) $(DISASSEMBLY)

disassemble: $(TARGET)
	objdump -D $(TARGET) > $(DISASSEMBLY)
	