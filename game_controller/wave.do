onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider MAIN_CONTROLLER
add wave -noupdate -label CLOCK                     /controller_shuffle_TB/clk
add wave -noupdate -label RESET                     /controller_shuffle_TB/rst
add wave -noupdate -label STATE -radix unsigned     /controller_shuffle_TB/U1/state
add wave -noupdate -label USER_BUTTON               /controller_shuffle_TB/user_ready_to_begin

add wave -noupdate -divider SUM REGISTERS
add wave -noupdate -label PLAYER_SUM -radix unsigned /controller_shuffle_TB/U1/player_sum_r
add wave -noupdate -label HOUSE_SUM -radix unsigned /controller_shuffle_TB/U1/house_sum_r

add wave -noupdate -divider ADDER_SIGNALS
add wave -noupdate -label CARD -radix unsigned /controller_shuffle_TB/U1/adder_instance/card


add wave -noupdate -divider DECK_MODULE
add wave -noupdate -label SHUFFLE_START     /controller_shuffle_TB/U1/deck_instance/shuffle_start
add wave -noupdate -label SHUFFLE_READY     /controller_shuffle_TB/U1/deck_instance/shuffle_ready
add wave -noupdate -label SEED              /controller_shuffle_TB/U1/deck_instance/seed
add wave -noupdate -label CARD_START        /controller_shuffle_TB/U1/deck_instance/card_start
add wave -noupdate -label CARD_READY        /controller_shuffle_TB/U1/deck_instance/card_ready
add wave -noupdate -label CARD              /controller_shuffle_TB/U1/deck_instance/card
add wave -noupdate -label CARD_OVERFLOW     /controller_shuffle_TB/U1/deck_instance/card_overflow

add wave -noupdate -divider LFSR_DECK_HANDSHAKES
add wave -noupdate -label LFSR_SET_START    /controller_shuffle_TB/U1/deck_instance/LFSR_SET_START
add wave -noupdate -label LFSR_SET_READY    /controller_shuffle_TB/U1/deck_instance/LFSR_SET_READY
add wave -noupdate -label LFSR_SHIFT_START  /controller_shuffle_TB/U1/deck_instance/LFSR_SHIFT_START
add wave -noupdate -label LFSR_SHIFT_READY  /controller_shuffle_TB/U1/deck_instance/LFSR_SHIFT_READY

add wave -noupdate -divider DECK_INTERNAL_STATES
add wave -noupdate -label DECK -radix unsigned /controller_shuffle_TB/U1/deck_instance/SHUFFLED_CARDS
add wave -noupdate -label LFSR -radix unsigned /controller_shuffle_TB/U1/deck_instance/lfsr/OUTPUT

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50000000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 240
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
