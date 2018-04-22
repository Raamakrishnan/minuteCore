.text
.global _start
_start:

    li x1, 0xFF
    li x2, 0x88
    csrrw x0, mscratch, x1
    csrrw x3, mscratch, x2
    sw x3, 0(zero)
    csrrw x4, mscratch, x0    
    sw x4, 4(zero)
end:
    jal end

.data
    .word 0x02030405