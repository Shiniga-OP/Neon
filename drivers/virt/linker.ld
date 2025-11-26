/* drivers/virt/linker.ld */
ENTRY(inicio)

UART_BASE = 0x09000000;
UART_FR = 0x18;
FR_TXFF = 0x20;
FR_RXFE = 0x10;
UART_DR = 0x00;
UART_CR = 0x30;

SECTIONS {
    . = 0x40100000;
    .text : {
        *(.text.boot)
        *(.text)
        *(.text.*)
    }
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }
    .data : { 
        *(.data)
        *(.data.*)
    }
    . = ALIGN(4096);
    .bss : {
        _bss_inicio = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4096);
        _bss_fim = .;
    }
    . = ALIGN(16);
    _pilha_inicio = .;
    . += 0x4000;
    _pilha_fim = .;

    KERNEL_ENDERECO = 0x40200000;
}