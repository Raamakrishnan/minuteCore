# Makefile - minuteCore

build: 
	@mkdir -p ./bin
	@echo "compiling verilog files"
	@iverilog -o ./bin/out ./src/tb_minuteCore.v
	@echo "compilation complete"

run: ./bin/out
	@echo "simulating verilog files"
	@vvp ./bin/out > ./bin/log
	@echo "simulation complete"
	@paste -d "" ./bin/dmem.3.out.txt ./bin/dmem.2.out.txt ./bin/dmem.1.out.txt ./bin/dmem.0.out.txt > ./bin/dmem.out.txt

clean:
	@rm -vrf ./bin/*
	@echo "Cleaned"
	
SRC = $(wildcard ./src/*.v)
IMEM = ./sim/iverilog/imem.txt
DMEM = $(wildcard ./sim/iverilog/dmem.?.txt)

iverilog_build: ./sim/iverilog/minuteCore.out

./sim/iverilog/minuteCore.out: $(SRC)
	@mkdir -p ./sim/iverilog
	@echo "IVERILOG: compiling verilog files"
	@iverilog -D OUT_DIR=./sim/iverilog -o ./sim/iverilog/minuteCore.out ./src/tb_minuteCore.v
	@echo "IVERILOG: compilation complete"

iverilog_run: ./sim/iverilog/minuteCore.log ./sim/iverilog/minuteCore.dump ./sim/iverilog/minuteCore.vcd ./sim/iverilog/dmem.out.txt

$(IMEM) $(DMEM):
	@sleep 2

%.log %.dump %.vcd: %.out
	@echo "IVERILOG: simulating verilog files"
	@vvp ./sim/iverilog/minuteCore.out > ./sim/iverilog/minuteCore.log
	@echo "IVERILOG: simulation complete"
	
./sim/iverilog/dmem.out.txt:: ./sim/iverilog/dmem.0.out.txt ./sim/iverilog/dmem.1.out.txt ./sim/iverilog/dmem.2.out.txt ./sim/iverilog/dmem.3.out.txt
	@paste -d "" $^ > $@

#./sim/iverilog/dmem.out.txt:

.PHONY: build run clean iverilog_build
