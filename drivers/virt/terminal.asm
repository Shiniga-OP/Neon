// drivers/virt/terminal.asm
.global _escrever_tex
.global _escrever_car
.global _obter_car
.global _config_uart

uart_base_real: .quad 0

_config_uart:
    // inicializa uart_base_real apenas uma vez
    ldr x9, = UART_BASE
    ldr x10, = uart_base_real
    str x9, [x10]
    
    // habilita TX
    mov w1, 0x301
    ldr x2, = UART_CR
    str w1, [x9, x2]
    ret

_escrever_car:
    // pega UART base diretamente
    ldr x9, = uart_base_real
    ldr x9, [x9]
    // escreve direto
    ldr x3, = UART_DR
    strb w0, [x9, x3]
    ret

_obter_car:
    ldr x9, = uart_base_real
    ldr x9, [x9]
1:
    ldr x3, = UART_FR
    ldr w1, [x9, x3]
    ldr x2, = FR_RXFE
    ands w1, w1, w2
    b.ne 1b
    ldr x3, = UART_DR
    ldrb w0, [x9, x3]
    ret

_escrever_tex:
    ldr x1, = uart_base_real
    ldr x1, [x1]
1:
    ldrb w2, [x0], 1
    cbz w2, 2f
    ldr x4, = UART_DR
    strb w2, [x1, x4]
    b 1b
2:
    ret