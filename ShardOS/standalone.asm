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

    call kernel_main

halt:
    hlt
    jmp halt

kernel_main:
    mov esi, msg
    mov edi, 0xb8000

print_loop:
    lodsb
    cmp al, 0
    je done
    mov ah, 0x07
    mov [edi], ax
    add edi, 2
    jmp print_loop

done:
    ret

msg db 'Hello, ShardOS!', 0

gdt_start:
    dq 0x0000000000000000  ; Null descriptor
    dq 0x00CF9A000000FFFF  ; Code segment descriptor
    dq 0x00CF92000000FFFF  ; Data segment descriptor

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

TIMES 510 - ($-$$) db 0
DW 0xAA55