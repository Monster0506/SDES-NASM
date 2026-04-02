global ascii_to_bits
global apply_perm
global copy_bytes
global ls1_5
global swap8
global compare_strings

section .text

ascii_to_bits:
    xor     rcx, rcx
.loop:
    cmp     rcx, rdx
    jge     .done
    movzx   eax, byte [rdi + rcx]
    sub     al, '0'
    mov     byte [rsi + rcx], al
    inc     rcx
    jmp     .loop
.done:
    ret

apply_perm:
    push    rbx
    push    r12
    push    r13
    push    r14
    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx
    xor     rbx, rbx
.loop:
    cmp     rbx, rcx
    jge     .done
    movzx   eax, byte [r13 + rbx]
    movzx   eax, byte [r12 + rax]
    mov     byte [r14 + rbx], al
    inc     rbx
    jmp     .loop
.done:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

copy_bytes:
    xor     rcx, rcx
.loop:
    cmp     rcx, rdx
    jge     .done
    movzx   eax, byte [rsi + rcx]
    mov     byte [rdi + rcx], al
    inc     rcx
    jmp     .loop
.done:
    ret

ls1_5:
    movzx   eax, byte [rdi]
    movzx   edx, byte [rdi + 1]
    mov     byte [rdi], dl
    movzx   edx, byte [rdi + 2]
    mov     byte [rdi + 1], dl
    movzx   edx, byte [rdi + 3]
    mov     byte [rdi + 2], dl
    movzx   edx, byte [rdi + 4]
    mov     byte [rdi + 3], dl
    mov     byte [rdi + 4], al
    ret

swap8:
    push    rbx
    movzx   eax,  byte [rdi]
    movzx   ecx,  byte [rdi + 1]
    movzx   edx,  byte [rdi + 2]
    movzx   r8d,  byte [rdi + 3]
    movzx   r9d,  byte [rdi + 4]
    movzx   r10d, byte [rdi + 5]
    movzx   r11d, byte [rdi + 6]
    movzx   ebx,  byte [rdi + 7]
    mov     byte [rdi],     r9b
    mov     byte [rdi + 1], r10b
    mov     byte [rdi + 2], r11b
    mov     byte [rdi + 3], bl
    mov     byte [rdi + 4], al
    mov     byte [rdi + 5], cl
    mov     byte [rdi + 6], dl
    mov     byte [rdi + 7], r8b
    pop     rbx
    ret

compare_strings:
    push    rbx
    push    r12
    mov     rbx, rdi
    mov     r12, rsi
    xor     rcx, rcx
.loop:
    movzx   eax, byte [rbx + rcx]
    movzx   edx, byte [r12 + rcx]
    cmp     al, dl
    jne     .not_equal
    test    al, al
    jz      .equal
    inc     rcx
    jmp     .loop
.equal:
    cmp     eax, eax
    pop     r12
    pop     rbx
    ret
.not_equal:
    cmp     eax, edx
    pop     r12
    pop     rbx
    ret
