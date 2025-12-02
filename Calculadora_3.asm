.data
# Parte 3 — Conversões de reais: analisar float (32-bit) e double (64-bit)
# Arquivo: Calculadora_Parte3.asm
# Descrição: Lê um float ou double e mostra os bits de sinal, expoente (com viés
# e sem viés) e a fração (mantissa). Comentários em português. Recomendado MARS.

prompt_float:    .asciiz "\nDigite um número real (float) e pressione Enter: "
prompt_double:   .asciiz "\nDigite um número real (double) e pressione Enter: "
menu_p3:         .asciiz "\n=== PARTE 3: REAL -> FLOAT/DOUBLE (IEEE-754) ===\n1) Float (32 bits)\n2) Double (64 bits)\n3) Sair\nEscolha (1-3): "
newline:         .asciiz "\n"
float_label:     .asciiz "\n--- FLOAT (32 bits) ---\n"
double_label:    .asciiz "\n--- DOUBLE (64 bits) ---\n"
bits32_label:    .asciiz "Bits (32): "
bits64_label:    .asciiz "Bits (64): "
sign_label:      .asciiz "Sinal: "
exp_label:       .asciiz "Expoente (com viés): "
exp_unbias:      .asciiz "Expoente (sem viés): "
mant_label:      .asciiz "Fração (mantissa) bits: "

.text
.globl main

main:
menu_loop:
    li $v0,4; la $a0, menu_p3; syscall
    li $v0,5; syscall
    move $t9,$v0
    beq $t9,1, p3_float
    beq $t9,2, p3_double
    beq $t9,3, p3_exit
    j menu_loop

# ------------------ Float 32-bit ------------------
# Lê float em $f0 (syscall 6), move bits com mfc1 e imprime detalhadamente.
p3_float:
    li $v0,4; la $a0, prompt_float; syscall
    li $v0,6; syscall    # lê float em $f0
    mfc1 $t0, $f0        # move representação IEEE-754 para $t0

    li $v0,4; la $a0, float_label; syscall
    li $v0,4; la $a0, bits32_label; syscall

    # imprimir 32 bits (MSB..LSB)
    move $t1,$t0; li $t2,31
p3_print32:
    srl $t3,$t1,31; andi $t3,$t3,1
    addi $a0,$t3,48; li $v0,11; syscall
    sll $t1,$t1,1; addi $t2,$t2,-1
    bgez $t2, p3_print32

    # extrair sinal, expoente, mantissa
    srl $t4,$t0,31; andi $t4,$t4,1
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, sign_label; syscall
    addi $a0,$t4,48; li $v0,11; syscall

    srl $t5,$t0,23; andi $t5,$t5,0xFF
    li $v0,4; la $a0, exp_label; syscall
    move $a0,$t5; li $v0,1; syscall

    addi $t6,$t5,-127
    li $v0,4; la $a0, exp_unbias; syscall
    move $a0,$t6; li $v0,1; syscall

    andi $t7,$t0,0x7FFFFF
    li $v0,4; la $a0, mant_label; syscall
    li $t8,22
p3_print_mant:
    srl $t9,$t7,$t8; andi $t9,$t9,1
    addi $a0,$t9,48; li $v0,11; syscall
    addi $t8,$t8,-1; bgez $t8, p3_print_mant
    j menu_loop

# ------------------ Double 64-bit ------------------
# Lê double (syscall 7) em $f0/$f1, move palavras com mfc1 e mostra bits.
p3_double:
    li $v0,4; la $a0, prompt_double; syscall
    li $v0,7; syscall    # lê double em $f0/$f1
    mfc1 $t0,$f0   # palavra baixa (bits 31..0)
    mfc1 $t1,$f1   # palavra alta  (bits 63..32)

    li $v0,4; la $a0, double_label; syscall
    li $v0,4; la $a0, bits64_label; syscall

    # imprimir 32 bits da palavra alta
    move $t2,$t1; li $t3,31
p3_print_high:
    srl $t4,$t2,31; andi $t4,$t4,1
    addi $a0,$t4,48; li $v0,11; syscall
    sll $t2,$t2,1; addi $t3,$t3,-1
    bgez $t3, p3_print_high

    # imprimir 32 bits da palavra baixa
    move $t2,$t0; li $t3,31
p3_print_low:
    srl $t4,$t2,31; andi $t4,$t4,1
    addi $a0,$t4,48; li $v0,11; syscall
    sll $t2,$t2,1; addi $t3,$t3,-1
    bgez $t3, p3_print_low

    # extrair sinal (bit 63)
    srl $t5,$t1,31; andi $t5,$t5,1
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, sign_label; syscall
    addi $a0,$t5,48; li $v0,11; syscall

    # extrair expoente (11 bits): bits 62..52 => deslocar 20
    srl $t6,$t1,20; andi $t6,$t6,0x7FF
    li $v0,4; la $a0, exp_label; syscall
    move $a0,$t6; li $v0,1; syscall

    addi $t7,$t6,-1023
    li $v0,4; la $a0, exp_unbias; syscall
    move $a0,$t7; li $v0,1; syscall

    # mantissa: 52 bits = 20 bits da palavra alta (lower 20) + 32 bits da palavra baixa
    andi $t8,$t1,0xFFFFF    # 20 bits superiores da mantissa
    li $v0,4; la $a0, mant_label; syscall

    # imprimir 20 bits da parte alta da mantissa
    li $t9,19
p3_print_mant_high:
    srl $s0,$t8,$t9; andi $s0,$s0,1
    addi $a0,$s0,48; li $v0,11; syscall
    addi $t9,$t9,-1; bgez $t9, p3_print_mant_high

    # imprimir 32 bits da palavra baixa (parte baixa da mantissa)
    move $s1,$t0; li $s2,31
p3_print_mant_low:
    srl $s3,$s1,31; andi $s3,$s3,1
    addi $a0,$s3,48; li $v0,11; syscall
    sll $s1,$s1,1; addi $s2,$s2,-1
    bgez $s2, p3_print_mant_low

    j menu_loop

p3_exit:
    li $v0,10; syscall

# Fim Parte 3
