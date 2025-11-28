# Controller testbench tcl file, Nader Hdeib B00898627, Cameron Archibald B00893056
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
vcom ../../lfsr/*.vhd

# Compile all your Verilog design and testbench files
vlog ../*.v
vlog *.v

# Launch simulation with proper library references
vsim work.controller_tb

# Load waveform setup if needed
do controller_wave.do

# Run the simulation
run 5000 ns
