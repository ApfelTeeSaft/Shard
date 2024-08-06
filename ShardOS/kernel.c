#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// Hardware text mode color constants
enum vga_color {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
};

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

uint16_t* const VGA_MEMORY = (uint16_t*) 0xB8000;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
    return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
    return (uint16_t) uc | (uint16_t) color << 8;
}

void terminal_initialize(void) {
    terminal_row = 0;
    terminal_column = 0;
    terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    terminal_buffer = VGA_MEMORY;
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            terminal_buffer[index] = vga_entry(' ', terminal_color);
        }
    }
}

void terminal_setcolor(uint8_t color) {
    terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) {
    const size_t index = y * VGA_WIDTH + x;
    terminal_buffer[index] = vga_entry(c, color);
}

void terminal_putchar(char c) {
    if (c == '\n') {
        terminal_row++;
        terminal_column = 0;
        return;
    }
    terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
    if (++terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_row = 0;
        }
    }
}

void terminal_write(const char* data, size_t size) {
    for (size_t i = 0; i < size; i++)
        terminal_putchar(data[i]);
}

size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len])
        len++;
    return len;
}

void terminal_writestring(const char* data) {
    terminal_write(data, strlen(data));
}

// Function declarations
void halt(void);
uint8_t inb(uint16_t port);

int strcmp(const char* str1, const char* str2) {
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return *(unsigned char*)str1 - *(unsigned char*)str2;
}

// Keyboard data buffer
#define KEYBOARD_BUFFER_SIZE 256
char keyboard_buffer[KEYBOARD_BUFFER_SIZE];
size_t keyboard_buffer_position = 0;

char scancode_to_ascii(uint8_t scancode) {
    // German keyboard scancode to ASCII conversion
    static char scancode_table[128] = {
        0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 223, 180, '\b',
        '\t', 'q', 'w', 'e', 'r', 't', 'z', 'u', 'i', 'o', 'p', 252, '+', '\n',
        0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 246, 228, '#',
        0, '<', 'y', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '-', 0,
        '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    };

    static char shift_scancode_table[128] = {
        0,  27, '!', '"', 167, '$', '%', '&', '/', '(', ')', '=', '?', '`', '\b',
        '\t', 'Q', 'W', 'E', 'R', 'T', 'Z', 'U', 'I', 'O', 'P', 220, '*', '\n',
        0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 214, 196, '\'',
        0, '>', 'Y', 'X', 'C', 'V', 'B', 'N', 'M', ';', ':', '_', 0,
        '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    };

    static bool shift_pressed = false;
    static bool caps_lock = false;

    if (scancode == 0x2A || scancode == 0x36) { // Left shift or right shift pressed
        shift_pressed = true;
        return 0;
    }
    if (scancode == 0xAA || scancode == 0xB6) { // Left shift or right shift released
        shift_pressed = false;
        return 0;
    }
    if (scancode == 0x3A) { // Caps Lock pressed
        caps_lock = !caps_lock;
        return 0;
    }

    if (scancode < 128) {
        if (shift_pressed || caps_lock) {
            return shift_scancode_table[scancode];
        } else {
            return scancode_table[scancode];
        }
    }

    return 0;
}

void keyboard_handler(void) {
    uint8_t scancode = inb(0x60);
    // Handle only printable characters and backspace
    if (scancode < 0x80) {
        char c = scancode_to_ascii(scancode);
        if (c) {
            if (c == '\b' && keyboard_buffer_position > 0) {
                keyboard_buffer[--keyboard_buffer_position] = '\0';
                terminal_putchar('\b');
            } else if (c >= ' ' && c <= '~') {
                if (keyboard_buffer_position < KEYBOARD_BUFFER_SIZE - 1) {
                    keyboard_buffer[keyboard_buffer_position++] = c;
                    terminal_putchar(c);
                }
            }
        }
    }
}

void read_string(char* buffer, size_t buffer_size) {
    keyboard_buffer_position = 0;
    while (1) {
        if (keyboard_buffer_position > 0 && keyboard_buffer[keyboard_buffer_position - 1] == '\n') {
            break;
        }
    }
    for (size_t i = 0; i < keyboard_buffer_position && i < buffer_size - 1; i++) {
        buffer[i] = keyboard_buffer[i];
    }
    buffer[keyboard_buffer_position - 1] = '\0'; // Replace '\n' with null terminator
}

void parse_command(char* input) {
    if (strcmp(input, "help") == 0) {
        terminal_writestring("Commands: help, clear, halt, sysview\n");
    } else if (strcmp(input, "clear") == 0) {
        terminal_initialize();
    } else if (strcmp(input, "halt") == 0) {
        halt();
    } else if (strcmp(input, "sysview") == 0) {
        terminal_writestring("System View: Basic hardware info.\n");
    } else {
        terminal_writestring("Unknown command. Type 'help' for a list of commands.\n");
    }
}

void kernel_main(void) {
    terminal_initialize();
    terminal_writestring("Welcome to ShardOS CLI!\n");
    terminal_writestring("Type a command. Use 'help' for a list of commands.\n");

    char input_buffer[256];
    while (true) {
        terminal_writestring("ShardOS> ");
        read_string(input_buffer, sizeof(input_buffer));
        parse_command(input_buffer);
    }
}

void halt(void) {
    while (1) {
        asm volatile ("hlt");
    }
}

uint8_t inb(uint16_t port) {
    uint8_t result;
    asm volatile("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}