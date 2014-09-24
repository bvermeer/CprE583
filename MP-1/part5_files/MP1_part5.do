onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_delay_tb/my_in
add wave -noupdate /uart_delay_tb/CLK
add wave -noupdate /uart_delay_tb/rst
add wave -noupdate /uart_delay_tb/iData_in
add wave -noupdate /uart_delay_tb/iRX_full
add wave -noupdate /uart_delay_tb/iTX_busy_n
add wave -noupdate /uart_delay_tb/iRD_n
add wave -noupdate /uart_delay_tb/iWR_n
add wave -noupdate /uart_delay_tb/iData_out
add wave -noupdate /uart_delay_tb/oData_in
add wave -noupdate /uart_delay_tb/oRX_full
add wave -noupdate /uart_delay_tb/oTX_busy_n
add wave -noupdate /uart_delay_tb/oRD_n
add wave -noupdate /uart_delay_tb/oWR_n
add wave -noupdate /uart_delay_tb/oData_out
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iClk
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iData_in
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iReset
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iRX_full
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iTX_busy_n
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iRD_n
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iWR_n
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iData_out
add wave -noupdate /uart_delay_tb/UART_Delay_unit/oData_in
add wave -noupdate /uart_delay_tb/UART_Delay_unit/oRX_full
add wave -noupdate /uart_delay_tb/UART_Delay_unit/oTX_busy_n
add wave -noupdate /uart_delay_tb/UART_Delay_unit/oRD_n
add wave -noupdate /uart_delay_tb/UART_Delay_unit/oWR_n
add wave -noupdate /uart_delay_tb/UART_Delay_unit/oData_out
add wave -noupdate /uart_delay_tb/UART_Delay_unit/count_reg
add wave -noupdate /uart_delay_tb/UART_Delay_unit/one_sec
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iData_in_reg
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iRX_full_reg
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iTX_busy_n_reg
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iRD_n_reg
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iWR_n_reg
add wave -noupdate /uart_delay_tb/UART_Delay_unit/iData_out_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9999999228 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {10500 us}
