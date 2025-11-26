// arquiteturas/arm64/boot.asm
.section .text.boot
.global inicio

inicio:
    // pilha
    ldr x0, = _pilha_fim
    mov sp, x0
    // configurar UART
    mov x0, 0
    bl _config_uart
    
    ldr x0, = msg_ola
    bl _escrever_tex
    
    ldr x0, = msg_funcionou  
    bl _escrever_tex
    
    bl ns_abrir
fim:
    wfe
    b fim

.align 2
1:
    ldr x0, = msg_coisa
    bl _escrever_tex
    b ns_abrir // volta pro loop
ns_abrir:
    bl _obter_car
    
    mov w1, '@'
    cmp w0, w1 // verifica se digitou "@"
    b.eq 1b
    
    bl _escrever_car
    // quebra de linha
    mov w0, 0x0A
    bl _escrever_car
    
    b ns_abrir

.section .rodata
msg_ola: .asciz "BOOTLOADER ARM64\r\n"
msg_funcionou: .asciz "FUNCIONOU\r\n"
msg_coisa: .asciz "alguma coisa\r\n"

// pilha
.section .bss
.space 0x4000
_pilha_fim:
