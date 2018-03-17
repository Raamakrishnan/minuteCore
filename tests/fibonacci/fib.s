.text
.global _start
_start:
    # x1 - a
    # x2 - b
    # x4 - c
    # x5 - pointer
    # x3 - counter
    li x2, 0x01
    li x3, 0x0F
    sw x1, 0(x0)
    #nop
    sw x2, 4(x0)
    li x5, 0x08
l:  add x4, x1, x2      # c = a + b
    mv x1, x2           # a = b
    #nop
    #nop
    mv x2, x4           # b = c
    #nop
    sw x4, 0(x5)        # write the value
    addi x5, x5, 0x04   # increment pointer
    #nop
    #nop 
    blt x1, x3, l
end:
    jal end