// nucleo/kernel.asm
// constantes pra acesso a tabela de chamadas do sistema(x0)
.equ REG_TABELA_CHAMADAS, 19
.equ _ESCREVER_TEX, 0
.equ _ESCREVER_CAR, 1
.equ _OBTER_CAR, 2
.equ TAM_PONTEIRO, 8

.global principal

principal:
    // salva registradores x29(FP) e x30(LR) e ajusta a pilha
    stp x29, x30, [sp, -16]!
    // salva o endereço da tabela de chamadas(passado em x0) em x19
    mov x19, x0 
    // _escrever_tex(função 0 na tabela)
    ldr x0, = msg_kernel 
    ldr x1, [x19, _ESCREVER_TEX * TAM_PONTEIRO] // carrega endereço do _escrever_tex
    blr x1 
    // loop de parada
    ldr x0, = msg_parada
    ldr x1, [x19, _ESCREVER_TEX * TAM_PONTEIRO]
    blr x1
    // reinicia a pilha e entra em loop infinito
    ldp x29, x30, [sp], 16
    b . 
.section .rodata
msg_kernel:
.asciz "Kernel iniciado com sucesso! Controle assumido.\r\n"

msg_parada:
.asciz "Parada do Kernel\r\n"
