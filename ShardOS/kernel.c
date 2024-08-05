// kernel.c
void kernel_main() {
    const char *str = "Hello World in ShardOS!";
    char *vidptr = (char*)0xb8000;
    unsigned int i = 0;
    unsigned int j = 0;

    while (str[j] != '\0') {
        vidptr[i++] = str[j++];
        vidptr[i++] = 0x07;
    }

    return;
}