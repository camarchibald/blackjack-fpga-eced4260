# Circular counter testbench wave.do file, Cameron Archibald B00893056
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLK /testbench/CLK_TB
add wave -noupdate -label SET /testbench/SET_TB
add wave -noupdate -label SET_VAL -radix unsigned /testbench/SET_VAL_TB
add wave -noupdate -label OUTPUT -radix unsigned /testbench/OUTPUT_TB
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
WaveRestoreZoom {0 ps} {2000 ns}
