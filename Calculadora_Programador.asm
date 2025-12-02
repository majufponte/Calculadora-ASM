.data
# Mensagens e textos em português mostrados ao usuário
prompt_int:      .asciiz "
Digite um inteiro (base 10) e pressione Enter: "
prompt_float:    .asciiz "
Digite um número real (float) e pressione Enter: "
prompt_double:   .asciiz "
Digite um número real (double) e pressione Enter: "
menu:            .asciiz "
=== CALCULADORA PROGRAMADOR (MIPS - didática) ===
1) Converter inteiro (dec) para binário (mostrando passos)
2) Converter inteiro (dec) para octal (mostrando passos)
3) Converter inteiro (dec) para hexadecimal (mostrando passos)
4) Converter inteiro (dec) para BCD (4 bits por dígito)
5) Converter inteiro (dec) para complemento de 2 (16 bits)
6) Converter real -> float IEEE-754 (mostrar sinal/expoente(viés)/fração)
7) Converter real -> double IEEE-754 (mostrar sinal/expoente(viés)/fração)
8) Sair
Escolha uma opção (1-8): "
newline:         .asciiz "
"
step_div:        .asciiz "Passo: dividir por "
step_qr:         .asciiz "  Quociente = "
step_rem:        .asciiz "  Resto = "
result_label:    .asciiz "
Resultado: "
bcd_label:       .asciiz "
BCD (4 bits por dígito): "
twos_label:      .asciiz "
Complemento de 2 (16 bits): "
float_label:     .asciiz "
--- FLOAT (32 bits) ---
"
double_label:    .asciiz "
--- DOUBLE (64 bits) ---
"
sign_label:      .asciiz "Sinal: "
exp_label:       .asciiz "Expoente (com viés): "
exp_unbias:      .asciiz "Expoente (sem viés): "
mant_label:      .asciiz "Fração (mantissa) bits: "
bits32_label:    .asciiz "Bits (32): "
bits64_label:    .asciiz "Bits (64): "
hexmap:          .asciiz "0123456789ABCDEF"

.text
.globl main

# -----------------------------------------------------------------
# Programa: Calculadora Programador (MIPS)
# Objetivo: Fazer conversões didáticas e mostrar passo a passo no console
# Observações: Comentários e mensagens estão em português para didática.
# Recomendado: usar o simulador MARS (syscalls compatíveis).
# -----------------------------------------------------------------

main:
    # Loop principal que exibe o menu e lê a opção do usuário
menu_loop:
    li $v0, 4
    la $a0, menu
    syscall

    # Ler opção (inteiro)
    li $v0, 5
    syscall
    move $t9, $v0    # salva opção em $t9

    # Saltos para rotinas de acordo com a opção
    beq $t9, 1, do_bin
    beq $t9, 2, do_oct
    beq $t9, 3, do_hex
    beq $t9, 4, do_bcd
    beq $t9, 5, do_twos
    beq $t9, 6, do_float
    beq $t9, 7, do_double
    beq $t9, 8, exit_prog
    j menu_loop

# ------------------------- Rotina de leitura de inteiro -------------------------
# read_int: imprime mensagem e lê um inteiro (syscall 5). Resultado em $s0.
read_int:
    li $v0, 4
    la $a0, prompt_int
    syscall
    li $v0, 5
    syscall
    move $s0, $v0    # armazena inteiro em $s0 para uso posterior
    jr $ra

# ------------------------- Rotinas auxiliares de impressão -------------------------
# Estas rotinas ajudam a manter o código organizado — usam syscalls do MARS.
print_newline:
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra

print_string:
    # espera $a0 -> endereço da string
    li $v0, 4
    syscall
    jr $ra

print_int_reg:
    # espera inteiro em $a0
    move $v0, $a0
    li $v0, 1
    syscall
    jr $ra

print_char_reg:
    # espera código ASCII em $a0 (caractere único)
    li $v0, 11
    syscall
    jr $ra

# ------------------------- Conversão DEC -> BINÁRIO (passo a passo) -------------------------
# Estratégia didática:
# 1) Mostrar cada passo da divisão sucessiva por 2 (quociente e resto).
# 2) Armazenar restos na pilha para imprimir em ordem reversa (MSB..LSB).
# 3) Tratar número negativo imprimindo '-' e convertendo o valor absoluto.

do_bin:
    jal read_int            # lê inteiro e guarda em $s0
    move $t0, $s0          # copia valor para $t0 (trabalho)

    # Rotina de impressão inicial
    li $v0,4; la $a0, result_label; syscall

    # Se negativo: imprime '-' e passa a trabalhar com o absoluto
    bltz $t0, bin_negative
    j bin_positive

bin_negative:
    # Mostra indicação de negativo
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, bits32_label; syscall
    # imprime '-' (ASCII 45)
    li $v0,11; li $a0,45; syscall
    neg $t1, $t0
    move $t0, $t1
    j bin_positive

bin_positive:
    # Se o número for zero, imprime 0 e retorna ao menu
    beqz $t0, bin_print_zero

    # Reservar espaço na pilha para guardar restos (remoções)
    addi $sp, $sp, -128
    move $t2, $sp    # ponteiro para onde armazenar restos
    li $t3, 0        # contador de restos

bin_loop:
    # Mostrar passo (didático): dividir por 2
    li $v0,4; la $a0, step_div; syscall
    li $v0,1; li $a0,2; syscall
    li $v0,4; la $a0, newline; syscall

    # Divisão inteira por 2: usa instrução div, depois mflo/mfhi
    li $t4, 2
    div $t0, $t4
    mflo $t5    # quociente
    mfhi $t6    # resto (0 ou 1)

    # Imprime quociente e resto (passo a passo)
    li $v0,4; la $a0, step_qr; syscall
    move $a0, $t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0, $t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall

    # Armazena o resto (um byte) na pilha
    sb $t6, 0($t2)
    addi $t2, $t2, 1
    addi $t3, $t3, 1

    # Atualiza t0 com o quociente e repete até quociente=0
    move $t0, $t5
    bnez $t0, bin_loop

    # Agora imprime os restos em ordem inversa (do último resto ao primeiro)
    li $v0,4; la $a0, result_label; syscall
    move $t2, $sp
    add $t2, $t2, $t3

print_rev_bin:
    subi $t2, $t2, 1
    lb $t7, 0($t2)
    move $a0, $t7; li $v0,11; syscall    # imprime '0' ou '1' como caractere
    addi $t3, $t3, -1
    bgtz $t3, print_rev_bin

    # Restaurar ponteiro da pilha
    addi $sp, $sp, 128
    j menu_loop

bin_print_zero:
    li $v0,4; la $a0, result_label; syscall
    li $v0,1; li $a0,0; syscall
    j menu_loop

# ------------------------- Conversão DEC -> OCTAL (passo a passo) -------------------------
# Mesma estratégia: divisões sucessivas por 8, imprimir quociente/resto e reverter restos.

do_oct:
    jal read_int
    move $t0, $s0
    beqz $t0, oct_zero

    addi $sp, $sp, -128
    move $t2, $sp
    li $t3,0

oct_loop:
    li $t4,8
    div $t0,$t4
    mflo $t5
    mfhi $t6

    # Impressão didática do passo (divisão por 8)
    li $v0,4; la $a0, step_div; syscall
    li $v0,1; li $a0,8; syscall
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, step_qr; syscall
    move $a0,$t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0,$t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall

    sb $t6,0($t2)
    addi $t2,$t2,1
    addi $t3,$t3,1
    move $t0,$t5
    bnez $t0, oct_loop

    # Imprime resultado (restos em ordem inversa)
    li $v0,4; la $a0, result_label; syscall
    move $t2,$sp
    add $t2,$t2,$t3

print_rev_oct:
    subi $t2,$t2,1
    lb $t7,0($t2)
    move $a0,$t7; li $v0,11; syscall
    addi $t3,$t3,-1
    bgtz $t3, print_rev_oct

    addi $sp,$sp,128
    j menu_loop

oct_zero:
    li $v0,4; la $a0, result_label; syscall
    li $v0,1; li $a0,0; syscall
    j menu_loop

# ------------------------- Conversão DEC -> HEXADECIMAL (passo a passo) -------------------------
# Utiliza divisão por 16 e mapeia restos 10..15 para A..F via tabela hexmap.

do_hex:
    jal read_int
    move $t0, $s0
    beqz $t0, hex_zero

    addi $sp,$sp,-128
    move $t2,$sp
    li $t3,0

hex_loop:
    li $t4,16
    div $t0,$t4
    mflo $t5
    mfhi $t6

    # Impressão didática do passo (dividir por 16)
    li $v0,4; la $a0, step_div; syscall
    li $v0,1; li $a0,16; syscall
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, step_qr; syscall
    move $a0,$t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0,$t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall

    sb $t6,0($t2)
    addi $t2,$t2,1
    addi $t3,$t3,1
    move $t0,$t5
    bnez $t0, hex_loop

    # Imprime resultado mapeando 10..15 para A..F usando hexmap
    li $v0,4; la $a0, result_label; syscall
    move $t2,$sp
    add $t2,$t2,$t3

print_rev_hex:
    subi $t2,$t2,1
    lb $t7,0($t2)
    la $t8, hexmap
    add $t8, $t8, $t7   # desloca para o caractere correto
    lb $t9, 0($t8)
    move $a0, $t9; li $v0,11; syscall
    addi $t3,$t3,-1
    bgtz $t3, print_rev_hex

    addi $sp,$sp,128
    j menu_loop

hex_zero:
    li $v0,4; la $a0, result_label; syscall
    li $v0,1; li $a0,0; syscall
    j menu_loop

# ------------------------- Conversão DEC -> BCD (4 bits por dígito) -------------------------
# Estratégia didática:
# 1) Extrair dígitos decimais por divisões sucessivas por 10 (mostrar passos).
# 2) Para cada dígito (0..9), imprimir os 4 bits correspondentes (b3 b2 b1 b0).

do_bcd:
    jal read_int
    move $t0, $s0

    # Se negativo: imprime '-' e trabalha com o absoluto
    bltz $t0, bcd_negative
    j bcd_positive

bcd_negative:
    neg $t0, $t0
    li $v0,11; li $a0,45; syscall    # imprime '-'
    j bcd_positive

bcd_positive:
    # Prepara pilha para armazenar os dígitos extraídos (LSB primeiro)
    addi $sp,$sp,-64
    move $t2,$sp
    li $t3,0
    beqz $t0, bcd_zero

bcd_loop:
    li $t4,10
    div $t0,$t4
    mflo $t5
    mfhi $t6    # dígito (0..9)

    # Imprime passo: quociente e resto
    li $v0,4; la $a0, step_qr; syscall
    move $a0,$t5; li $v0,1; syscall
    li $v0,4; la $a0, step_rem; syscall
    move $a0,$t6; li $v0,1; syscall
    li $v0,4; la $a0, newline; syscall

    # Armazena dígito
    sb $t6,0($t2)
    addi $t2,$t2,1
    addi $t3,$t3,1
    move $t0,$t5
    bnez $t0, bcd_loop

    # Imprime etiqueta BCD
    li $v0,4; la $a0, bcd_label; syscall

    # Percorre dígitos em ordem reversa e imprime 4 bits por dígito
    move $t2,$sp
    add $t2,$t2,$t3

print_bcd_rev:
    subi $t2,$t2,1
    lb $t7,0($t2)

    # Para cada bit (b3..b0) usamos shift constante para extrair
    # bit 3
    srl $t10,$t7,3
    andi $t10,$t10,1
    addi $a0,$t10,48
    li $v0,11; syscall
    # bit 2
    srl $t10,$t7,2
    andi $t10,$t10,1
    addi $a0,$t10,48
    li $v0,11; syscall
    # bit 1
    srl $t10,$t7,1
    andi $t10,$t10,1
    addi $a0,$t10,48
    li $v0,11; syscall
    # bit 0
    andi $t10,$t7,1
    addi $a0,$t10,48
    li $v0,11; syscall

    # espaço separador entre dígitos
    li $v0,11; li $a0,32; syscall

    addi $t3,$t3,-1
    bgtz $t3, print_bcd_rev

    addi $sp,$sp,64
    j menu_loop

bcd_zero:
    li $v0,4; la $a0, bcd_label; syscall
    # imprime 0000 para zero
    li $v0,11; li $a0,48; syscall
    li $v0,11; li $a0,48; syscall
    li $v0,11; li $a0,48; syscall
    li $v0,11; li $a0,48; syscall
    j menu_loop

# ------------------------- Conversão DEC -> Complemento de 2 (16 bits) -------------------------
# Estratégia:
# - Para números positivos: mostrar os 16 bits diretamente (com padding)
# - Para números negativos: mostrar passo invertendo bits e somando 1 (invert+1)

do_twos:
    jal read_int
    move $t0, $s0

    # Imprime etiqueta
    li $v0,4; la $a0, twos_label; syscall

    # Mascara para 16 bits
    li $t1, 0xFFFF
    and $t2, $t0, $t1    # agora t2 tem apenas os 16 bits relevantes

    # Se negativo: mostrar o passo invert+1
    bltz $t0, twos_negative_step
    j twos_print

twos_negative_step:
    # Inverte bits (XOR com 0xFFFF) - este é o passo 'inverter bits'
    xori $t3, $t2, 0xFFFF

    # Mostra o resultado da inversão (didático)
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, step_qr; syscall
    move $a0, $t3; li $v0,1; syscall

    # Soma 1 (passo final do complemento de 2)
    addi $t4, $t3, 1
    move $t2, $t4

twos_print:
    # Imprime 16 bits de t2 do MSB para LSB
    li $t5,15
print_twos_loop:
    srl $t6, $t2, 15
    andi $t6, $t6,1
    addi $a0,$t6,48
    li $v0,11; syscall
    sll $t2, $t2,1
    subi $t5,$t5,1
    bgez $t5, print_twos_loop
    j menu_loop

# ------------------------- Conversão REAL -> FLOAT (IEEE-754 32 bits) -------------------------
# Estratégia didática:
# 1) Ler float (syscall 6) para registrador $f0.
# 2) Mover os bits para inteiro ($t0) com mfc1 para analisá-los.
# 3) Mostrar os 32 bits, extrair sinal, expoente (com e sem viés) e mantissa.

do_float:
    li $v0,4; la $a0, prompt_float; syscall
    li $v0,6
    syscall            # lê float em $f0

    # Passar os bits do $f0 para $t0 (representação IEEE-754)
    mfc1 $t0, $f0

    # Cabeçalho informativo
    li $v0,4; la $a0, float_label; syscall
    li $v0,4; la $a0, bits32_label; syscall

    # Imprime os 32 bits do valor (do MSB ao LSB)
    move $t1, $t0
    li $t2,31
print32_loop:
    srl $t3, $t1, 31
    andi $t3, $t3,1
    addi $a0,$t3,48
    li $v0,11; syscall
    sll $t1,$t1,1
    addi $t2,$t2,-1
    bgez $t2, print32_loop

    # Extrai o bit de sinal (bit 31)
    srl $t4, $t0,31
    andi $t4,$t4,1
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, sign_label; syscall
    addi $a0,$t4,48; li $v0,11; syscall

    # Extrai expoente (8 bits) — bits 30..23
    srl $t5,$t0,23
    andi $t5,$t5,0xFF
    li $v0,4; la $a0, exp_label; syscall
    move $a0,$t5; li $v0,1; syscall

    # Calcula expoente sem viés (subtrai 127)
    addi $t6, $t5, -127
    li $v0,4; la $a0, exp_unbias; syscall
    move $a0,$t6; li $v0,1; syscall

    # Extrai mantissa (23 bits) — bits 22..0
    andi $t7, $t0, 0x7FFFFF
    li $v0,4; la $a0, mant_label; syscall

    # Imprime os 23 bits da mantissa (b0..b22)
    li $t8,22
print_mant_loop:
    srl $t9, $t7, $t8
    andi $t9,$t9,1
    addi $a0,$t9,48
    li $v0,11; syscall
    addi $t8,$t8,-1
    bgez $t8, print_mant_loop
    j menu_loop

# ------------------------- Conversão REAL -> DOUBLE (IEEE-754 64 bits) -------------------------
# Estratégia:
# 1) Ler double (syscall 7) em $f0/$f1 (MARS guarda em par de registradores).
# 2) Mover as palavras para inteiros: low-> $t0, high-> $t1 (mfc1).
# 3) Imprimir os 64 bits e extrair sinal, expoente (com e sem viés) e mantissa (52 bits).

#do_double:
    do_double:
    li $v0,4; la $a0, prompt_double; syscall
    li $v0,7
    syscall            # lê double em $f0/$f1

    # MARS: $f0 contém a parte baixa (low word), $f1 a parte alta (high word)
    mfc1 $t0, $f0   # palavra baixa (bits 31..0)
    mfc1 $t1, $f1   # palavra alta  (bits 63..32)

    # Cabeçalho informativo
    li $v0,4; la $a0, double_label; syscall
    li $v0,4; la $a0, bits64_label; syscall

    # Imprime 32 bits da palavra alta (MSB primeiro)
    move $t2, $t1
    li $t3,31
print_high_loop:
    srl $t4, $t2,31
    andi $t4,$t4,1
    addi $a0,$t4,48
    li $v0,11; syscall
    sll $t2,$t2,1
    addi $t3,$t3,-1
    bgez $t3, print_high_loop

    # Imprime 32 bits da palavra baixa
    move $t2, $t0
    li $t3,31
print_low_loop:
    srl $t4,$t2,31
    andi $t4,$t4,1
    addi $a0,$t4,48
    li $v0,11; syscall
    sll $t2,$t2,1
    addi $t3,$t3,-1
    bgez $t3, print_low_loop

    # Extrai sinal (bit 63, ou bit 31 da palavra alta)
    srl $t5, $t1,31
    andi $t5,$t5,1
    li $v0,4; la $a0, newline; syscall
    li $v0,4; la $a0, sign_label; syscall
    addi $a0,$t5,48; li $v0,11; syscall

    # Extrai expoente (11 bits): bits 62..52 -> são bits 20..30 da palavra alta
    srl $t6, $t1,20
    andi $t6,$t6,0x7FF
    li $v0,4; la $a0, exp_label; syscall
    move $a0,$t6; li $v0,1; syscall

    # Expoente sem viés (subtrai 1023)
    addi $t7,$t6,-1023
    li $v0,4; la $a0, exp_unbias; syscall
    move $a0,$t7; li $v0,1; syscall

    # Mantissa: 52 bits = 20 bits baixos da palavra alta + 32 bits da palavra baixa
    andi $t8,$t1,0xFFFFF   # extrai os 20 bits altos da mantissa
    li $v0,4; la $a0, mant_label; syscall

    # Imprime os 20 bits da parte alta da mantissa
    li $t9,19
print_mant_high:
    srl $s0,$t8,$t9
    andi $s0,$s0,1
    addi $a0,$s0,48; li $v0,11; syscall
    addi $t9,$t9,-1
    bgez $t9, print_mant_high

    # Em seguida, imprime os 32 bits da palavra baixa (parte baixa da mantissa)
    move $s1,$t0
    li $s2,31
print_mant_low:
    srl $s3,$s1,31
    andi $s3,$s3,1
    addi $a0,$s3,48; li $v0,11; syscall
    sll $s1,$s1,1
    addi $s2,$s2,-1
    bgez $s2, print_mant_low

    j menu_loop

# ------------------------- Finalização -------------------------
exit_prog:
    li $v0,10
    syscall

# Fim do arquivo
