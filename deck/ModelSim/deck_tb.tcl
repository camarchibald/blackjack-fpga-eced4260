# Deck testbench tcl file, Cameron Archibald B00893056, Nader Hdeib B00898627
# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the VHDL source code in the parent folder
vcom ../*.vhd
# compile the VHDL code of the testbench
vcom *.vht
# compile VHDL code of component lfsr_circular_counter
vcom ../../lfsr/*.vhd
# start the Simulator, including some libraries that may be needed
vsim work.testbench -Lf 220model -Lf altera_mf
# show waveforms specified in wave.do
do deck_wave.do
# advance the simulation the desired amount of time
run 16000 ns
