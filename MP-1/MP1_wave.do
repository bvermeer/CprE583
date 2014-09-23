onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {MP1 testbench (MP1_tb)}
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/my_in
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/system_clk
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/reset_n
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/tx_driver
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/rx_driver
add wave -noupdate -divider {Stimulus (uart_driver)}
add wave -noupdate -format Literal -radix hexadecimal /mp1_tb/uart_driver/array_index
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/sysclk
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/reset_low
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/fpga_serial1_tx
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/fpga_serial1_rx
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/reset
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/wr_n
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/rd_n
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/txd_temp
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/rx_full
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/tx_busy_n
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_driver/my_pulse
add wave -noupdate -format Literal -radix hexadecimal /mp1_tb/uart_driver/d_in
add wave -noupdate -format Literal -radix hexadecimal /mp1_tb/uart_driver/d_out
add wave -noupdate -format Literal -radix hexadecimal /mp1_tb/uart_driver/data_rx_reg
add wave -noupdate -format Literal -radix hexadecimal /mp1_tb/uart_driver/send_data_array
add wave -noupdate -divider {FPGA hardware (uart_hw)}
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/sysclk
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/reset_low
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/fpga_serial1_tx
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/fpga_serial1_rx
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/reset
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/wr_n
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/rd_n
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/rx_full
add wave -noupdate -format Logic -radix hexadecimal /mp1_tb/uart_hw/tx_busy_n
add wave -noupdate -format Literal -radix hexadecimal /mp1_tb/uart_hw/d_in
add wave -noupdate -format Literal -radix hexadecimal /mp1_tb/uart_hw/d_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1161545215 ps} 0}
configure wave -namecolwidth 337
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
configure wave -timelineunits ps
update
WaveRestoreZoom {9029982441 ps} {10051053556 ps}
