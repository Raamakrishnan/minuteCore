# Makefile - minuteCore

.PHONY: clean build_iverilog run_iverilog clean_iverilog build_modelsim lib run_modelsim clean_modelsim
	
SRC = $(wildcard ./src/*.v)
IVERILOG_SIM_PATH = ./sim/iverilog
IVERILOG_IMEM = $(IVERILOG_SIM_PATH)/imem.txt
IVERILOG_DMEM = $(IVERILOG_SIM_PATH)/dmem.0.txt $(IVERILOG_SIM_PATH)/dmem.1.txt \
				$(IVERILOG_SIM_PATH)/dmem.2.txt $(IVERILOG_SIM_PATH)/dmem.3.txt
IVERILOG_FLAGS = -Wall
TEST ?= bubble_sort

# Icarus Verilog build rules

build_iverilog: $(IVERILOG_SIM_PATH)/out

./sim/iverilog/out: $(SRC)
	@mkdir -p $(IVERILOG_SIM_PATH)
	@echo IVERILOG: compiling verilog files
	@iverilog $(IVERILOG_FLAGS) -o $(IVERILOG_SIM_PATH)/out ./src/tb_minuteCore.v
	@echo IVERILOG: compilation complete

run_iverilog: $(IVERILOG_SIM_PATH)/log

./sim/iverilog/log: $(IVERILOG_SIM_PATH)/out $(IVERILOG_IMEM) $(IVERILOG_DMEM)
	@echo IVERILOG: simulating verilog files
	@cd $(IVERILOG_SIM_PATH) && vvp out > log
	@echo IVERILOG: simulation complete
	@paste -d "" $(IVERILOG_SIM_PATH)/dmem.3.out.txt $(IVERILOG_SIM_PATH)/dmem.2.out.txt \
		$(IVERILOG_SIM_PATH)/dmem.1.out.txt $(IVERILOG_SIM_PATH)/dmem.0.out.txt \
		 > $(IVERILOG_SIM_PATH)/dmem.out.txt

clean: clean_iverilog clean_modelsim
	@echo Cleaned

clean_iverilog:
	rm -vrf $(IVERILOG_SIM_PATH)/*
	@echo Cleaned IVERILOG

$(IVERILOG_IMEM):
	ln -s ~/minuteCore/tests/$(TEST)/build/imem.txt ~/minuteCore/$(IVERILOG_SIM_PATH)/imem.txt 
	@echo Linked IMEM with $(TEST)
	
$(IVERILOG_DMEM):
	@ln -s ~/minuteCore/tests/$(TEST)/build/dmem.?.txt ~/minuteCore/$(IVERILOG_SIM_PATH)
	@echo Linked DMEM with $(TEST)


# ModelSim build rules

MODELSIM_SIM_PATH = ./sim/modelsim
MODELSIM_IMEM = $(MODELSIM_SIM_PATH)/imem.txt
MODELSIM_DMEM = $(MODELSIM_SIM_PATH)/dmem.0.txt $(MODELSIM_SIM_PATH)/dmem.1.txt \
				$(MODELSIM_SIM_PATH)/dmem.2.txt $(MODELSIM_SIM_PATH)/dmem.3.txt
MODELSIM_WORK = $(MODELSIM_SIM_PATH)/work
LIB_WORK = $(MODELSIM_SIM_PATH)/work

build_modelsim: lib whole_library $(MODELSIM_SIM_PATH)/out

$(MODELSIM_SIM_PATH)/out: 
	@echo 'vsim -quiet -novopt -lib work -do "run -all; quit" -c tb_minuteCore' > $@
	@chmod +x $@
	@echo MODELSIM: created output file

lib:
	@echo MODELSIM: creating library files
	@vlib $(MODELSIM_WORK)

# Define path to each design unit
WORK__writeback = $(LIB_WORK)/writeback/_primary.dat
WORK__tb_minuteCore = $(LIB_WORK)/tb_minute@core/_primary.dat
WORK__sp_ram = $(LIB_WORK)/sp_ram/_primary.dat
WORK__regfile = $(LIB_WORK)/regfile/_primary.dat
WORK__minuteCore = $(LIB_WORK)/minute@core/_primary.dat
WORK__memory = $(LIB_WORK)/memory/_primary.dat
WORK__imem = $(LIB_WORK)/imem/_primary.dat
WORK__hazard_detect = $(LIB_WORK)/hazard_detect/_primary.dat
WORK__fetch = $(LIB_WORK)/fetch/_primary.dat
WORK__execute = $(LIB_WORK)/execute/_primary.dat
WORK__dmem = $(LIB_WORK)/dmem/_primary.dat
WORK__decode = $(LIB_WORK)/decode/_primary.dat
VCOM = vcom
VLOG = vlog
VOPT = vopt
SCCOM = sccom

whole_library :     $(WORK__writeback) \
    $(WORK__tb_minuteCore) \
    $(WORK__sp_ram) \
    $(WORK__regfile) \
    $(WORK__minuteCore) \
    $(WORK__memory) \
    $(WORK__imem) \
    $(WORK__hazard_detect) \
    $(WORK__fetch) \
    $(WORK__execute) \
    $(WORK__dmem) \
    $(WORK__decode)

$(WORK__decode) \
$(WORK__dmem) \
$(WORK__execute) \
$(WORK__fetch) \
$(WORK__hazard_detect) \
$(WORK__imem) \
$(WORK__memory) \
$(WORK__minuteCore) \
$(WORK__regfile) \
$(WORK__sp_ram) \
$(WORK__tb_minuteCore) \
$(WORK__writeback) : $(SRC)
	@echo MODELSIM: compiling verilog files
	@$(VLOG) -work $(LIB_WORK) +incdir+./src -O0 ./src/tb_minuteCore.v
	@echo MODELSIM: compilation complete

run_modelsim: $(MODELSIM_SIM_PATH)/log

$(MODELSIM_SIM_PATH)/log: build_modelsim $(MODELSIM_IMEM) $(MODELSIM_DMEM)
	@echo MODELSIM: simulating verilog files
	cd $(MODELSIM_SIM_PATH) && ./out > log
	@echo MODELSIM: simulation complete
	@paste -d "" $(MODELSIM_SIM_PATH)/dmem.3.out.txt $(MODELSIM_SIM_PATH)/dmem.2.out.txt \
		$(MODELSIM_SIM_PATH)/dmem.1.out.txt $(MODELSIM_SIM_PATH)/dmem.0.out.txt \
		> $(MODELSIM_SIM_PATH)/dmem.out.txt
	@cut -c3- $(MODELSIM_SIM_PATH)/log > tmp
	rm $(MODELSIM_SIM_PATH)/log
	mv tmp $(MODELSIM_SIM_PATH)/log

$(MODELSIM_IMEM):
	ln -s ~/minuteCore/tests/$(TEST)/build/imem.txt ~/minuteCore/$(MODELSIM_SIM_PATH)/imem.txt 
	@echo Linked IMEM with $(TEST)
	
$(MODELSIM_DMEM):
	@ln -s ~/minuteCore/tests/$(TEST)/build/dmem.?.txt ~/minuteCore/$(MODELSIM_SIM_PATH)
	@echo Linked DMEM with $(TEST)


clean_modelsim:
	@rm -vrf $(MODELSIM_SIM_PATH)/*
	@echo Cleaned MODELSIM
