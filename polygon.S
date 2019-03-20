.global makebox
.global maketorus
.global makesphere
.global cos2
.global sin2
.data
    storage: .zero 48
.bss
.text
makebox://X,Y,Z in xmm0-2, h,w,d in xmm3-5
    //½ box
    lea storage(%rip), %rsi
    movsd %xmm0,(%rsi)
    movsd %xmm1,8(%rsi)
    movsd %xmm2,16(%rsi)
    vaddsd %xmm0, %xmm3, %xmm3
    movsd %xmm3,24(%rsi)
    vsubsd %xmm4, %xmm1, %xmm4
    movsd %xmm4,32(%rsi)
    vsubsd %xmm5, %xmm2, %xmm5
    movsd %xmm5,40(%rsi)
    call drawcorn
    call uboxvar
    movsd %xmm5, %xmm2
    movsd %xmm4, %xmm1
    call addedge
    call uboxvar
    movsd %xmm0, 24(%rsi)
    movsd %xmm1, 32(%rsi)
    movsd %xmm2, 40(%rsi)
    movsd %xmm3, (%rsi)
    movsd %xmm4, 8(%rsi)
    movsd %xmm5, 16(%rsi)
    call drawcorn
    
    ret
uboxvar:
    lea storage(%rip), %rsi
    movsd (%rsi), %xmm0
    movsd 8(%rsi), %xmm1
    movsd 16(%rsi), %xmm2
    movsd 24(%rsi), %xmm3
    movsd 32(%rsi), %xmm4
    movsd 40(%rsi), %xmm5
    ret
drawcorn:
    call uboxvar
    movsd %xmm0, %xmm3
    movsd %xmm1, %xmm4
    call addedge
    call uboxvar
    movsd %xmm1, %xmm4
    movsd %xmm2, %xmm5
    call addedge
    call uboxvar
    movsd %xmm0, %xmm3
    movsd %xmm2, %xmm5
    call addedge
    call uboxvar
    movsd %xmm0, %xmm3
    movsd %xmm5, %xmm2
    call addedge
    call uboxvar
    movsd %xmm1, %xmm4
    movsd %xmm5, %xmm2
    call addedge
    call uboxvar
    movsd %xmm1, %xmm4
    movsd %xmm3, %xmm0
    call addedge
    ret
roundmatrix://0-19 phi in rdi, 0-19 theta in rsi, radius is in %xmm3
    sub $32, %rsp
    vmovsd %xmm3, (%rsp)
    vcvtsi2sd %rdi, %xmm0, %xmm0
    vcvtsi2sd %rsi, %xmm1, %xmm1
    vmulsd pointo2(%rip), %xmm0, %xmm0
    vmulsd pointo2(%rip), %xmm1, %xmm1
    vmovsd %xmm0, 8(%rsp)
    vmovsd %xmm1, 16(%rsp)
    mov tempmatrix4(%rip), %rdi
    lea blankmatrix(%rip), %rax
    call forcematrix
    vmovsd 8(%rsp), %xmm0
    call sin2
    vmovsd %xmm0, 24(%rsp)
    vmovsd 8(%rsp), %xmm0
    call cos2
    mov tempmatrix4(%rip), %rdi
    mov (%rdi), %rdi
    mov one(%rip), %rax
    mov %rax, (%rdi)
    vmovsd %xmm0, 40(%rdi)
    vmovsd %xmm0, 80(%rdi)
    vmovsd 24(%rsp), %xmm0
    vmovsd %xmm0, 48(%rdi)
    vxorpd %ymm1, %ymm1, %ymm1
    vsubsd %xmm0, %xmm1, %xmm0
    vmovsd %xmm0, 72(%rdi)
    vmovsd 16(%rsp), %xmm0
    call sin2
    vmovsd %xmm0, 24(%rsp)
    vmovsd 16(%rsp), %xmm0
    call cos2
    mov tempmatrixX(%rip), %rdi
    mov (%rdi), %rdi
    vmulsd (%rsp), %xmm0, %xmm0
    vmovsd %xmm0, (%rdi)
    vmovsd 24(%rsp), %xmm0
    vmulsd (%rsp), %xmm0, %xmm0
    vmovsd %xmm0, 8(%rdi)
    movq $0, 16(%rdi)
    movq $0, 24(%rdi)
    mov tempmatrix4(%rip), %rdi
    mov tempmatrixX(%rip), %rsi
    call multiplymatrix
    add $32, %rsp
    ret
    
makesphere:
    call gensphere
    xor %rdx, %rdx
    twohunnid:
    vmovsd one(%rip), %xmm7
    vpermq $0b0, %ymm7, %ymm7
    vmovupd (%rax, %rdx,8), %ymm3
    vpermq $0b00, %ymm3, %ymm0
    vpermq $0b01, %ymm3, %ymm1
    vpermq $0b10, %ymm3, %ymm2
    vaddpd %ymm7, %ymm3, %ymm3
    vpermq $0b01, %ymm3, %ymm4
    vpermq $0b10, %ymm3, %ymm5
    push %rax
    push %rdx
    mov edgem(%rip), %rdi
    call addedge
    pop %rdx
    pop %rax
    add $4, %rdx
    cmp $1600, %rdx
    jne twohunnid
    mov %rax, %rdi
    call free@PLT
    ret
gensphere:
    sub $32, %rsp
    vmovsd %xmm0, (%rsp)
    vmovsd %xmm1, 8(%rsp)
    vmovsd %xmm2, 16(%rsp)
    vmovsd %xmm3, 24(%rsp)
    mov $400, %rdi
    mov $32, %rsi
    call calloc@PLT
    mov %rax,tempmatrixG(%rip)
    xor %rax, %rax
    startrot:
    xor %rcx, %rcx
    startcirc:

    vmovsd 24(%rsp), %xmm3
    push %rax
    push %rcx
    mov %rdi, %rdx
    mov %rax, %rdi
    mov %rcx, %rsi
    call roundmatrix
    pop %rcx
    pop %rax
    mov tempmatrixX(%rip), %rdi
    mov (%rdi), %r8
    vmovsd (%rsp), %xmm0
    vmovsd 8(%rsp), %xmm1
    vmovsd 16(%rsp), %xmm2
    vaddsd (%r8), %xmm0, %xmm0
    vmovsd %xmm0, (%r8)
    vaddsd 8(%r8), %xmm1, %xmm1
    vmovsd %xmm1, 8(%r8)
    vaddsd 16(%r8), %xmm2, %xmm2
    vmovsd %xmm2, 16(%r8)
    vmovupd (%r8), %ymm0
    mov tempmatrixG(%rip), %rdx
    mov %rax, %r8
    imul $20, %r8
    add %rcx, %r8
    sal $2, %r8
    vmovupd %ymm0, (%rdx, %r8, 8)

    inc %rcx
    cmp $20, %rcx
    jne startcirc

    inc %rax
    cmp $20, %rax
    jne startrot
    add $32, %rsp
    mov tempmatrixG(%rip), %rax
    ret

maketorus:
    vsubsd %xmm3, %xmm4, %xmm4
    vsubsd %xmm3, %xmm4, %xmm4
    call gentorus
    xor %rdx, %rdx
    twohunnid2:
    vmovsd one(%rip), %xmm7
    vpermq $0b0, %ymm7, %ymm7
    vmovupd (%rax, %rdx,8), %ymm3
    vpermq $0b00, %ymm3, %ymm0
    vpermq $0b01, %ymm3, %ymm1
    vpermq $0b10, %ymm3, %ymm2
    vaddpd %ymm7, %ymm3, %ymm3
    vpermq $0b01, %ymm3, %ymm4
    vpermq $0b10, %ymm3, %ymm5
    push %rax
    push %rdx
    mov edgem(%rip), %rdi
    call addedge
    pop %rdx
    pop %rax
    add $4, %rdx
    cmp $1600, %rdx
    jne twohunnid2
    mov %rax, %rdi
    call free@PLT
    ret
gentorus:
    sub $40, %rsp
    vmovsd %xmm0, (%rsp)
    vmovsd %xmm1, 8(%rsp)
    vmovsd %xmm2, 16(%rsp)
    vmovsd %xmm3, 24(%rsp)
    vmovsd %xmm4, 32(%rsp)
    mov $400, %rdi
    mov $32, %rsi
    call calloc@PLT
    mov %rax,tempmatrixG(%rip)
    xor %rax, %rax
    startrotd:
    xor %rcx, %rcx
    startdonut:

    vmovsd 24(%rsp), %xmm3
    vmovsd 32(%rsp), %xmm4
    push %rax
    push %rcx
    mov %rdi, %rdx
    mov %rax, %rdi
    mov %rcx, %rsi
    call donutmatrix
    pop %rcx
    pop %rax
    mov tempmatrixX(%rip), %rdi
    mov (%rdi), %r8
    vmovsd (%rsp), %xmm0
    vmovsd 8(%rsp), %xmm1
    vmovsd 16(%rsp), %xmm2
    vaddsd (%r8), %xmm0, %xmm0
    vmovsd %xmm0, (%r8)
    vaddsd 8(%r8), %xmm1, %xmm1
    vmovsd %xmm1, 8(%r8)
    vaddsd 16(%r8), %xmm2, %xmm2
    vmovsd %xmm2, 16(%r8)
    vmovupd (%r8), %ymm0
    mov tempmatrixG(%rip), %rdx
    mov %rax, %r8
    imul $20, %r8
    add %rcx, %r8
    sal $2, %r8
    vmovupd %ymm0, (%rdx, %r8, 8)

    inc %rcx
    cmp $20, %rcx
    jne startdonut

    inc %rax
    cmp $20, %rax
    jne startrotd
    add $40, %rsp
    mov tempmatrixG(%rip), %rax
    ret

donutmatrix://0-19 phi in rdi, 0-19 theta in rsi, radius is in %xmm3, Radius is in %xmm4
    sub $40, %rsp
    vmovsd %xmm3, (%rsp)
    vmovsd %xmm4, 32(%rsp)
    cvtsi2sd %rdi, %xmm0
    cvtsi2sd %rsi, %xmm1
    vmulsd pointo2(%rip), %xmm0, %xmm0
    vmulsd pointo2(%rip), %xmm1, %xmm1
    vmovsd %xmm0, 8(%rsp)
    vmovsd %xmm1, 16(%rsp)
    mov tempmatrix4(%rip), %rdi
    lea blankmatrix(%rip), %rax
    call forcematrix
    vmovsd 8(%rsp), %xmm0
    call sin2
    vmovsd %xmm0, 24(%rsp)
    vmovsd 8(%rsp), %xmm0
    call cos2
    mov tempmatrix4(%rip), %rdi
    mov (%rdi), %rdi
    mov one(%rip), %rax
    mov %rax, 40(%rdi)
    vmovsd %xmm0, (%rdi)
    vmovsd %xmm0, 80(%rdi)
    vmovsd 24(%rsp), %xmm0
    vmovsd %xmm0, 64(%rdi)
    vxorpd %ymm1, %ymm1, %ymm1
    vsubsd %xmm0, %xmm1, %xmm0
    vmovsd %xmm0, 16(%rdi)
    vmovsd 16(%rsp), %xmm0
    call sin2
    vmovsd %xmm0, 24(%rsp)
    vmovsd 16(%rsp), %xmm0
    call cos2
    vmovsd %xmm0, 8(%rsp)
    mov tempmatrixX(%rip), %rdi
    mov (%rdi), %rdi
    vmovsd 32(%rsp), %xmm1
    vmulsd (%rsp), %xmm0, %xmm0
    vaddsd %xmm1, %xmm0, %xmm0
    vmovsd %xmm0, (%rdi)
    vmovsd 24(%rsp), %xmm0
    vmulsd (%rsp), %xmm0, %xmm0
    vmovsd %xmm0, 8(%rdi)
    //properly get new point for 3rd matrix slot
    vmovsd 8(%rsp), %xmm0
    vmulsd (%rsp), %xmm0, %xmm0
    vaddsd %xmm1, %xmm0, %xmm0
    vmovsd %xmm0, 16(%rdi)
    movq $0, 24(%rdi)
    mov tempmatrix4(%rip), %rdi
    mov tempmatrixX(%rip), %rsi
    call multiplymatrix
    add $40, %rsp
    ret

cos2:
    sub $4, %rsp
    cvtsd2ss %xmm0, %xmm0
    vmovss %xmm0, (%rsp)
    fld (%rsp)
    fcos
    fstp (%rsp)
    vmovss  (%rsp), %xmm0
    cvtss2sd %xmm0, %xmm0
    add $4, %rsp
    ret
sin2:
    sub $4, %rsp
    cvtsd2ss %xmm0, %xmm0
    vmovss %xmm0, (%rsp)
    fld (%rsp)
    fsin
    fstp (%rsp)
    vmovss  (%rsp), %xmm0
    cvtss2sd %xmm0, %xmm0
    add $4, %rsp
    ret

