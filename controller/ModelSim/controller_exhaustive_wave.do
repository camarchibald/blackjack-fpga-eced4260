onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider INTERNAL
add wave -noupdate -label CLOCK                         /controller_exhaustive_tb/clk

add wave -noupdate -divider BUTTONS
add wave -noupdate -label RESET                         /controller_exhaustive_tb/rst
add wave -noupdate -label START_GAME_BUTTON             /controller_exhaustive_tb/user_ready_to_begin
add wave -noupdate -label HIT_BUTTON                    /controller_exhaustive_tb/hit
add wave -noupdate -label STAND_BUTTON                  /controller_exhaustive_tb/stand

add wave -noupdate -divider SWITCHES
add wave -noupdate -label SEED              /controller_exhaustive_tb/seed

add wave -noupdate -divider LEDS
add wave -noupdate -label GAME_OUTCOME /controller_exhaustive_tb/game_outcome

add wave -noupdate -divider INFO
add wave -noupdate -label PLAYER_HAND -radix unsigned /controller_exhaustive_tb/player_hand
add wave -noupdate -label HOUSE_HAND -radix unsigned /controller_exhaustive_tb/house_hand
add wave -noupdate -label STATE -radix unsigned /controller_exhaustive_tb/state
add wave -noupdate -label PLAYER_SUM -radix unsigned /controller_exhaustive_tb/player_sum_tb
add wave -noupdate -label HOUSE_SUM -radix unsigned /controller_exhaustive_tb/house_sum_tb
add wave -noupdate -label CORRECT -radix unsigned /controller_exhaustive_tb/correct
add wave -noupdate -label INCORRECT -radix unsigned /controller_exhaustive_tb/incorrect

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
