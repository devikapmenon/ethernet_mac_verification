# Makefile for Verilator Simulation

TOP = tb/tb_top.sv

VERILATOR_FLAGS = -sv -Wall -Wno-fatal --cc --exe

OBJ_DIR = obj_dir

all: run

compile:
	verilator -sv -Wall -Wno-fatal \
  -Irtl \
  --cc --exe tb/tb_top.sv sim_main.cpp \
  rtl/ethernet_mac.sv rtl/mac_tx.sv rtl/mac_rx.sv
run: compile
	./$(OBJ_DIR)/Vtb_top

clean:
	rm -rf $(OBJ_DIR) *.vcd
