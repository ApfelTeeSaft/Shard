; boot.asm
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

    ; Load the second stage bootloader
    mov si, load_msg
    call print_string

    ; Load the bootloader (1 sector, starting at LBA 1)
    mov bx, 0x0000   ; Segment to load at
    mov dh, 0x01     ; Number of sectors to read
    mov dl, 0x80     ; Drive number (first hard drive)
    mov cx, 0x0002   ; Starting LBA (logical block address)
    call disk_load

    ; Jump to the bootloader
    jmp 0x0000:0x0200

load_msg db "Loading second stage bootloader...", 0

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

disk_load:
    pusha
    mov ah, 0x02   ; BIOS read sectors
    mov al, dh     ; Number of sectors
    mov ch, 0x00   ; Cylinder
    mov cl, 0x02   ; Sector number
    mov dh, 0x00   ; Head number
    int 0x13
    jc .error
    popa
    ret
.error:
    mov si, error_msg
    call print_string
    hlt
error_msg db "Disk read error", 0

times 510-($-$$) db 0
dw 0xAA55