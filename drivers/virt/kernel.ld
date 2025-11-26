ENTRY(principal)
SECTIONS
{
    . = 0x40200000;
    
    .text : {
        *(.text)
        *(.text.*)
    }

    .data : { 
        *(.data)
        *(.data.*)
    }

    .bss : {
        _kernel_bss_inicio = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _kernel_bss_fim = .;
    }

    /DISCARD/ : {
        *(.comment)
        *(.note.*)
    }
}