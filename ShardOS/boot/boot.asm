BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Load the second stage bootloader
    mov si, msg
    call print_string

    ; Load the second stage bootloader
    mov bx, 0x1000
    mov dh, 1
    mov dl, 0
    mov ch, 0
    mov cl, 2

    mov ah, 0x02
    mov al, 1
    int 0x13

    ; Jump to second stage bootloader
    jmp 0x1000:0

print_string:
    mov ah, 0x0e
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

msg db "Loading second stage bootloader...", 0

times 510-($-$$) db 0
dw 0xAA55