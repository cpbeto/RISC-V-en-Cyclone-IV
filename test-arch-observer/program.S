.section .text
.global _start

_start:
    li x1,220
    sw x0,4 (x1)
    lw x2,4 (x1)
_loop:
    addi x2,x2,4
    sw x2,8 (x1)
    addi x3,x2,32
    sw x3,64 (x2)
    addi x4,x3,80
    sw x4,128 (x4)
    sub x5,x4,x2
    sw x5,12 (x5)
    li x6,160
    sw x6,8 (x6)
    lw x7,8 (x6)
    addi x2,x2,12
    addi x3,x3,4
    addi x4,x4,8
    addi x5,x5,1
    addi x6,x6,5
    addi x7,x7,3
    j _loop
