extern apply_perm
extern copy_bytes
extern swap8
extern compare_strings
extern generate_keys_into
extern filter_bits
extern pad_key
extern prompt_and_read
extern printf

extern plaintext, ciphertext, cipher_len, decrypted
extern k_1, k_2, guess_k1, guess_k2
extern guess_raw, guess_final
extern blk_in, blk_tmp, blk_out
extern ep_out, xor_out, p4_in, p4_out_buf, fk_result
extern ip_tbl, ip_inv_tbl, ep_tbl, p4_tbl
extern s0_box, s1_box
extern prompt_guess, msg_correct, msg_wrong

%define KEY_LEN 10

global sbox_lookup
global fk_func
global sdes_process_byte
global encrypt_string
global decrypt_string
global key_guess_loop

section .text

sbox_lookup:
    movzx   eax, byte [rdi]
    add     eax, eax
    movzx   ecx, byte [rdi + 3]
    add     eax, ecx
    movzx   ecx, byte [rdi + 1]
    add     ecx, ecx
    movzx   r8d, byte [rdi + 2]
    add     ecx, r8d
    imul    eax, eax, 4
    add     eax, ecx
    movzx   eax, byte [rsi + rax]
    mov     ecx, eax
    shr     ecx, 1
    and     ecx, 1
    mov     byte [rdx], cl
    and     eax, 1
    mov     byte [rdx + 1], al
    ret

fk_func:
    push    rbx
    push    r12
    push    r13
    push    r14
    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx

    lea     rdi, [r12 + 4]
    mov     rsi, ep_tbl
    mov     rdx, ep_out
    mov     rcx, 8
    call    apply_perm

    xor     rbx, rbx
.xor_loop:
    cmp     rbx, 8
    jge     .xor_done
    movzx   eax, byte [ep_out + rbx]
    movzx   ecx, byte [r13 + rbx]
    xor     eax, ecx
    mov     byte [xor_out + rbx], al
    inc     rbx
    jmp     .xor_loop
.xor_done:

    mov     rdi, xor_out
    mov     rsi, s0_box
    mov     rdx, p4_in
    call    sbox_lookup

    lea     rdi, [xor_out + 4]
    mov     rsi, s1_box
    lea     rdx, [p4_in + 2]
    call    sbox_lookup

    mov     rdi, p4_in
    mov     rsi, p4_tbl
    mov     rdx, p4_out_buf
    mov     rcx, 4
    call    apply_perm

    xor     rbx, rbx
.xor_l:
    cmp     rbx, 4
    jge     .copy_r
    movzx   eax, byte [r12 + rbx]
    movzx   ecx, byte [p4_out_buf + rbx]
    xor     eax, ecx
    mov     byte [r14 + rbx], al
    inc     rbx
    jmp     .xor_l
.copy_r:
    xor     rbx, rbx
.copy_r_loop:
    cmp     rbx, 4
    jge     .fk_done
    movzx   eax, byte [r12 + rbx + 4]
    mov     byte [r14 + rbx + 4], al
    inc     rbx
    jmp     .copy_r_loop
.fk_done:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

sdes_process_byte:
    push    rbx
    push    r12
    push    r13
    movzx   ebx, dil
    mov     r12, rsi
    mov     r13, rdx

    xor     rcx, rcx
.expand:
    cmp     rcx, 8
    jge     .expand_done
    mov     eax, ebx
    mov     edx, 7
    sub     edx, ecx
    xchg    ecx, edx
    shr     eax, cl
    xchg    ecx, edx
    and     eax, 1
    mov     byte [blk_in + rcx], al
    inc     rcx
    jmp     .expand
.expand_done:

    mov     rdi, blk_in
    mov     rsi, ip_tbl
    mov     rdx, blk_tmp
    mov     rcx, 8
    call    apply_perm

    mov     rdi, blk_tmp
    mov     rsi, r12
    mov     rdx, fk_result
    call    fk_func

    mov     rdi, fk_result
    call    swap8

    mov     rdi, fk_result
    mov     rsi, r13
    mov     rdx, blk_tmp
    call    fk_func

    mov     rdi, blk_tmp
    mov     rsi, ip_inv_tbl
    mov     rdx, blk_out
    mov     rcx, 8
    call    apply_perm

    xor     eax, eax
    xor     rcx, rcx
.collapse:
    cmp     rcx, 8
    jge     .collapse_done
    shl     eax, 1
    movzx   edx, byte [blk_out + rcx]
    or      eax, edx
    inc     rcx
    jmp     .collapse
.collapse_done:
    pop     r13
    pop     r12
    pop     rbx
    ret

encrypt_string:
    push    rbx
    push    r12
    mov     rdi, plaintext
    call    strlen_local
    mov     r12, rax
    xor     rbx, rbx
.loop:
    cmp     rbx, r12
    jge     .done
    movzx   edi, byte [plaintext + rbx]
    mov     rsi, k_1
    mov     rdx, k_2
    call    sdes_process_byte
    mov     byte [ciphertext + rbx], al
    inc     rbx
    jmp     .loop
.done:
    mov     [cipher_len], r12
    pop     r12
    pop     rbx
    ret

decrypt_string:
    push    rbx
    push    r12
    mov     r12, [cipher_len]
    xor     rbx, rbx
.loop:
    cmp     rbx, r12
    jge     .done
    movzx   edi, byte [ciphertext + rbx]
    mov     rsi, guess_k2
    mov     rdx, guess_k1
    call    sdes_process_byte
    mov     byte [decrypted + rbx], al
    inc     rbx
    jmp     .loop
.done:
    mov     byte [decrypted + r12], 0
    pop     r12
    pop     rbx
    ret

key_guess_loop:
    push    rbx
.loop:
    mov     rdi, prompt_guess
    mov     rsi, guess_raw
    mov     rdx, 64
    call    prompt_and_read

    mov     rdi, guess_raw
    mov     rsi, guess_final
    mov     rdx, KEY_LEN
    call    filter_bits
    mov     rbx, rax

    cmp     rbx, KEY_LEN
    jge     .no_pad
    mov     rdi, guess_final
    mov     rsi, rbx
    mov     rdx, KEY_LEN
    call    pad_key
.no_pad:
    mov     byte [guess_final + KEY_LEN], 0

    mov     rdi, guess_final
    mov     rsi, guess_k1
    mov     rdx, guess_k2
    call    generate_keys_into

    call    decrypt_string

    mov     rdi, decrypted
    mov     rsi, plaintext
    call    compare_strings
    jne     .wrong

    mov     rdi, msg_correct
    mov     rsi, decrypted
    xor     eax, eax
    call    printf
    jmp     .exit
.wrong:
    mov     rdi, msg_wrong
    mov     rsi, decrypted
    xor     eax, eax
    call    printf
    jmp     .loop
.exit:
    pop     rbx
    ret

strlen_local:
    xor     rax, rax
.sl_loop:
    cmp     byte [rdi + rax], 0
    je      .sl_done
    inc     rax
    jmp     .sl_loop
.sl_done:
    ret
