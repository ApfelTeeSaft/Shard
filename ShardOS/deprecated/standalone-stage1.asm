BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov bx, 0x9000
    mov dh, 0x01
    call load_sectors

    jmp 0x9000:0x0000

load_sectors:
    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, 0x00
    int 0x13
    jc error
    ret

error:
    ; hlt cuz fuck you
    hlt

TIMES 510 - ($-$$) db 0
DW 0xAA55