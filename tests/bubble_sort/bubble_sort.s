.text
.global _start
_start:
    # x1 - a
    # x2 - b
    # x3 - temp
    # x4 - pointer a
    # x5 - pointer b
    # x6 - counter
    # x7 - return address

    li x6, 4
l3: li x4, 3
    li x5, 2
l2: lb x1, 0(x4)
    lb x2, 0(x5)
    bge x1, x2, l # skip swapping if x1 >= x2
    # swaps x1 and x2
    mv x3, x2
    mv x2, x1
    mv x1, x3
    sb x1, 0(x4)
    sb x2, 0(x5)
l:
    addi x4, x4, -1
    addi x5, x5, -1
    bgtz x4, l2
    addi x6, x6, -1
    bgez x6, l3
end:
    jal end

.data
    .word 0x02030405