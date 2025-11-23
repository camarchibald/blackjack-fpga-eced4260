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

# Compile all your Verilog design and testbench files
vlog *.v

# Launch simulation with proper library references
vsim -L adder -L comparator -L deck -L work work.controller_shuffle_TB

# Load waveform setup if needed
do wave.do

# Run the simulation
run 650 ns
