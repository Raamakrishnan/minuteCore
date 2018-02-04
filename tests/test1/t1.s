.text
.global _start
_start:
    addi x2, x0, 0x01
    nop
    nop
    nop
    nop
    sw	zero, 0(zero)
    
.data
	.dword 0x12345
	.dword 0x67890
