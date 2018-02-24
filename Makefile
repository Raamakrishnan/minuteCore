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

.PHONY: build run clean