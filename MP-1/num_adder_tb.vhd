-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: num_adder_tb.vhd                                               --
-- Author: Blake Vermeer													 --
-- Date: 9/22/2014                                                           --
--                                                                           --
-- Description: Testbench for MP1_top: Test the num adder addition		     --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


entity num_adder_tb is
end num_adder_tb;

architecture rtl of num_adder_tb is

----------------------------------------------
--       Component declarations             --
----------------------------------------------

-- Component that get put on the FPGA
component num_adder 
    Port ( clk       	: in  STD_LOGIC;
	       reset     	: in STD_LOGIC;
           new_data  	: in  STD_LOGIC; -- Indicate a new byte has been captured from UART
           data_in   	: in  STD_LOGIC_VECTOR (7 downto 0);
           TX_busy_n 	: in  STD_LOGIC;
           send_data 	: out  STD_LOGIC; -- Request UART to transmit data_out
           data_out  	: out  STD_LOGIC_VECTOR (7 downto 0)
	     );
end component;




----------------------------------------------
--          Signal declarations             --
----------------------------------------------
signal system_clk : std_logic := '0';  -- system clock
signal reset    : std_logic := '1';  -- Reset active low

signal new_data_sig : std_logic := '0'; --Signal to signal new data
signal input_data : std_logic_vector ( 7 downto 0) := (others => '0') ; --Input data 
signal TX_busy_signal : std_logic := '0'; --UART busy signal
signal send_data_sig : std_logic ; --Signal to send new data
signal output_data : std_logic_vector ( 7 downto 0) ; --Data to send


--Clock period definition
constant clk_period : time := 1ns;

begin


-- Processes

-------------------------------------------
-------------------------------------------
-- Process Name: system_clk_gen          --
--                                       --
-- Description: Generate clock to run the --
-- simulation.                           --
--                                       --
--                                       --
-------------------------------------------
-------------------------------------------  
system_clk_gen : process
begin
  system_clk <= '0';
  wait for 10 ns;
    loop
      wait for clk_period;
      system_clk <= '1';
      wait for clk_period;
      system_clk <= '0';
    end loop;
end process system_clk_gen;


-------------------------------------------
-------------------------------------------
-- Process Name: toggle_reset            --
--                                       --
-- Description: Generate clock to run the --
-- simulation.                           --
--                                       --
--                                       --
-------------------------------------------
-------------------------------------------  
toggle_reset : process
begin
  reset <= '1'; -- place circuit in reset
  wait for 100 ns;
  reset <= '0'; 
  wait;
end process toggle_reset;


-- Combinational assignments
stim_proc : process

	--Wait for the reset to finish
	wait for 10 ns;

	--Input 0
	input_data <= x"48";

	wait for clk_period;

	new_data_sig <= '1'; 

	wait for clk_period;

	new_data_sig <= '0';

	wait for clk_period;

	TX_busy_signal <= '1';

	wait for clk_period;

	TX_busy_signal <= '0';


end process stim_proc;



  -- Port map MP1_top
UART_HW : MP1_top  
port map
(
	clk => system_clk,
	reset => reset.
	new_data => new_data_sig.
	data_in => input_data,
	TX_busy_n => TX_busy_signal.
	send_data => send_data_sig,
	data_out => output_data
);



end rtl;

