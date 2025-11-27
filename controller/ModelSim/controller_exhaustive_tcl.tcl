# stop any simulation that is currently running
quit -sim

# Create and map libraries
vlib work
vlib comparator
vlib adder
vlib deck
# vlib display (add when ready)

# Compile external VHDL modules
vcom ../../deck/*.vhd
vcom ../../comparator/*.vhd
vcom ../../adder/*.vhd
vcom ../../lfsr_circular_counter/*.vhd

# Compile all your Verilog design and testbench files
vlog ../*.v
vlog controller_exhaustive_tb.v

# Launch simulation with proper library references
vsim work.controller_exhaustive_tb

# Load waveform setup if needed
do controller_exhaustive_wave.do

# Run the simulation
run 240000 ns
