CC = aarch64-linux-gnu-gcc
CFLAGS = -static -march=armv8-a -pthread
TARGET_DIR = bin
TARGET = $(TARGET_DIR)/dmb
SRC = dmb.c
OBJ = $(SRC:.c=.o)
DISASSEMBLY = $(TARGET_DIR)/dmb.s

.PHONY: all clean disassemble

all: $(TARGET) disassemble

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

disassemble: $(TARGET)
	aarch64-linux-gnu-objdump -d $(TARGET) > $(DISASSEMBLY)

clean:
	rm -f $(TARGET) $(OBJ) $(DISASSEMBLY)