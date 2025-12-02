.data
# Parte 2 — Conversão: Decimal -> Complemento de 2 (16 bits)
# Arquivo: Calculadora_Parte2.asm
# Descrição: Programa MIPS didático que lê um inteiro decimal e mostra
# o procedimento para obter o complemento a 2 em 16 bits (invert + 1)
# Mensagens e comentários em português. Recomendado MARS.

prompt_int:    .asciiz "\nDigite um inteiro (base 10) e pressione Enter: "
menu_p2:       .asciiz "\n=== PARTE 2: COMPLEMENTO DE 2 (16 bits) ===\n1) Converter para complemento de 2 (16 bits)\n2) Sair\nEscolha (1-2): "
newline:       .asciiz "\n"
step_inv:      .asciiz "Passo: inverter bits (XOR com 0xFFFF) -> "
step_add1:     .asciiz "Passo: somar 1 ao valor invertido -> "
result_label:  .asciiz "\nComplemento de 2 (16 bits): "

.text
.globl main

main:
menu_loop:
    li $v0,4; la $a0, menu_p2; syscall
    li $v0,5; syscall
    move $t9,$v0
    beq $t9,1, p2_twos
    beq $t9,2, p2_exit
    j menu_loop

# rotina leitura inteiro
read_int_p2:
    li $v0,4; la $a0, prompt_int; syscall
    li $v0,5; syscall
    move $s0,$v0
    jr $ra

# Conversão para complemento de 2 (16 bits)
p2_twos:
    jal read_int_p2
    move $t0,$s0
    li $v0,4; la $a0, result_label; syscall

    # máscara para 16 bits
    li $t1, 0xFFFF
    and $t2, $t0, $t1    # t2 contém os 16 bits do número

    # Se negativo, mostrar passos invert+1
    bltz $t0, p2_negative_step
    # se positivo, apenas imprimir 16 bits
    j p2_print_bits

p2_negative_step:
    # inverter bits (XOR 0xFFFF)
    li $v0,4; la $a0, step_inv; syscall
    xori $t3, $t2, 0xFFFF
    move $a0,$t3; li $v0,1; syscall

    # somar 1
    li $v0,4; la $a0, step_add1; syscall
    addi $t4,$t3,1
    move $a0,$t4; li $v0,1; syscall
    move $t2,$t4

# imprimir 16 bits de t2 (MSB -> LSB)
p2_print_bits:
    li $t5,15
p2_print_loop:
    srl $t6,$t2,15
    andi $t6,$t6,1
    addi $a0,$t6,48; li $v0,11; syscall
    sll $t2,$t2,1
    subi $t5,$t5,1
    bgez $t5, p2_print_loop
    j menu_loop

p2_exit:
    li $v0,10; syscall

# Fim Parte 2
