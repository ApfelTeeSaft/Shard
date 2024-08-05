# ShardOS

<p align="center">
  <img src="https://github.com/user-attachments/assets/001dfe63-9b9c-4d69-b18a-7ec27b697813" alt="ShardOS Logo" width="256" height="256">
</p>

ShardOS is a simple operating system developed as a learning project. It includes a basic bootloader and kernel written in assembly and C.

## Screenshot

![image](https://github.com/user-attachments/assets/f58939df-0d91-4950-bf9f-4168f074a2dc)


## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Building and Running](#building-and-running)
  - [Bootloader with C Kernel](#bootloader-with-c-kernel)
  - [Standalone ASM Kernel](#standalone-asm-kernel)
- [License](#license)

## Introduction

ShardOS is a minimal operating system project designed to understand the fundamentals of OS development. It consists of a bootloader and a basic kernel that prints a "Hello World" message to the screen. Alternatively, it can run a standalone ASM kernel that prints "Hello, ShardOS!".

## Features

- Basic bootloader written in assembly
- Simple kernel written in C
- Option to run a standalone bootloader with an integrated ASM kernel
- "Hello World" message display

## Requirements

To build and run ShardOS, you need the following tools installed on your system:

- NASM (Netwide Assembler)
- GCC (GNU Compiler Collection) with MinGW for cross-compilation
- QEMU (Quick Emulator) for testing

## Installation

### Windows

1. **Install Chocolatey**: If you don't have Chocolatey installed, open PowerShell as Administrator and run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; `
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. **Install required packages**:
   ```cmd
   choco install nasm mingw qemu
   ```

### Linux

1. **Install required packages** (Debian-based systems):
   ```bash
   sudo apt update
   sudo apt install nasm gcc qemu
   ```

## Building and Running

### Bootloader with C Kernel

1. **Clone the repository**:
   ```bash
   git clone https://github.com/apfelteesaft/Shard.git
   cd Shard
   ```

2. **Assemble the bootloader**:
   ```bash
   nasm -f elf32 boot.asm -o boot.o
   ```

3. **Compile the kernel**:
   ```bash
   gcc -m32 -ffreestanding -c kernel.c -o kernel.o
   ```

4. **Link the object files**:
   ```bash
   ld -m i386pe -T link.ld -o ShardOS.bin boot.o kernel.o
   ```

5. **Create a bootable disk image**:
   ```cmd
   fsutil file createnew boot.img 1474560
   copy /b boot.bin+boot.img boot.img
   ```

6. **Run ShardOS using QEMU**:
   ```bash
   qemu-system-i386 -fda boot.img
   ```

### Standalone ASM Kernel

1. **Assemble the standalone bootloader**:
   ```bash
   nasm -f bin standalone.asm -o standalone.bin
   ```

2. **Create a bootable disk image**:
   ```cmd
   fsutil file createnew boot.img 1474560
   copy /b standalone.bin+boot.img boot.img
   ```

3. **Run ShardOS using QEMU**:
   ```bash
   qemu-system-i386 -fda boot.img
   ```
## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/ApfelTeeSaft/Shard/blob/main/LICENSE) file for details.
