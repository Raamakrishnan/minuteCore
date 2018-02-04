.text
.global _start
_start:
    lw x1, 0(zero)
    nop
    nop
    nop
    addi x2, x0, 0x01
    nop
    nop
    nop
    nop
    sw	zero, 0(zero)
    
.data
	.dword 0x12345
	.dword 0x67890
