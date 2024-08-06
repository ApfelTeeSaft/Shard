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

    ; Load the second stage loader (2 sectors starting at LBA 1)
    mov bx, 0x2000   ; Segment to load at (0x2000:0x0000 -> 0x20000)
    mov ah, 0x02     ; BIOS read sectors
    mov al, 0x02     ; Number of sectors to read
    mov ch, 0x00     ; Cylinder
    mov cl, 0x02     ; Sector number
    mov dh, 0x00     ; Head number
    mov dl, 0x80     ; Drive number
    int 0x13
    jc disk_error

    ; Jump to the second stage loader
    jmp 0x2000:0x0000

disk_error:
    mov si, disk_error_msg
    call print_string
    hlt

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

load_msg db "Loading second stage loader...", 0
disk_error_msg db "Disk read error", 0

times 510-($-$$) db 0
dw 0xAA55