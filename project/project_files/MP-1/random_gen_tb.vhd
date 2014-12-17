-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: random_gen_tb.vhd                                               --
-- Author: Blake Vermeer                                                     --
-- Date: 12/9/2014                                                           --
--                                                                           --
-- Description: Testbench for cmd_parse.vhd                                  --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity random_gen_tb is
port
(
    my_in : in std_logic --input to keep modelsim from complaining
);
end random_gen_tb;

architecture rtl of random_gen_tb is

----------------------------------------------
--       Component declarations             --
----------------------------------------------

-- Component that get put on the FPGA
COMPONENT random_gen
    Port ( 	clk 			: in std_logic;
				rst 			: in std_logic;
				enable 		: in std_logic;	-- start random number generation process
				new_data 	: in std_logic;
				TX_busy_n 	: in std_logic; 	-- Indicate a new byte has been captured from UART
				data_in		: in std_logic_vector(7 downto 0);
				send_data	: out std_logic;	-- Request UART to transmit data_out
				done			: out std_logic;	-- Indicate that output has finished transmitting
				data_out 	: out std_logic_vector(7 downto 0); -- byte of the random_number to be sent out
				random_num 	: out std_logic_vector(255 downto 0); -- random number being generated every clock cycle
			
				debug_state	: out std_logic_vector(7 downto 0)
			);
end COMPONENT;

----------------------------------------------
--          Signal declarations             --
----------------------------------------------
signal system_clk 	: std_logic ;  -- system clock
signal reset    	: std_logic ;  -- Reset active low
signal new_data 	: std_logic ; 
signal enable		: std_logic ;
signal done			: std_logic	;
signal random_num	: std_logic_vector(255 downto 0) ;
signal data_in 		: std_logic_vector ( 7 downto 0) ;
signal TX_busy_n 	: std_logic ; 
signal send_data    : std_logic ; 
signal data_out 	: std_logic_vector ( 7 downto 0) ; 

signal debug_state	: std_logic_vector(7 downto 0);

-- signal debug_state  : std_logic_vector ( 3 downto 0) ;
-- signal debug_date_in_reg : std_logic_vector ( 7 downto 0) ;
-- signal debug_help_msg_done : std_logic ; 


constant clk_period : time := 1 ns;


begin


-- Processes

-------------------------------------------
-------------------------------------------
-- Process Name: system_clk_gen          --
--                                       --
-- Description: Generat clock to run the --
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
-- Description: Generat clock to run the --
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


-------------------------------------------
-------------------------------------------
-- Process Name: sim_tx                  --
--                                       --
-- Description: simulate the TX done     --
-- signal.                               --
--                                       --
--                                       --
-------------------------------------------
-------------------------------------------  
sim_tx : process
begin

    TX_busy_n <= '1';

    wait for clk_period;

    wait until send_data = '1';

    TX_busy_n <= '0';

    wait for 50 ns;

end process sim_tx;



-------------------------------------------
-------------------------------------------
-- Process Name: main_stim               --
--                                       --
-- Description: Main driving process     --
--                                       --
--                                       --
--                                       --
-------------------------------------------
-------------------------------------------  
main_stim : process
begin

    new_data 	<= '0'; 
    data_in 	<= (others => '0') ; 	
	 enable		<= '0';
    
    wait for 150 ns;
	 
	 enable 		<= '1';
	 
	 wait for clk_period;

    data_in    <= x"39";

    wait for clk_period; 

    new_data <= '1';

    wait for clk_period;

    new_data <= '0';

	 data_in    <= x"30";

    wait for clk_period; 

    new_data <= '1';

    wait for clk_period;

    new_data <= '0';

    wait for clk_period;

    data_in <= x"00";

    wait for 20 us;


end process main_stim;


-- Combinational assignments


  -- Port map MP1_top_driver
Random_Gen_Driver : random_gen 
port map
(
    clk        => system_clk,	
	 rst       	=> reset,
	 enable  	=> enable,
	 new_data 	=> new_data,
    data_in   	=> data_in,
    TX_busy_n 	=> TX_busy_n,
    send_data 	=> send_data,
	 done 		=> done,
    data_out  	=> data_out,
	 random_num	=> random_num,
	 
	 debug_state => debug_state
);

end rtl;
