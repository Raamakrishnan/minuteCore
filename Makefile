# Makefile - minuteCore

.PHONY: clean iverilog_build iverilog_run iverilog_clean
	
SRC = $(wildcard ./src/*.v)
IVERILOG_IMEM = ./sim/iverilog/imem.txt
IVERILOG_DMEM = ./sim/iverilog/dmem.0.txt ./sim/iverilog/dmem.1.txt ./sim/iverilog/dmem.2.txt ./sim/iverilog/dmem.3.txt
TEST ?= sort

iverilog_build: ./sim/iverilog/minuteCore.out

./sim/iverilog/minuteCore.out: $(SRC)
	@mkdir -p ./sim/iverilog
	@echo "IVERILOG: compiling verilog files"
	@iverilog -DOUT_DIR=./sim/iverilog -o ./sim/iverilog/minuteCore.out ./src/tb_minuteCore.v
	@echo "IVERILOG: compilation complete"

iverilog_run: ./sim/iverilog/minuteCore.log

./sim/iverilog/minuteCore.log: ./sim/iverilog/minuteCore.out $(IVERILOG_IMEM) $(IVERILOG_DMEM)
	@echo "IVERILOG: simulating verilog files"
	@cd ./sim/iverilog && vvp minuteCore.out > minuteCore.log
	@echo "IVERILOG: simulation complete"
	@paste -d "" ./sim/iverilog/dmem.3.out.txt ./sim/iverilog/dmem.2.out.txt ./sim/iverilog/dmem.1.out.txt ./sim/iverilog/dmem.0.out.txt > ./sim/iverilog/dmem.out.txt

clean: iverilog_clean	

iverilog_clean:
	rm -vrf ./sim/iverilog/*
	@echo "Cleaned"

$(IVERILOG_IMEM):
	@echo Linking IMEM with $(TEST)
	@ln -s ~/minuteCore/tests/$(TEST)/build/imem.txt ~/minuteCore/sim/iverilog/imem.txt 
	
$(IVERILOG_DMEM):
	@echo Linking DMEM with $(TEST)
	@ln -s ~/minuteCore/tests/$(TEST)/build/dmem.?.txt ~/minuteCore/sim/iverilog/
