CC = gcc
CFLAGS = -O0 -ggdb3 -std=c99 -static
TARGET_DIR = bin
TARGET = $(TARGET_DIR)/false_sharing
SRC = false_sharing.c
OBJ = $(SRC:.c=.o)
DISASSEMBLY = $(TARGET_DIR)/false_sharing.s

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
	