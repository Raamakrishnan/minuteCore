.text
.global _start
_start:
    sb	zero, 0(zero)
    lw zero, 0(zero)
    nop
    nop
    nop
    nop
    nop
.data
	.dword 0x1020304050607080
	.dword 0x1020304050607080
