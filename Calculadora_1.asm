.data
# Parte 1 — Conversões: Decimal -> Binário, Octal, Hexadecimal, BCD
# Arquivo: Calculadora_Parte1.asm
# Descrição: Programa MIPS didático que lê um inteiro decimal e realiza
# as 4 conversões acima, mostrando passo a passo (divisões, quociente e resto)
# Recomendado: executar no MARS (syscalls compatíveis). Mensagens em português.

prompt_int:      .asciiz "
Digite um inteiro (base 10) e pressione Enter: "
menu_p1:         .asciiz "
=== PARTE 1: CONVERSÕES (DEC) ===
1) Decimal -> Binário (passo a passo)
2) Decimal -> Octal (passo a passo)
3) Decimal -> Hexadecimal (passo a passo)
4) Decimal -> BCD (4 bits por dígito)
5) Sair
Escolha uma opção (1-5): "
newline:         .asciiz "
"
step_div:        .asciiz "Passo: dividir por "
step_qr:         .asciiz "  Quociente = "
step_rem:        .asciiz "  Resto = "
result_label:    .asciiz "
Resultado: "
hexmap:          .asciiz "0123456789ABCDEF"
bcd_label:       .asciiz "
BCD (4 bits por dígito): "

.text
.globl main

# ------------------ Programa principal (Parte 1) ------------------
main:
menu_loop:
    li $v0,4; la $a0, menu_p1; syscall
    li $v0,5; syscall
    move $t9, $v0
    beq $t9,1, p1_bin
    beq $t9,2, p1_oct
    beq $t9,3, p1_hex
    beq $t9,4, p1_bcd
    beq $t9,5, p1_exit
    j menu_loop

# Rotina de leitura de inteiro
read_int:
    li $v0,4; la $a0, prompt_int; syscall
    li $v0,5; syscall
    move $s0, $v0
    jr $ra

# ------------------ Decimal -> Binário ------------------
# Mostra cada divisão por 2: quociente e resto; armazena restos na pilha e imprime em ordem reversa.
p1_bin:
    jal read_int
    move $t0, $s0
    li $v0,4; la $a0, result_label; syscall
    bltz $t0, p1_bin_negative
    beqz $t0, p1_bin_zero

    # reservar espaço para restos
    addi $sp,$sp,-128
    move $t2,$sp
    li $t3,0

p1_bin_loop:
    # mostrar passo
    li $v0,4; la $a0, step_div; syscall
    li $v0,1; li $a0,2; syscall
    li $v0,4; la $a0, newline; syscall

    li $t4,2; div $t0,$t4
    mflo $t5; mfhi $t6
    li $v0,4; la $a0, step_qr; syscall
    move $a0,$t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0,$t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall

    sb $t6,0($t2); addi $t2,$t2,1; addi $t3,$t3,1
    move $t0,$t5
    bnez $t0, p1_bin_loop

    # imprimir restos em ordem reversa
    li $v0,4; la $a0, result_label; syscall
    move $t2,$sp; add $t2,$t2,$t3
p1_bin_print_rev:
    subi $t2,$t2,1
    lb $t7,0($t2)
    addi $a0,$t7,48; li $v0,11; syscall
    addi $t3,$t3,-1
    bgtz $t3, p1_bin_print_rev
    addi $sp,$sp,128
    j menu_loop

p1_bin_negative:
    # imprime sinal '-' e converte com valor absoluto
    li $v0,11; li $a0,45; syscall
    neg $t0,$t0
    j p1_bin

p1_bin_zero:
    li $v0,4; la $a0, result_label; syscall
    li $v0,1; li $a0,0; syscall
    j menu_loop

# ------------------ Decimal -> Octal ------------------
p1_oct:
    jal read_int
    move $t0,$s0
    beqz $t0, p1_oct_zero
    addi $sp,$sp,-128
    move $t2,$sp; li $t3,0
p1_oct_loop:
    li $t4,8; div $t0,$t4
    mflo $t5; mfhi $t6
    li $v0,4; la $a0, step_div; syscall
    li $v0,1; li $a0,8; syscall
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, step_qr; syscall
    move $a0,$t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0,$t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall
    sb $t6,0($t2); addi $t2,$t2,1; addi $t3,$t3,1
    move $t0,$t5; bnez $t0, p1_oct_loop
    li $v0,4; la $a0, result_label; syscall
    move $t2,$sp; add $t2,$t2,$t3
p1_oct_print_rev:
    subi $t2,$t2,1; lb $t7,0($t2)
    addi $a0,$t7,48; li $v0,11; syscall
    addi $t3,$t3,-1; bgtz $t3, p1_oct_print_rev
    addi $sp,$sp,128
    j menu_loop
p1_oct_zero:
    li $v0,4; la $a0, result_label; syscall
    li $v0,1; li $a0,0; syscall
    j menu_loop

# ------------------ Decimal -> Hexadecimal ------------------
p1_hex:
    jal read_int
    move $t0,$s0
    beqz $t0, p1_hex_zero
    addi $sp,$sp,-128
    move $t2,$sp; li $t3,0
p1_hex_loop:
    li $t4,16; div $t0,$t4
    mflo $t5; mfhi $t6
    li $v0,4; la $a0, step_div; syscall
    li $v0,1; li $a0,16; syscall
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, step_qr; syscall
    move $a0,$t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0,$t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall
    sb $t6,0($t2); addi $t2,$t2,1; addi $t3,$t3,1
    move $t0,$t5; bnez $t0, p1_hex_loop
    li $v0,4; la $a0, result_label; syscall
    move $t2,$sp; add $t2,$t2,$t3
p1_hex_print_rev:
    subi $t2,$t2,1
    lb $t7,0($t2)
    la $t8, hexmap
    add $t8,$t8,$t7
    lb $t9,0($t8)
    move $a0,$t9; li $v0,11; syscall
    addi $t3,$t3,-1
    bgtz $t3, p1_hex_print_rev
    addi $sp,$sp,128
    j menu_loop
p1_hex_zero:
    li $v0,4; la $a0, result_label; syscall
    li $v0,1; li $a0,0; syscall
    j menu_loop

# ------------------ Decimal -> BCD (4 bits por dígito) ------------------
p1_bcd:
    jal read_int
    move $t0,$s0
    bltz $t0, p1_bcd_negative
    beqz $t0, p1_bcd_zero
    addi $sp,$sp,-64
    move $t2,$sp; li $t3,0
p1_bcd_loop:
    li $t4,10; div $t0,$t4
    mflo $t5; mfhi $t6
    li $v0,4; la $a0, step_qr; syscall
    move $a0,$t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0,$t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall
    sb $t6,0($t2); addi $t2,$t2,1; addi $t3,$t3,1
    move $t0,$t5; bnez $t0, p1_bcd_loop
    li $v0,4; la $a0, bcd_label; syscall
    move $t2,$sp; add $t2,$t2,$t3
p1_bcd_print_rev:
    subi $t2,$t2,1; lb $t7,0($t2)
    # imprime 4 bits do dígito (b3..b0)
    srl $t10,$t7,3; andi $t10,$t10,1; addi $a0,$t10,48; li $v0,11; syscall
    srl $t10,$t7,2; andi $t10,$t10,1; addi $a0,$t10,48; li $v0,11; syscall
    srl $t10,$t7,1; andi $t10,$t10,1; addi $a0,$t10,48; li $v0,11; syscall
    andi $t10,$t7,1; addi $a0,$t10,48; li $v0,11; syscall
    li $v0,11; li $a0,32; syscall
    addi $t3,$t3,-1; bgtz $t3, p1_bcd_print_rev
    addi $sp,$sp,64
    j menu_loop
p1_bcd_negative:
    neg $t0,$t0; li $v0,11; li $a0,45; syscall; j p1_bcd
p1_bcd_zero:
    li $v0,4; la $a0, bcd_label; syscall
    li $v0,11; li $a0,48; syscall
    li $v0,11; li $a0,48; syscall
    li $v0,11; li $a0,48; syscall
    li $v0,11; li $a0,48; syscall
    j menu_loop

p1_exit:
    li $v0,10; syscall

# Fim Parte 1
