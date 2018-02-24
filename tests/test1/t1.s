.text
.global _start
_start:
    lb x2, 3(zero)
    lh x3, 2(zero)
    addi x2, x0, 0x01
    nop
    nop
    nop
    nop
    sw	zero, 0(zero)
    
.data
	.dword 0x1020304050607080
	.dword 0x1020304050607080
