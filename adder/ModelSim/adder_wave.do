# Adder testbench wave.do file, Cameron Archibald B00893056
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider ADDER_VALS
add wave -noupdate -label CARD -radix unsigned /testbench/CARD
add wave -noupdate -label RESET /testbench/RESET
add wave -noupdate -label PLAYER_INPUT -radix unsigned /testbench/PLAYER_INPUT
add wave -noupdate -label HOUSE_INPUT -radix unsigned /testbench/HOUSE_INPUT
add wave -noupdate -label PLAYER_OUTPUT -radix unsigned /testbench/PLAYER_OUTPUT
add wave -noupdate -label HOUSE_OUTPUT -radix unsigned /testbench/HOUSE_OUTPUT

add wave -noupdate -divider SELECT_SIGNALS
add wave -noupdate -label PLAYER_SELECT /testbench/PLAYER_SELECT
add wave -noupdate -label HOUSE_SELECT /testbench/HOUSE_SELECT

add wave -noupdate -divider ADDER_INTERNAL_SIGNALS
add wave -noupdate -label IN1_ARR /testbench/adder_inst/IN1_ARR
add wave -noupdate -label IN2_ARR /testbench/adder_inst/IN2_ARR
add wave -noupdate -label CIN_ARR /testbench/adder_inst/CIN_ARR
add wave -noupdate -label COUT_ARR /testbench/adder_inst/COUT_ARR
add wave -noupdate -label SUM_ARR -radix unsigned /testbench/adder_inst/SUM_ARR

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
