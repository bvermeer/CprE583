onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate -radix hexadecimal /testbench/reset
add wave -noupdate -radix hexadecimal /testbench/tx_client_clk_0
# add wave -noupdate -radix hexadecimal /testbench/tx_ifg_delay_0
# add wave -noupdate -radix hexadecimal /testbench/rx_client_clk_0
# add wave -noupdate -radix hexadecimal /testbench/pause_val_0
# add wave -noupdate -radix hexadecimal /testbench/pause_req_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_tx_clk_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_tx_en_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_tx_er_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_txd_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_rx_clk_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_rx_dv_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_rx_er_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_rxd_0
# add wave -noupdate -radix hexadecimal /testbench/mii_tx_clk_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_crs_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_col_0
# add wave -noupdate -radix hexadecimal /testbench/host_clk
# add wave -noupdate -radix hexadecimal /testbench/sys_clk
# add wave -noupdate -radix hexadecimal /testbench/refclk
# add wave -noupdate -radix hexadecimal /testbench/emac0_configuration_busy
# add wave -noupdate -radix hexadecimal /testbench/emac0_monitor_finished_1g
# add wave -noupdate -radix hexadecimal /testbench/emac0_monitor_finished_100m
# add wave -noupdate -radix hexadecimal /testbench/emac0_monitor_finished_10m
# add wave -noupdate -radix hexadecimal /testbench/emac1_configuration_busy
# add wave -noupdate -radix hexadecimal /testbench/emac1_monitor_finished_1g
# add wave -noupdate -radix hexadecimal /testbench/emac1_monitor_finished_100m
# add wave -noupdate -radix hexadecimal /testbench/emac1_monitor_finished_10m
# add wave -noupdate -radix hexadecimal /testbench/config_test/reset
# add wave -noupdate -radix hexadecimal /testbench/config_test/host_clk
# add wave -noupdate -divider {testbench: emace0_phy_tb}
# add wave -noupdate -radix ascii /testbench/phy0_test/gmii_txd
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_tx_en
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_tx_er
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_tx_clk
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rxd
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rx_dv
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rx_er
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rx_clk
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_col
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_crs
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/mii_tx_clk
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/configuration_busy
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/monitor_finished_1g
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/monitor_finished_100m
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/monitor_finished_10m
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/mii_tx_clk_int
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/mii_tx_clk100
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/mii_tx_clk10
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rx_clk_int
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rx_clk1000
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rx_clk100
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/gmii_rx_clk10
# add wave -noupdate -radix hexadecimal /testbench/phy0_test/current_speed
# add wave -noupdate -divider {testbench: configuration_tb}
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac0_configuration_busy
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac0_monitor_finished_1g
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac0_monitor_finished_100m
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac0_monitor_finished_10m
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac1_configuration_busy
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac1_monitor_finished_1g
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac1_monitor_finished_100m
# add wave -noupdate -radix hexadecimal /testbench/config_test/emac1_monitor_finished_10m
# add wave -noupdate -radix hexadecimal /testbench/config_test/hostclk
add wave -noupdate -divider {Top_level v5_emacs_v1_4_example}
add wave -noupdate -radix hexadecimal /testbench/dut/sys_clk
add wave -noupdate -radix hexadecimal /testbench/dut/RESET
add wave -noupdate -radix hexadecimal /testbench/dut/reset_i
add wave -noupdate -radix hexadecimal /testbench/dut/reset_inv
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_0
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_1
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_2
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_3
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_4
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_5
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_6
add wave -noupdate -radix hexadecimal /testbench/dut/GPIO_LED_7
add wave -noupdate -radix ascii /testbench/dut/GMII_TXD_0
# add wave -noupdate -radix hexadecimal /testbench/dut/GMII_TX_EN_0
# add wave -noupdate -radix hexadecimal /testbench/dut/GMII_TX_ER_0
# add wave -noupdate -radix hexadecimal /testbench/dut/GMII_TX_CLK_0
# add wave -noupdate -radix hexadecimal /testbench/dut/GMII_RXD_0
# add wave -noupdate -radix hexadecimal /testbench/dut/GMII_RX_DV_0
# add wave -noupdate -radix hexadecimal /testbench/dut/GMII_RX_ER_0
# add wave -noupdate -radix hexadecimal /testbench/dut/GMII_RX_CLK_0
add wave -noupdate -radix hexadecimal /testbench/dut/ll_clk_0_i
add wave -noupdate -radix ascii /testbench/dut/tx_ll_data_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/tx_ll_sof_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/tx_ll_eof_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/tx_ll_src_rdy_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/tx_ll_dst_rdy_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/rx_ll_data_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/rx_ll_sof_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/rx_ll_eof_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/rx_ll_src_rdy_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/rx_ll_dst_rdy_n_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/ll_pre_reset_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/ll_reset_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/refclk_ibufg_i
# add wave -noupdate -radix hexadecimal /testbench/dut/refclk_bufg_i
# add wave -noupdate -radix hexadecimal /testbench/dut/tx_clk_0
# add wave -noupdate -radix hexadecimal /testbench/dut/rx_clk_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/gmii_rx_clk_0_delay
# add wave -noupdate -radix hexadecimal /testbench/dut/idelayctrl_reset_0_r
# add wave -noupdate -radix hexadecimal /testbench/dut/idelayctrl_reset_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/gtx_clk_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTRXDVLD
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTRXFRAMEDROP
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTRXSTATS
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTRXSTATSVLD
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTRXSTATSBYTEVLD
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTTXSTATS
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTTXSTATSVLD
# add wave -noupdate -radix hexadecimal /testbench/dut/EMAC0CLIENTTXSTATSBYTEVLD
# add wave -noupdate -radix hexadecimal /testbench/dut/CLIENTEMAC0TXIFGDELAY
# add wave -noupdate -radix hexadecimal /testbench/dut/CLIENTEMAC0PAUSEREQ
# add wave -noupdate -radix hexadecimal /testbench/dut/CLIENTEMAC0PAUSEVAL
# add wave -noupdate -divider {EMAC0 Tx Client Interface}
# add wave -noupdate -label tx_client_clk_0 -radix hexadecimal /testbench/dut/tx_clk_0
# add wave -noupdate -radix hexadecimal /testbench/dut/v5_emac_ll/tx_data_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/v5_emac_ll/tx_data_valid_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/v5_emac_ll/tx_ack_0_i
# add wave -noupdate -radix hexadecimal /testbench/tx_ifg_delay_0
# add wave -noupdate -divider {EMAC0 Rx Client Interface}
# add wave -noupdate -label rx_client_clk_0 -radix hexadecimal /testbench/dut/rx_clk_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/v5_emac_ll/rx_data_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/v5_emac_ll/rx_data_valid_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/v5_emac_ll/rx_good_frame_0_i
# add wave -noupdate -radix hexadecimal /testbench/dut/v5_emac_ll/rx_bad_frame_0_i
# add wave -noupdate -divider {EMAC0 Flow Control}
# add wave -noupdate -radix hexadecimal /testbench/pause_val_0
# add wave -noupdate -radix hexadecimal /testbench/pause_req_0
# add wave -noupdate -divider {EMAC0 Tx GMII/MII Interface}
# add wave -noupdate -radix hexadecimal /testbench/gmii_tx_clk_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_txd_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_tx_en_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_tx_er_0
# add wave -noupdate -divider {EMAC0 Rx GMII/MII Interface}
# add wave -noupdate -radix hexadecimal /testbench/gmii_rx_clk_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_rxd_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_rx_dv_0
# add wave -noupdate -radix hexadecimal /testbench/gmii_rx_er_0
# add wave -noupdate -divider address_swap
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_clock
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_reset
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_data_in_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_sof_in_n_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_eof_in_n_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_src_rdy_in_n_scn
# add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/rx_ll_data_out
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_sof_out_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_eof_out_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_src_rdy_out_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_dst_rdy_in_n_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/sel_delay_path
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/enable_data_sr
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/data_sr5
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/mux_out
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_enable
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/control_fsm_state
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/data_sr_content
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/eof_sr_content
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/sof_sr_content
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rdy_sr_content
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_data_in
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_sof_in_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_eof_in_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_src_rdy_in_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/rx_ll_dst_rdy_in_n
add wave -noupdate -divider MP2_scanner
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_clock
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_reset
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_sof_in_n_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_eof_in_n_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_src_rdy_in_n_scn
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_dst_rdy_in_n_scn
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_0
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_1
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_2
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_3
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_4
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_5
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_6
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/GPIO_LED_7
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/corn_counter
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ece_counter
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/gataga_counter
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_sof_in_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_eof_in_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_src_rdy_in_n
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_dst_rdy_in_n
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/scan_state
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/scan_state_next
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in_scn_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_sof_in_n_scn_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_eof_in_n_scn_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_src_rdy_in_n_scn_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_dst_rdy_in_n_scn_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_sof_in_n_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_eof_in_n_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_src_rdy_in_n_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_dst_rdy_in_n_reg
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_scn_dly
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/sof_n_scn_dly
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/eof_n_scn_dly
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/src_rdy_n_scn_dly
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/dst_rdy_n_scn_dly
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ip_src_shift_reg
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ip_dst_shift_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/eth_index_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ip_index_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/udp_payload_index_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/udp_len_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ip_src_addr_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ip_dst_addr_reg
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/src_insert_shift_reg
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/dst_insert_shift_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/zero_udp_cksum_insert_shift_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/data_out_sel
add wave -noupdate -radix ascii /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_data_in_insert
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/eth_start_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/eth_end_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ld_ip_index_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ld_src_ip_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ld_dst_ip_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/ld_udp_len_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/start_scan_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/wr_src_IP_flag
# add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/wr_dst_IP_flag
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/wr_zero_udp_cksum
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/pause_flag
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/rx_ll_src_rdy_in_n_mux
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/eof_pend_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/packet_done_reg
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/corn_state
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/corn_state_next
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/corn_flag
add wave -noupdate -radix hexadecimal /testbench/dut/client_side_asm_emac0/my_MP2_scanner/corn_flag_LED_reg
add wave -noupdate -divider {Test semaphores}
add wave -noupdate -radix hexadecimal /testbench/emac0_configuration_busy
add wave -noupdate -radix hexadecimal /testbench/emac0_monitor_finished_1g
add wave -noupdate -radix hexadecimal /testbench/emac0_monitor_finished_100m
add wave -noupdate -radix hexadecimal /testbench/emac0_monitor_finished_10m
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30938250 ps} 0}
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
WaveRestoreZoom {30900985 ps} {31003525 ps}
