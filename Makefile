AS=as
LD=ld
OBJCOPY=objcopy

BOOTLOADER_CODIGOS= \
	arquiteturas/arm64/boot.asm \
	drivers/virt/terminal.asm
	
BOOTLOADER_OBJETOS=$(BOOTLOADER_CODIGOS:.asm=.o)

KERNEL_CODIGOS= \
	nucleo/kernel.asm \
	biblis/ns.asm

KERNEL_OBJETOS=$(KERNEL_CODIGOS:.asm=.o)

bootloader.bin: bootloader.elf
	$(OBJCOPY) -O binary $< $@

bootloader.elf: $(BOOTLOADER_OBJETOS)
	$(LD) -nostdlib -T drivers/virt/linker.ld $^ -o $@

kernel.bin: kernel.elf
	$(OBJCOPY) -O binary $< $@
	@echo "=== kernel info ==="
	@echo "Tamanho do kernel:"
	@stat -c%s kernel.bin
	@echo "Primeiros bytes (hex):"
	@od -x kernel.bin | \
head -3

kernel.elf: $(KERNEL_OBJETOS)
	$(LD) -nostdlib -T drivers/virt/kernel.ld $^ -o $@

disco.img: bootloader.bin kernel.bin
	@echo "=== criando disco ==="
	@echo "Tamanho do bootloader:" `stat -c%s bootloader.bin` "bytes"
	@echo "Tamanho do kernel:" `stat -c%s kernel.bin` "bytes"
	dd if=/dev/zero of=$@ bs=512 count=2048 2>/dev/null
	dd if=bootloader.bin of=$@ bs=512 conv=notrunc 2>/dev/null
	dd if=kernel.bin of=$@ bs=512 seek=64 conv=notrunc 2>/dev/null
	@echo "Disco criado. Verificando setor 64:"
	@dd if=disco.img bs=512 skip=64 count=1 2>/dev/null | \
od -x | head -3

%.o: %.asm
	$(AS) $< -o $@
limpar:
	rm -f $(BOOTLOADER_OBJETOS) $(KERNEL_OBJETOS) \
		bootloader.elf bootloader.bin \
		kernel.elf kernel.bin \
		disco.img
qemu: disco.img
	qemu-system-aarch64 \
	-machine virt \
	-cpu cortex-a53 \
	-m 128M \
	-device loader,file=bootloader.bin,addr=0x40100000,cpu-num=0 \
	-serial stdio \
	-display none \
	-d in_asm -D qemu.log # debug obrigatorio pra identificar erros sutis de memoria

.PHONY: limpar qemu