onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider MAIN_CONTROLLER
add wave -noupdate -label CLOCK                         /controller_shuffle_TB/clk
add wave -noupdate -label RESET                         /controller_shuffle_TB/rst
add wave -noupdate -label STATE -radix unsigned         /controller_shuffle_TB/U1/state
add wave -noupdate -label GAME_STATE -radix unsigned    /controller_shuffle_TB/U1/game_state
add wave -noupdate -label START_GAME_BUTTON             /controller_shuffle_TB/user_ready_to_begin
add wave -noupdate -label HIT_BUTTON                    /controller_shuffle_TB/hit
add wave -noupdate -label STAND_BUTTON                  /controller_shuffle_TB/stand

add wave -noupdate -divider SUM_REGISTERS
add wave -noupdate -label PLAYER_SUM -radix unsigned /controller_shuffle_TB/U1/player_sum_r
add wave -noupdate -label HOUSE_SUM -radix unsigned /controller_shuffle_TB/U1/house_sum_r

add wave -noupdate -divider ADDER_SIGNALS
add wave -noupdate -label CARD -radix unsigned  /controller_shuffle_TB/U1/adder_instance/card
add wave -noupdate -label HOUSE_SELECT          /controller_shuffle_TB/U1/house_select
add wave -noupdate -label PLAYER_SELECT         /controller_shuffle_TB/U1/player_select

add wave -noupdate -divider COMPARATOR_SIGNALS
add wave -noupdate -label val1_player           /controller_shuffle_TB/U1/val1_player
add wave -noupdate -label val2_player           /controller_shuffle_TB/U1/val2_player
add wave -noupdate -label val1_house            /controller_shuffle_TB/U1/val1_house
add wave -noupdate -label val2_house            /controller_shuffle_TB/U1/val2_house
add wave -noupdate -label val2_17               /controller_shuffle_TB/U1/val2_17
add wave -noupdate -label val2_21               /controller_shuffle_TB/U1/val2_21
add wave -noupdate -label LESS_THAN             /controller_shuffle_TB/U1/cp_lt
add wave -noupdate -label EQUAL_TO              /controller_shuffle_TB/U1/cp_eq
add wave -noupdate -label GREATER_THAN          /controller_shuffle_TB/U1/cp_gt
add wave -noupdate -label COMPARATOR_IN1 -radix unsigned              /controller_shuffle_TB/U1/comparator_instance/IN1_ARR
add wave -noupdate -label COMPARATOR_IN2  -radix unsigned             /controller_shuffle_TB/U1/comparator_instance/IN2_ARR

add wave -noupdate -divider DISPLAY_MODULE_SIGNALS
add wave -noupdate -label PLAYER_HAND           /controller_shuffle_TB/U1/player_hand
add wave -noupdate -label HOUSE_HAND            /controller_shuffle_TB/U1/house_hand
add wave -noupdate -label PLAYER_HAND_INDEX     /controller_shuffle_TB/U1/player_hand_index
add wave -noupdate -label HOUSE_HAND_INDEX     /controller_shuffle_TB/U1/house_hand_index

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
add wave -noupdate -label LFSR -radix unsigned /controller_shuffle_TB/U1/deck_instance/lfsr_inst/OUTPUT

add wave -noupdate -divider HAND_DISPLAY
add wave -noupdate -label HAND_SELECT /controller_shuffle_TB/U1/hand_select
add wave -noupdate -label GAME_OUTCOME /controller_shuffle_TB/U1/game_outcome
add wave -noupdate -label HAND_DISPLAY_0 /controller_shuffle_TB/U1/hand_display_0
add wave -noupdate -label HAND_DISPLAY_1 /controller_shuffle_TB/U1/hand_display_1
add wave -noupdate -label HAND_DISPLAY_2 /controller_shuffle_TB/U1/hand_display_2
add wave -noupdate -label HAND_DISPLAY_3 /controller_shuffle_TB/U1/hand_display_3
add wave -noupdate -label HAND_DISPLAY_4 /controller_shuffle_TB/U1/hand_display_4
add wave -noupdate -label HAND_DISPLAY_5 /controller_shuffle_TB/U1/hand_display_5
add wave -noupdate -label HANDS /controller_shuffle_TB/U1/hands

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
