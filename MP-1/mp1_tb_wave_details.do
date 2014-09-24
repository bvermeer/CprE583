onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mp1_tb/my_in
add wave -noupdate /mp1_tb/system_clk
add wave -noupdate /mp1_tb/reset_n
add wave -noupdate /mp1_tb/TX_driver
add wave -noupdate /mp1_tb/RX_driver
add wave -noupdate -radix ascii -childformat {{/mp1_tb/UART_HW/process_data_1/data_out_reg(7) -radix ascii} {/mp1_tb/UART_HW/process_data_1/data_out_reg(6) -radix ascii} {/mp1_tb/UART_HW/process_data_1/data_out_reg(5) -radix ascii} {/mp1_tb/UART_HW/process_data_1/data_out_reg(4) -radix ascii} {/mp1_tb/UART_HW/process_data_1/data_out_reg(3) -radix ascii} {/mp1_tb/UART_HW/process_data_1/data_out_reg(2) -radix ascii} {/mp1_tb/UART_HW/process_data_1/data_out_reg(1) -radix ascii} {/mp1_tb/UART_HW/process_data_1/data_out_reg(0) -radix ascii}} -subitemconfig {/mp1_tb/UART_HW/process_data_1/data_out_reg(7) {-height 18 -radix ascii} /mp1_tb/UART_HW/process_data_1/data_out_reg(6) {-height 18 -radix ascii} /mp1_tb/UART_HW/process_data_1/data_out_reg(5) {-height 18 -radix ascii} /mp1_tb/UART_HW/process_data_1/data_out_reg(4) {-height 18 -radix ascii} /mp1_tb/UART_HW/process_data_1/data_out_reg(3) {-height 18 -radix ascii} /mp1_tb/UART_HW/process_data_1/data_out_reg(2) {-height 18 -radix ascii} /mp1_tb/UART_HW/process_data_1/data_out_reg(1) {-height 18 -radix ascii} /mp1_tb/UART_HW/process_data_1/data_out_reg(0) {-height 18 -radix ascii}} /mp1_tb/UART_HW/process_data_1/data_out_reg
add wave -noupdate /mp1_tb/UART_HW/process_data_1/send_data
add wave -noupdate -radix ascii /mp1_tb/UART_HW/process_data_1/data_to_send
add wave -noupdate /mp1_tb/UART_HW/process_data_1/TX_busy_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20061295000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 435
configure wave -valuecolwidth 100
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
WaveRestoreZoom {99999977580 ps} {100000001180 ps}
