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

clean:
	@rm -vrf ./bin/*
	@echo "Cleaned"

.PHONY: build run clean