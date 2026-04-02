extern ascii_to_bits
extern apply_perm
extern copy_bytes
extern ls1_5

extern keyfinal
extern bits_key, after_p10, ls_left, ls_right, ls_combined
extern k_1, k_2
extern p10_tbl, p8_tbl

global generate_keys
global generate_keys_into

section .text

generate_keys:
    mov     rdi, keyfinal
    mov     rsi, k_1
    mov     rdx, k_2

generate_keys_into:
    push    rbx
    push    r12
    push    r13
    mov     r12, rsi
    mov     r13, rdx

    mov     rsi, bits_key
    mov     rdx, 10
    call    ascii_to_bits

    mov     rdi, bits_key
    mov     rsi, p10_tbl
    mov     rdx, after_p10
    mov     rcx, 10
    call    apply_perm

    mov     rdi, ls_left
    mov     rsi, after_p10
    mov     rdx, 5
    call    copy_bytes

    lea     rsi, [after_p10 + 5]
    mov     rdi, ls_right
    mov     rdx, 5
    call    copy_bytes

    mov     rdi, ls_left
    call    ls1_5
    mov     rdi, ls_right
    call    ls1_5

    call    .combine_and_p8
    mov     rdi, ls_combined
    mov     rsi, p8_tbl
    mov     rdx, r12
    mov     rcx, 8
    call    apply_perm

    mov     rdi, ls_left
    call    ls1_5
    mov     rdi, ls_right
    call    ls1_5

    call    .combine_and_p8
    mov     rdi, ls_combined
    mov     rsi, p8_tbl
    mov     rdx, r13
    mov     rcx, 8
    call    apply_perm

    pop     r13
    pop     r12
    pop     rbx
    ret

.combine_and_p8:
    push    rdi
    push    rsi
    push    rdx
    push    rcx
    mov     rdi, ls_combined
    mov     rsi, ls_left
    mov     rdx, 5
    call    copy_bytes
    lea     rdi, [ls_combined + 5]
    mov     rsi, ls_right
    mov     rdx, 5
    call    copy_bytes
    pop     rcx
    pop     rdx
    pop     rsi
    pop     rdi
    ret
