# stop any simulation that is currently running
quit -sim

# Create and map libraries
vlib work

# Compile all your Verilog design and testbench files
vlog *.v

# Launch simulation with proper library references
vsim work.controller_shuffle_TB

# Load waveform setup if needed
do wave.do

# Run the simulation
run 650 ns
