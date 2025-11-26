// biblis/ns.asm
.global ns_abrir

.equ REG_TABELA_CHAMADAS, 19
.equ _ESCREVER_TEX, 0
.equ _ESCREVER_CAR, 1
.equ _OBTER_CAR, 2
.equ TAM_PONTEIRO, 8

msg_coisa: .asciz "alguma coisa\r\n"

.align 2
1:
    ldr x0, = msg_coisa
    ldr x1, [x19, _ESCREVER_TEX * TAM_PONTEIRO]
    blr x1
    b ns_abrir // volta pro loop
ns_abrir:
    ldr x1, [x19, _OBTER_CAR * TAM_PONTEIRO]
    blr x1
    
    mov w1, '@'
    cmp w0, w1 // verifica se digitou "@"
    b.eq 1b
    
    ldr x1, [x19, _ESCREVER_CAR * TAM_PONTEIRO]
    blr x1
    // quebra de linha
    mov w0, 0x0A
    ldr x1, [x19, _ESCREVER_CAR * TAM_PONTEIRO]
    blr x1
    
    b ns_abrir
.end
