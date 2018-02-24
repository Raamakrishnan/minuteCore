.text
.global _start
_start:
    lw x1, 0(zero)
    sb zero, 1(zero)
    lh x3, 1(zero)
    nop
    nop
    nop
    nop
    nop
.data
	.dword 0x1020304050607080
	.dword 0x1020304050607080
