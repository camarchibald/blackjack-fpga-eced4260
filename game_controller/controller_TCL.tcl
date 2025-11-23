# stop any simulation that is currently running
quit -sim

# Create and map libraries
vlib work
vlib comparator
vlib adder
vlib deck
# vlib display (add when ready)

# Compile external VHDL modules
vcom ../deck/*.vhd
vcom ../comparator/*.vhd
vcom ../adder/*.vhd
vcom ../lfsr_circular_counter/*.vhd

# Compile all your Verilog design and testbench files
vlog *.v

# Launch simulation with proper library references
vsim work.controller_shuffle_TB

# Load waveform setup if needed
do wave.do

# Run the simulation
run 5000 ns
