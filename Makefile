TOP = instruction_mem

all:
	iverilog -o sim.out rtl/$(TOP).v sim/$(TOP)_tb.v

run:
	vvp sim.out

waves:
	gtkwave wave.vcd

clean:
	rm -f sim.out wave.vcd