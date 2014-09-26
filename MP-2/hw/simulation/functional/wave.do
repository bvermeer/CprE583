onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {System Signals}
add wave -noupdate -format Logic /testbench/reset
add wave -noupdate -format Logic /testbench/host_clk
add wave -noupdate -divider MP1_scanner
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_clock
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_reset
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_data_in_scn
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_sof_in_n_scn
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_eof_in_n_scn
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_src_rdy_in_n_scn
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_dst_rdy_in_n_scn
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_data_in
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_sof_in_n
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_eof_in_n
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_src_rdy_in_n
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_dst_rdy_in_n
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/scan_state
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/scan_state_next
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_data_in_scn_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_sof_in_n_scn_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_eof_in_n_scn_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_src_rdy_in_n_scn_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_dst_rdy_in_n_scn_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_data_in_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_sof_in_n_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_eof_in_n_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_src_rdy_in_n_reg
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_dst_rdy_in_n_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/data_scn_dly
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/sof_n_scn_dly
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/eof_n_scn_dly
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/src_rdy_n_scn_dly
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/dst_rdy_n_scn_dly
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/ip_src_shift_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/ip_dst_shift_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/eth_index_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/udp_payload_index
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/udp_len_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/ip_src_addr_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/ip_dst_addr_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/src_insert_shift_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/dst_insert_shift_reg
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/data_out_sel
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/rx_ll_data_in_insert
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/eth_start_flag
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/eth_end_flag
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/ld_src_ip_flag
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/ld_dst_ip_flag
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/ld_udp_len_flag
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/start_scan_flag
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/wr_src_ip_flag
add wave -noupdate -format Logic -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_mp1_scanner/wr_dst_ip_flag
add wave -noupdate -divider {EMAC0 Tx Client Interface}
add wave -noupdate -format Logic -label tx_client_clk_0 /testbench/dut/tx_clk_0
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/v5_emac_ll/tx_data_0_i
add wave -noupdate -format Logic /testbench/dut/v5_emac_ll/tx_data_valid_0_i
add wave -noupdate -format Logic /testbench/dut/v5_emac_ll/tx_ack_0_i
add wave -noupdate -format Literal -radix hexadecimal /testbench/tx_ifg_delay_0
add wave -noupdate -divider {EMAC0 Rx Client Interface}
add wave -noupdate -format Logic -label rx_client_clk_0 /testbench/dut/rx_clk_0_i
add wave -noupdate -format Literal -radix hexadecimal /testbench/dut/v5_emac_ll/rx_data_0_i
add wave -noupdate -format Logic /testbench/dut/v5_emac_ll/rx_data_valid_0_i
add wave -noupdate -format Logic /testbench/dut/v5_emac_ll/rx_good_frame_0_i
add wave -noupdate -format Logic /testbench/dut/v5_emac_ll/rx_bad_frame_0_i
add wave -noupdate -divider {EMAC0 Flow Control}
add wave -noupdate -format Literal -radix hexadecimal /testbench/pause_val_0
add wave -noupdate -format Logic /testbench/pause_req_0
add wave -noupdate -divider {EMAC0 Tx GMII/MII Interface}
add wave -noupdate -format Logic /testbench/gmii_tx_clk_0
add wave -noupdate -format Literal -radix hexadecimal /testbench/gmii_txd_0
add wave -noupdate -format Logic /testbench/gmii_tx_en_0
add wave -noupdate -format Logic /testbench/gmii_tx_er_0
add wave -noupdate -divider {EMAC0 Rx GMII/MII Interface}
add wave -noupdate -format Logic /testbench/gmii_rx_clk_0
add wave -noupdate -format Literal -radix hexadecimal /testbench/gmii_rxd_0
add wave -noupdate -format Logic /testbench/gmii_rx_dv_0
add wave -noupdate -format Logic /testbench/gmii_rx_er_0
add wave -noupdate -divider {Test semaphores}
add wave -noupdate -format Logic /testbench/emac0_configuration_busy
add wave -noupdate -format Logic /testbench/emac0_monitor_finished_1g
add wave -noupdate -format Logic /testbench/emac0_monitor_finished_100m
add wave -noupdate -format Logic /testbench/emac0_monitor_finished_10m
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 317
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
WaveRestoreZoom {1458432443 ps} {2028503556 ps}
