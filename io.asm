extern fgets
extern printf
extern strlen
extern stdin

extern plaintext, keyinput, keyfinal
extern prompt_plain, prompt_key
extern fmt_plain_out, fmt_key_out
extern msg_truncated, msg_padded


%define KEY_LEN 10

global read_line
global prompt_and_read
global get_plaintext
global get_key
global strip_newline
global count_valid_bits
global filter_bits
global pad_key

section .text

read_line:
    push    rbx
    mov     rbx, rdi
    mov     rdx, [stdin]
    call    fgets
    mov     rdi, rbx
    call    strip_newline
    pop     rbx
    ret

prompt_and_read:
    push    rbx
    push    r12
    push    r13
    mov     r12, rsi
    mov     r13, rdx
    xor     eax, eax
    call    printf
    mov     rdi, r12
    mov     rsi, r13
    call    read_line
    pop     r13
    pop     r12
    pop     rbx
    ret

strip_newline:
    xor     rcx, rcx
.loop:
    movzx   eax, byte [rdi + rcx]
    test    al, al
    jz      .done
    cmp     al, 10
    je      .replace
    inc     rcx
    jmp     .loop
.replace:
    mov     byte [rdi + rcx], 0
.done:
    ret

count_valid_bits:
    push    rbx
    mov     rbx, rdi
    call    strlen
    mov     rcx, rax
    xor     rax, rax
    xor     rdx, rdx
.loop:
    cmp     rdx, rcx
    jge     .done
    movzx   r8d, byte [rbx + rdx]
    inc     rdx
    cmp     r8b, '0'
    je      .hit
    cmp     r8b, '1'
    jne     .loop
.hit:
    inc     rax
    jmp     .loop
.done:
    pop     rbx
    ret

filter_bits:
    push    rbx
    push    r12
    push    r13
    mov     rbx, rdi
    mov     r12, rsi
    mov     r13, rdx
    mov     rdi, rbx
    call    strlen
    mov     rcx, rax
    xor     rsi, rsi
    xor     rdx, rdx
.loop:
    cmp     rsi, rcx
    jge     .done
    cmp     rdx, r13
    jge     .done
    movzx   eax, byte [rbx + rsi]
    inc     rsi
    cmp     al, '0'
    je      .copy
    cmp     al, '1'
    jne     .loop
.copy:
    mov     byte [r12 + rdx], al
    inc     rdx
    jmp     .loop
.done:
    mov     rax, rdx
    pop     r13
    pop     r12
    pop     rbx
    ret

pad_key:
    mov     rcx, rsi
.loop:
    cmp     rcx, rdx
    jge     .done
    mov     byte [rdi + rcx], '0'
    inc     rcx
    jmp     .loop
.done:
    ret

get_plaintext:
    mov     rdi, prompt_plain
    mov     rsi, plaintext
    mov     rdx, 64
    jmp     prompt_and_read

get_key:
    push    rbx
    mov     rdi, prompt_key
    mov     rsi, keyinput
    mov     rdx, 64
    call    prompt_and_read
    mov     rdi, keyinput
    mov     rsi, keyfinal
    mov     rdx, KEY_LEN
    call    filter_bits
    mov     rbx, rax
    cmp     rbx, KEY_LEN
    jl      .do_pad
    mov     rdi, keyinput
    call    count_valid_bits
    cmp     rax, KEY_LEN
    jle     .finalize
    mov     rdi, msg_truncated
    xor     eax, eax
    call    printf
    jmp     .finalize
.do_pad:
    mov     rdi, msg_padded
    xor     eax, eax
    call    printf
    mov     rdi, keyfinal
    mov     rsi, rbx
    mov     rdx, KEY_LEN
    call    pad_key
.finalize:
    mov     byte [keyfinal + KEY_LEN], 0
    pop     rbx
    ret
