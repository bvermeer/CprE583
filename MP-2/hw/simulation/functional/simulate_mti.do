vmap unisims_ver /remote/Xilinx/ISE/vhdl/mti_se/unisim
vmap secureip /remote/Xilinx/ISE/verilog/mti_se/secureip
vlib work
vmap work work

vcom -work work ../../example_design/client/MP1_scanner.vhd
vcom -work work ../../example_design/client/address_swap_module_8.vhd
vcom -work work ../../example_design/client/fifo/tx_client_fifo_8.vhd
vcom -work work ../../example_design/client/fifo/rx_client_fifo_8.vhd
vcom -work work ../../example_design/client/fifo/eth_fifo_8.vhd
vcom -work work ../../example_design/physical/gmii_if.vhd
vcom -work work ../../example_design/v5_emac_v1_4.vhd
vcom -work work ../../example_design/v5_emac_v1_4_block.vhd
vcom -work work ../../example_design/v5_emac_v1_4_locallink.vhd
vcom -work work ../../example_design/temac_clk_gen.vhd
vcom -work work ../../example_design/v5_emac_v1_4_example_design.vhd
vcom -work work ../configuration_tb.vhd
vcom -work work ../emac0_phy_tb.vhd
vcom -work work ../demo_tb.vhd
vsim -voptargs="+acc" -t ps work.testbench
do wave_mti.do
run -all
