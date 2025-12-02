// arquiteturas/boot.asm
.section .text.boot
.global inicio

inicio:
    // zera a sessão BSS
    ldr x0, = _bss_inicio
    ldr x1, = _bss_fim 
    mov x2, 0 // valor pra zerar
zerar_bss:
    cmp x0, x1
    b.ge fim_zerar_bss
    str x2, [x0], 8 // zera 8 bytes e avança
    b zerar_bss
fim_zerar_bss:
    // configura pilha
    ldr x0, = _pilha_fim
    mov sp, x0
    // configura uart
    bl _config_uart
    
    ldr x0, = comando
    bl _escrever_tex
    
    bl ns_loop
ns_loop:
    bl _obter_car
    
    cmp w0, 0x0D
    b.eq nova_linha
    
    bl _escrever_car
    
    cmp w0, 'a'
    b.eq 1f // ajuda
    
    cmp w0, 's'
    b.eq 2f // status
    
    cmp w0, 'e'
    b.eq carregar_kernel
    
    b ns_loop
nova_linha:
    mov w0, 0x0A
    bl _escrever_car
    ldr x0, = comando
    bl _escrever_tex
    b ns_loop
carregar_kernel:
    mov w0, 0x0A
    bl _escrever_car
    
    ldr x0, = msg_carregando
    bl _escrever_tex
    
    bl _carregar_kernel
    
    cbnz x0, erro_carregamento
    
    // DEBUG
    // verificação extensiva do kernel carregado
    ldr x0, = msg_verificando_kernel
    bl _escrever_tex
    
    // 1. verifica se a memoria não ta toda zerada
    ldr x0, = 0x40200000
    ldr x1, [x0]
    ldr x0, = msg_kernel_primeiros_bytes
    bl _escrever_tex
    mov x0, x1
    bl _escrever_hex
    ldr x0, = msg_nova_linha
    bl _escrever_tex
    
    // verifica se não é memoria zerada
    cbz x1, kernel_zerado
    
    // 2. verifica multiplas posições
    ldr x0, = msg_verificando_multiplas_pos
    bl _escrever_tex
    
    // posição 0
    ldr x0, = 0x40200000
    ldr x1, [x0]
    ldr x0, = msg_posicao
    bl _escrever_tex
    ldr x0, = 0x40200000
    bl _escrever_hex
    ldr x0, = msg_valor
    bl _escrever_tex
    mov x0, x1
    bl _escrever_hex
    ldr x0, = msg_nova_linha
    bl _escrever_tex
    
    // posição 0x100
    ldr x0, = 0x40200100
    ldr x1, [x0]
    ldr x0, = msg_posicao
    bl _escrever_tex
    ldr x0, = 0x40200100
    bl _escrever_hex
    ldr x0, = msg_valor
    bl _escrever_tex
    mov x0, x1
    bl _escrever_hex
    ldr x0, = msg_nova_linha
    bl _escrever_tex
    
    // posição 0x200
    ldr x0, = 0x40200200
    ldr x1, [x0]
    ldr x0, = msg_posicao
    bl _escrever_tex
    ldr x0, = 0x40200200
    bl _escrever_hex
    ldr x0, = msg_valor
    bl _escrever_tex
    mov x0, x1
    bl _escrever_hex
    ldr x0, = msg_nova_linha
    bl _escrever_tex
    
    // 3. teste de escrita/leitura na area do kernel
    ldr x0, = msg_testando_memoria
    bl _escrever_tex
    
    // escreve padrão de teste em endereço temporario
    ldr x0, = 0x40210000  // apos o kernel
    ldr x1, = 0x123456789ABCDEF0
    str x1, [x0]
    
    // le de volta
    ldr x2, [x0]
    cmp x1, x2
    b.ne memoria_defeituosa
    
    ldr x0, = msg_memoria_ok
    bl _escrever_tex
    
    // 4. verifica instruções validas no ponto de entrada
    ldr x0, = msg_verificando_instrucoes
    bl _escrever_tex
    
    ldr x0, = 0x40200000
    ldr w1, [x0]
    ldr x0, = msg_primeira_instrucao
    bl _escrever_tex
    mov x0, x1
    bl _escrever_hex
    ldr x0, = msg_nova_linha
    bl _escrever_tex
    
    // 5. soma de Verificação dos primeiros 512 bytes
    ldr x0, = msg_calculando_soma
    bl _escrever_tex
    
    mov x2, 0 // soma
    mov x3, 64 // 64 * 8 bytes = 512 bytes
    ldr x4, = 0x40200000
soma_loop:
    ldr x1, [x4], 8
    add x2, x2, x1
    subs x3, x3, 1
    b.ne soma_loop
    
    ldr x0, = msg_soma
    bl _escrever_tex
    mov x0, x2
    bl _escrever_hex
    ldr x0, = msg_nova_linha
    bl _escrever_tex
    
    // 6. debug critico, testa execução do kernel
    ldr x0, = msg_debug_critico
    bl _escrever_tex
    
    // testa execução controlada
    ldr x0, = msg_testando_execucao
    bl _escrever_tex
    
    // salva estado atual
    mov x19, x30  // salva LR
    
    ldr x0, = msg_salto
    bl _escrever_tex
    ldr x0, = 0x40200000
    blr x0
    
    // se retornou, algo deu errado
    ldr x0, = msg_retornou_erro
    bl _escrever_tex
    mov x30, x19  // restaura LR
    b erro_carregamento
    
debug_continuar:
    // se chegou aqui, o teste passou
    ldr x0, = msg_teste_passou
    bl _escrever_tex
    mov x30, x19  // Restaura LR
    
    // 7. confirmação final
    ldr x0, = msg_kernel_pronto
    bl _escrever_tex
    
    ldr x0, = msg_confirmacao_salto
    bl _escrever_tex
    
    // pausa pra visualização
    ldr x0, 200000
1:  subs x0, x0, 1
    b.ne 1b
    
    // executa o kernel:
    ldr x0, = msg_salto
    bl _escrever_tex
    
    ldr x0, = 0x40200000 // endereço do kernel
    blr x0
    
kernel_zerado:
    ldr x0, = msg_kernel_zerado
    bl _escrever_tex
    b erro_carregamento
    
memoria_defeituosa:
    ldr x0, = msg_memoria_defeituosa
    bl _escrever_tex
    b erro_carregamento
    
erro_carregamento:
    ldr x0, = msg_erro_carregamento
    bl _escrever_tex
    b ns_loop
1:
    mov w0, 0x0A
    bl _escrever_car
    ldr x0, = msg_ajuda
    bl _escrever_tex
    b nova_linha
2:
    mov w0, 0x0A
    bl _escrever_car
    ldr x0, = msg_status
    bl _escrever_tex
    b nova_linha

.section .rodata
comando: .asciz "~ $ "
msg_carregando: .asciz "[bootloader]: Carregando kernel...\r\n"
msg_salto: .asciz "[bootloader] saltando pro kernel...\r\n"
msg_ajuda: .asciz "[Comandos]:\ns: status do bootloader\ne: executar o kernel\r\n"
msg_status: .asciz "[BootLoader]: Neon-boot 0.0.1\n\r[Arquitetura]: ARM64\n\r[Pilha]: 16 KB\r\n"
msg_erro: .asciz "[ERRO]: ainda estamos no bootloader"
msg_erro_carregamento: .asciz "[ERRO]: Falha ao carregar kernel\r\n"
// msgs de debug
msg_verificando_kernel: .asciz "[DEBUG] Verificando kernel carregado...\r\n"
msg_kernel_primeiros_bytes: .asciz "[DEBUG] Primeiros 8 bytes: "
msg_verificando_multiplas_pos: .asciz "[DEBUG] Verificando múltiplas posições:\r\n"
msg_posicao: .asciz "[DEBUG] Pos "
msg_valor: .asciz ": "
msg_testando_memoria: .asciz "[DEBUG] Testando memória...\r\n"
msg_memoria_ok: .asciz "[DEBUG] Memória OK\r\n"
msg_verificando_instrucoes: .asciz "[DEBUG] Verificando instruções...\r\n"
msg_primeira_instrucao: .asciz "[DEBUG] Primeira instrução: "
msg_calculando_soma: .asciz "[DEBUG] Calculando soma de verificação...\r\n"
msg_soma: .asciz "[DEBUG] Soma (512 bytes): "
msg_kernel_pronto: .asciz "[DEBUG] Kernel parece válido\r\n"
msg_confirmacao_salto: .asciz "[DEBUG] Saltando para kernel em 2 segundos...\r\n"
msg_kernel_zerado: .asciz "[ERRO] Kernel zerado - possivel falha no carregamento\r\n"
msg_memoria_defeituosa: .asciz "[ERRO] Memória defeituosa\r\n"
msg_nova_linha: .asciz "\r\n"
msg_debug_critico: .asciz "[DEBUG CRITICO] Testando execução do kernel...\r\n"
msg_testando_execucao: .asciz "[DEBUG] Testando execução controlada...\r\n"
msg_retornou_erro: .asciz "[ERRO] Kernel retornou - código inválido\r\n"
msg_teste_passou: .asciz "[DEBUG] Teste de execução passou!\r\n"
