# Comparator testbench wave.do file, Cameron Archibald B00893056, Nader Hdeib B00898627
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider COMPARATOR_INPUTS
add wave -noupdate -label PLAYER_INPUT -radix unsigned /testbench/PLAYER_INPUT
add wave -noupdate -label HOUSE_INPUT -radix unsigned /testbench/HOUSE_INPUT

add wave -noupdate -divider COMPARATOR_CONTROL
add wave -noupdate -label VAL1_PLAYER /testbench/VAL1_PLAYER
add wave -noupdate -label VAL1_HOUSE /testbench/VAL1_HOUSE
add wave -noupdate -label VAL2_PLAYER /testbench/VAL2_PLAYER
add wave -noupdate -label VAL2_HOUSE /testbench/VAL2_HOUSE
add wave -noupdate -label VAL2_21 /testbench/VAL2_21
add wave -noupdate -label VAL2_17 /testbench/VAL2_17

add wave -noupdate -divider COMPARATOR_OUTPUT
add wave -noupdate -label EQ /testbench/EQ
add wave -noupdate -label GT /testbench/GT
add wave -noupdate -label LT /testbench/LT

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 73
configure wave -valuecolwidth 64
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {5000 ns}
