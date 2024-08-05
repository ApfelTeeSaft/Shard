# ShardOS

<p align="center">
  <img src="https://github.com/user-attachments/assets/001dfe63-9b9c-4d69-b18a-7ec27b697813" alt="ShardOS Logo" width="256" height="256">
</p>

ShardOS is a simple operating system built from scratch for educational purposes. This project demonstrates the basics of OS development, including bootloading, kernel development, and simple hardware interaction.

## Screenshot

![image](https://github.com/user-attachments/assets/f58939df-0d91-4950-bf9f-4168f074a2dc)


## Prerequisites

To build ShardOS, you need the following tools installed on your Linux system:

- `nasm` (Netwide Assembler)
- `gcc` (GNU Compiler Collection)
- `ld` (GNU Linker)
- `qemu` (for emulation and testing)

You can install these tools using your package manager. For example, on Debian-based systems like Ubuntu, run:

```sh
sudo apt update
sudo apt install nasm gcc make qemu-system-x86
```

## Building ShardOS

### 1. Assemble the Bootloader

Assemble the bootloader using `nasm`:

```sh
nasm -f elf32 boot/boot.asm -o boot.o
```

### 2. Compile the Kernel

Compile the kernel using `gcc`:

```sh
gcc -m32 -ffreestanding -c kernel.c -o kernel.o
```

### 3. Link the Object Files

Link the bootloader and kernel using `ld`:

```sh
ld -m elf_i386 -T link.ld -o ShardOS.bin boot.o kernel.o
```

### 4. Create a Bootable Image

Create a bootable image by concatenating the boot sector and the kernel:

```sh
dd if=/dev/zero of=boot.img bs=512 count=2880
dd if=ShardOS.bin of=boot.img conv=notrunc
```

### 5. Run with QEMU

Run your OS using QEMU:

```sh
qemu-system-i386 -fda boot.img
```

## File Structure

- `boot/boot.asm`: Assembly code for the bootloader.
- `kernel.c`: C code for the kernel.
- `link.ld`: Linker script for combining the bootloader and kernel into a single binary.
- `deprecated/stage1/2.asm`: Old attempt at making a Standalone OS purely in Assembly

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

This project is licensed under the GNU General Public License v3.0.
3. **Run ShardOS using QEMU**:
   ```bash
   qemu-system-i386 -fda boot.img
   ```
## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/ApfelTeeSaft/Shard/blob/main/LICENSE) file for details.
