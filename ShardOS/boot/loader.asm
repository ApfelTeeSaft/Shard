BITS 16
ORG 0x0000

start:
    ; Print entering protected mode message
    mov si, loader_msg
    call print_string

    ; Disable interrupts
    cli

    ; Load the GDT
    lgdt [gdt_descriptor]

    ; Enable protected mode by setting PE bit in CR0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Far jump to flush the prefetch queue and enter protected mode
    jmp CODE_SEG:init_pm

BITS 32
init_pm:
    ; Set up segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9C00

    ; Print kernel loaded message
    mov si, kernel_msg
    call print_string

    ; Call the C kernel main function
    call kernel_main

    ; Hang if the kernel returns
halt:
    hlt
    jmp halt

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

gdt_start:
    ; Null descriptor
    dw 0, 0, 0, 0
    ; Code segment descriptor (base=0x00000000, limit=0xFFFFF)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A  ; Code segment descriptor
    db 0xCF
    db 0x00
    ; Data segment descriptor (base=0x00000000, limit=0xFFFFF)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92  ; Data segment descriptor
    db 0xCF
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_start + 8
DATA_SEG equ gdt_start + 16

loader_msg db "Entering protected mode...", 0
kernel_msg db "Kernel loaded, calling kernel main...", 0

times 510-($-$$) db 0
dw 0xAA55

extern kernel_main