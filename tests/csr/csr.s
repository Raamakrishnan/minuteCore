.text
.global _start
_start:

    li x1, 0xFF
    csrrw x0, mscratch, x1
    csrrw x2, mscratch, x0
    sw x2, 0(zero)    
end:
    jal end

.data
    .word 0x02030405