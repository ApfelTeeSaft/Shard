BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    lgdt [gdt_descriptor]
    
    in al, 0x92
    or al, 00000010b
    out 0x92, al

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode

BITS 32
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9C00

    extern kernel_main
    call kernel_main

halt:
    hlt
    jmp halt

gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

TIMES 510 - ($-$$) db 0
DW 0xAA55