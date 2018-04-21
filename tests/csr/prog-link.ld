OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

__stack_size__ = 0x400; /* 1k stack */
__mem_top__ = 0x10001000;

__sp = __mem_top__;
__heap_top__ = __mem_top__ - __stack_size__;
__sp_bottom = __heap_top__;

SECTIONS
{
. = 0x00000000; /* IMEM address */

.text : { *(.text) }
. = 0x10000000; /* DMEM address */
.data : { *(.bss)
        *(.data)
        *(.sdata)
        *(.rodata)
        *(.got.plt) *(.got) }
_gp = ALIGN(16) + 0x7ff0;

__heap = ALIGN(0x4); /*64-bit alligned heap pointer */
}

