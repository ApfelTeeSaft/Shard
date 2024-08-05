# ShardOS

ShardOS is a simple operating system developed as a learning project. It includes a basic bootloader and kernel written in assembly and C.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Building and Running](#building-and-running)
- [License](#license)

## Introduction

ShardOS is a minimal operating system project designed to understand the fundamentals of OS development. It consists of a bootloader and a basic kernel that prints a "Hello World" message to the screen.

## Features

- Basic bootloader written in assembly
- Simple kernel written in C
- "Hello World" message display

## Requirements

To build and run ShardOS, you need the following tools installed on your system:

- NASM (Netwide Assembler)
- GCC (GNU Compiler Collection) with MinGW for cross-compilation
- QEMU (Quick Emulator) for testing
- dd for creating bootable disk images

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

1. **Clone the repository**:
   ```bash
   git clone https://github.com/apfelteesaft/Shard.git
   cd Shard
   cd ShardOS
   ```

2. **Assemble the bootloader**:
   ```bash
   nasm -f elf32 boot/boot.asm -o boot/boot.o
   ```

3. **Compile the kernel**:
   ```bash
   gcc -m32 -ffreestanding -c kernel.c -o kernel.o
   ```

4. **Link the object files**:
   ```bash
   ld -m i386pe -T link.ld -o ShardOS.bin boot/boot.o kernel.o
   ```

5. **Create a bootable disk image**:
   ```bash
   dd if=/dev/zero of=boot.img bs=512 count=2880
   dd if=ShardOS.bin of=boot.img conv=notrunc
   ```

6. **Run ShardOS using QEMU**:
   ```bash
   qemu-system-i386 -fda boot.img
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/apfelteesaft/shard/LICENSE) file for details.
