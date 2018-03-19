.text
.global _start
_start:
    # x1 - value
    # x2 - pointer
    li x3, 0x0A
l:  sw x1, 0(x2)        # write the value
    addi x1, x1, 0x01   # increment value
    addi x2, x2, 0x04   # increment pointer
    #nop
    #nop
    blt x1, x3, l
end:
    jal end
