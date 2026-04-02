extern fgets
extern printf
extern stdin

extern get_plaintext
extern get_key
extern generate_keys
extern encrypt_string
extern key_guess_loop

section .data
    prompt_plain    db  "Enter plaintext: ", 0
    prompt_key      db  "Enter 10-bit key (1s and 0s): ", 0
    fmt_plain_out   db  "Plaintext:        %s", 10, 0
    fmt_key_out     db  "Key:              %s", 10, 0
    msg_truncated   db  "Warning: key too long, truncated to 10 bits.", 10, 0
    msg_padded      db  "Warning: key too short, padded with 0s.", 10, 0
    fmt_cipher      db  "Ciphertext (hex): ", 0
    fmt_hex         db  "%02X ", 0
    fmt_newline     db  10, 0
    prompt_guess    db  "Guess the 10-bit key: ", 0
    msg_correct     db  "Correct! Decrypted: %s", 10, 0
    msg_wrong       db  "Wrong key, try again. Output: %s", 10, 0

    p10_tbl     db  2,4,1,6,3,9,0,8,7,5
    p8_tbl      db  5,2,6,3,7,4,9,8
    p4_tbl      db  1,3,2,0
    ip_tbl      db  1,5,2,0,3,7,4,6
    ip_inv_tbl  db  3,0,2,4,6,1,7,5
    ep_tbl      db  3,0,1,2,1,2,3,0

    s0_box  db  1,0,3,2, 3,2,1,0, 0,2,1,3, 3,1,3,2
    s1_box  db  0,1,2,3, 2,0,1,3, 3,0,1,0, 2,1,0,3

    KEY_LEN equ 10

section .bss
    plaintext       resb 64
    keyinput        resb 64
    keyfinal        resb 12

    bits_key        resb 10
    after_p10       resb 10
    ls_left         resb 5
    ls_right        resb 5
    ls_combined     resb 10
    k_1              resb 8
    k_2              resb 8

    blk_in          resb 8
    blk_tmp         resb 8
    blk_out         resb 8
    ep_out          resb 8
    xor_out         resb 8
    s0_in           resb 4
    s1_in           resb 4
    p4_in           resb 4
    p4_out_buf      resb 4
    fk_result       resb 8

    ciphertext      resb 64
    cipher_len      resq 1

    guess_raw       resb 64
    guess_final     resb 12
    guess_k1         resb 8
    guess_k2         resb 8
    decrypted       resb 64

global plaintext, keyinput, keyfinal, KEY_LEN
global bits_key, after_p10, ls_left, ls_right, ls_combined
global k_1, k_2
global blk_in, blk_tmp, blk_out, ep_out, xor_out
global s0_in, s1_in, p4_in, p4_out_buf, fk_result
global ciphertext, cipher_len
global guess_raw, guess_final, guess_k1, guess_k2, decrypted
global p10_tbl, p8_tbl, p4_tbl, ip_tbl, ip_inv_tbl, ep_tbl
global s0_box, s1_box
global prompt_plain, prompt_key, fmt_plain_out, fmt_key_out
global msg_truncated, msg_padded, fmt_cipher, fmt_hex, fmt_newline
global prompt_guess, msg_correct, msg_wrong

section .text
    global main

main:
    sub     rsp, 8

    call    get_plaintext
    call    get_key

    mov     rdi, fmt_plain_out
    mov     rsi, plaintext
    xor     eax, eax
    call    printf

    mov     rdi, fmt_key_out
    mov     rsi, keyfinal
    xor     eax, eax
    call    printf

    call    generate_keys
    call    encrypt_string

    mov     rdi, fmt_cipher
    xor     eax, eax
    call    printf

    mov     rbx, [cipher_len]
    xor     r12, r12
.print_loop:
    cmp     r12, rbx
    jge     .print_done
    movzx   esi, byte [ciphertext + r12]
    mov     rdi, fmt_hex
    xor     eax, eax
    call    printf
    inc     r12
    jmp     .print_loop
.print_done:
    mov     rdi, fmt_newline
    xor     eax, eax
    call    printf

    call    key_guess_loop

    add     rsp, 8
    mov     rax, 60
    xor     rdi, rdi
    syscall
