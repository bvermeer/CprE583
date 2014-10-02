onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider MP2_scanner
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_clock
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_reset
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in_scn
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_0
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_2
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_4
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/scan_state
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/scan_state_next
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in_scn_reg
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in_reg
add wave -noupdate -radix ascii -childformat {{/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(9) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(8) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(7) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(6) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(5) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(4) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(3) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(2) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(1) -radix ascii} {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(0) -radix ascii}} -expand -subitemconfig {/testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(9) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(8) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(7) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(6) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(5) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(4) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(3) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(2) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(1) {-radix ascii} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly(0) {-radix ascii}} /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29219000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
configure wave -valuecolwidth 214
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {29122802 ps} {29251198 ps}
