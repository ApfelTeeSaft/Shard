BITS 32
global _start
extern kernel_main

section .text
_start:
    ; Set up segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9C00

    ; Print debug message
    mov si, bootloader_msg
    call print_string

    ; Call kernel main function
    mov si, kernel_msg
    call print_string
    call kernel_main

    ; Hang if the kernel returns
halt:
    hlt
    jmp halt

bootloader_msg db "Second stage bootloader running...\n", 0
kernel_msg db "Calling kernel main...\n", 0

print_string:
    mov ah, 0x0E
.repeat:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .repeat
.done:
    ret