onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider MAIN_CONTROLLER

add wave -noupdate -label CLOCK    /controller_shuffle_TB/clk
add wave -noupdate -label RESET    /controller_shuffle_TB/rst
add wave -noupdate -label RESET    /controller_shuffle_TB/rst

add wave -noupdate -divider DECK_MODULE

add wave -noupdate -label SHUFFLE_START     /controller_shuffle_TB/U1/deck_instance/shuffle_start
add wave -noupdate -label SHUFFLE_READY     /controller_shuffle_TB/U1/deck_instance/shuffle_ready
add wave -noupdate -label SEED              /controller_shuffle_TB/U1/deck_instance/seed
add wave -noupdate -label CARD_START        /controller_shuffle_TB/U1/deck_instance/card_start
add wave -noupdate -label CARD_READY        /controller_shuffle_TB/U1/deck_instance/card_ready
add wave -noupdate -label CARD              /controller_shuffle_TB/U1/deck_instance/card
add wave -noupdate -label CARD_OVERFLOW     /controller_shuffle_TB/U1/deck_instance/card_overflow

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2000000 ps} 0}
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
WaveRestoreZoom {0 ps} {650 ns}
