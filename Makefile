.PHONY: build run clean

build: 
	@mkdir -p ./bin
	@echo "compiling verilog files"
	@iverilog -o ./bin/out ./src/tb_minuteCore.v
	@echo "compilation complete"

run: ./bin/out
	@echo "simulating verilog files"
	@vvp ./bin/out
	@echo "simulation complete"