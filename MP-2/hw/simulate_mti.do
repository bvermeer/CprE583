#vdel -all
vmap unisim /remote/Xilinx/13.4/ISE/vhdl/mti_se/10.1c/lin64/unisim
vmap secureip /remote/Xilinx/13.4/ISE/verilog/mti_se/10.1c/lin64/secureip

vlib work_sim
vmap work work_sim

vcom -work work_sim ./vhdl/client/MP2_scanner.vhd
vcom -work work_sim ./vhdl/client/address_swap_module_8.vhd
vcom -work work_sim ./vhdl/client/fifo/tx_client_fifo_8.vhd
vcom -work work_sim ./vhdl/client/fifo/rx_client_fifo_8.vhd
vcom -work work_sim ./vhdl/client/fifo/eth_fifo_8.vhd
vcom -work work_sim ./vhdl/physical/gmii_if.vhd
vcom -work work_sim ./vhdl/v5_emac_v1_4.vhd
vcom -work work_sim ./vhdl/v5_emac_v1_4_block.vhd
vcom -work work_sim ./vhdl/v5_emac_v1_4_locallink.vhd
vcom -work work_sim ./vhdl/temac_clk_gen.vhd
vcom -work work_sim ./vhdl/v5_emac_v1_4_example_design.vhd
vcom -work work_sim ./simulation/configuration_tb.vhd
vcom -work work_sim ./simulation/emac0_phy_tb.vhd
vcom -work work_sim ./simulation/demo_tb.vhd
vsim -voptargs="+acc" -t ps work.testbench
do wave_mti.do
run 50 us

