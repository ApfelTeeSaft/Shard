BITS 32

section .text
global _start
extern kernel_main

_start:
    ; Set up segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9C00

    ; Call kernel main function
    call kernel_main

    ; Hang if the kernel returns
halt:
    hlt
    jmp halt