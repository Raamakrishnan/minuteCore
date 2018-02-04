# the name of the program we're going to build
PROJECT = build
# this is a list of object files to generate.  Make will work out which to build from C and which from assembly
OBJECT_FILES = t1.o


# settings for the compilers
CC = riscv32-unknown-elf-gcc
AS = riscv32-unknown-elf-gcc
TARGET_ARCH = -m32 -march=RV32I
CFLAGS = -O0 $(TARGET_ARCH)
ASFLAGS =

# Lists of rules: the name of a file, followed by the files it depends on.
# When typing 'make' not followed by a rule name, the first rule is followed.  This rule depends on 
# everything, causing all the parts to be built

all: ${OBJECT_FILES} ${PROJECT} ${PROJECT}/${PROJECT}.bin ${PROJECT}/imem.txt ${PROJECT}/dmem.txt ${PROJECT}/dmem.0.txt $\
	${PROJECT}/dmem.1.txt ${PROJECT}/dmem.2.txt ${PROJECT}/dmem.3.txt ${PROJECT}/${PROJECT}.dump

# how to build a .o file from a .c file
%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

# how to build a .o file from a .s file
%.o: %.s
	$(AS) -c -o $@ $< $(ASFLAGS)

${PROJECT}/imem.txt: ${PROJECT}/${PROJECT}.imem
	hexdump -v -e '"%08x\n"' $< > $@
	
${PROJECT}/dmem.txt: ${PROJECT}/${PROJECT}.dmem
	hexdump -v -e '"%08x\n"' $< > $@
	
%/dmem.3.txt: %/dmem.txt
	cut -b 1-2 $< > $@
	
%/dmem.2.txt: %/dmem.txt
	cut -b 3-4 $< > $@
	
%/dmem.1.txt: %/dmem.txt
	cut -b 5-6 $< > $@
	
%/dmem.0.txt: %/dmem.txt
	cut -b 7-8 $< > $@
	
${PROJECT}:
	if [ ! -d "$@" ]; then \
		mkdir ${PROJECT}; \
	fi

${PROJECT}/${PROJECT}.imem: ${PROJECT}/${PROJECT}.bin
	riscv32-unknown-elf-objcopy -O binary --only-section=.text $< $@
	
${PROJECT}/${PROJECT}.dmem: ${PROJECT}/${PROJECT}.bin
	riscv32-unknown-elf-objcopy -O binary --pad-to=0x10000000 --only-section=.data $< $@

${PROJECT}/${PROJECT}.bin: ${OBJECT_FILES}
	riscv32-unknown-elf-ld -o $@ -T prog-link.ld $^

${PROJECT}/${PROJECT}.dump: ${PROJECT}/${PROJECT}.bin
	riscv32-unknown-elf-objdump -d $< > $@

# 'clean' rule: delete all the files so we can start afresh
clean:
	rm -rf ${PROJECT} ${PROJECT}.bin *.o

