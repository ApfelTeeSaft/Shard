BITS 16
ORG 0x7C00

start:
    ; Set up the stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print loading message
    mov si, load_msg
    call print_string

    ; Load the kernel (sectors starting at LBA 1)
    mov bx, 0x1000   ; Segment to load at
    mov ah, 0x02     ; BIOS read sectors
    mov al, 0x02     ; Number of sectors to read
    mov ch, 0x00     ; Cylinder
    mov cl, 0x02     ; Sector number
    mov dh, 0x00     ; Head number
    mov dl, 0x80     ; Drive number
    int 0x13
    jc disk_error

    ; Jump to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm

disk_error:
    mov si, disk_error_msg
    call print_string
    hlt

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
    ; Code segment descriptor
    dw 0xFFFF, 0x0000, 0x9A00, 0x00CF
    ; Data segment descriptor
    dw 0xFFFF, 0x0000, 0x9200, 0x00CF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_start + 8
DATA_SEG equ gdt_start + 16

load_msg db "Loading kernel...", 0
disk_error_msg db "Disk read error", 0

times 510-($-$$) db 0
dw 0xAA55

extern kernel_main