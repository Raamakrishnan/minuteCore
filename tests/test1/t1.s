.text
.global _start
_start:
    lw x1, 0(zero)
    lw x2, 4(zero)
    nop
    nop
    nop
    add x3, x1, x2
    nop
    nop
    nop
    sw x3, 8(zero)
end:
    jal end
.data
	.dword 0x1020304050607080
	.dword 0x1020304050607080
