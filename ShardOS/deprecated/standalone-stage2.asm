BITS 16
ORG 0x9000

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
    call clear_screen

    mov esi, welcome_msg
    call print_string

    mov esi, command_prompt_msg
    call print_string

cli_loop:
    mov esi, prompt
    call print_string

    call read_string
    call parse_command
    jmp cli_loop

clear_screen:
    mov edi, 0xb8000
    mov ecx, 2000
    mov eax, 0x0720
    rep stosd
    ret

print_string:
    mov edi, 0xb8000
    add edi, [cursor_offset]
.next_char:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x07
    stosw
    add dword [cursor_offset], 2
    jmp .next_char
.done:
    ret

read_string:
    mov edi, input_buffer
    xor ecx, ecx
.read_char:
    in al, 0x60
    cmp al, 0x1C
    je .enter
    cmp al, 0x0E
    je .backspace
    mov ah, 0x07
    stosw
    add dword [cursor_offset], 2
    jmp .read_char
.enter:
    mov byte [edi], 0
    ret
.backspace:
    sub edi, 2
    cmp edi, input_buffer
    jb .read_char
    mov ax, 0x0720
    stosw
    sub dword [cursor_offset], 2
    jmp .read_char

parse_command:
    mov esi, input_buffer
    mov edi, command_help
    call strcmp
    je .help
    mov edi, command_clear
    call strcmp
    je .clear
    mov edi, command_halt
    call strcmp
    je .halt
    mov edi, command_sysview
    call strcmp
    je .sysview
    ret

.help:
    mov esi, help_msg
    call print_string
    ret

.clear:
    call clear_screen
    ret

.halt:
    jmp halt

.sysview:
    mov esi, sysview_msg
    call print_string
    ret

strcmp:
    repe cmpsb
    sete al
    movzx eax, al
    ret

welcome_msg db 'Welcome to ShardOS CLI!', 0
command_prompt_msg db 'Type a command. Use "help" for a list of commands.', 0
prompt db 'ShardOS> ', 0
help_msg db 'Commands: help, clear, halt, sysview', 0
sysview_msg db 'System View: Basic hardware info.', 0
command_help db 'help', 0
command_clear db 'clear', 0
command_halt db 'halt', 0
command_sysview db 'sysview', 0
input_buffer times 256 db 0
cursor_offset dd 0

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