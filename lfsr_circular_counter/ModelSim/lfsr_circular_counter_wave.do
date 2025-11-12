# lfsr_circular_counter testbench wave.do file, Cameron Archibald B00893056
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLK /testbench/CLK
add wave -noupdate -label SET_START /testbench/SET_START
add wave -noupdate -label SET_READY /testbench/SET_READY
add wave -noupdate -label SET_VAL -radix unsigned /testbench/SET_VAL
add wave -noupdate -label SHIFT_START /testbench/SHIFT_START
add wave -noupdate -label SHIFT_READY /testbench/SHIFT_READY
add wave -noupdate -label OUTPUT -radix unsigned /testbench/OUTPUT
add wave -noupdate -label STATE -format literal /testbench/inst/STATE
add wave -noupdate -label TB_STATE -format literal /testbench/STATE
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
WaveRestoreZoom {0 ps} {3000 ns}
