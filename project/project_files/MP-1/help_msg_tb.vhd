-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: help_msg_tb.vhd                                                --
-- Author: Blake Vermeer                                                     --
-- Date: 12/9/2014                                                           --
--                                                                           --
-- Description: Testbench for help_msg                                       --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


entity help_msg_tb is
port
(
my_in : in std_logic -- input need to keep modelsim from                        
                     -- compaining???
);
end help_msg_tb;

architecture rtl of help_msg_tb is

----------------------------------------------
--       Component declarations             --
----------------------------------------------

-- Component that get put on the FPGA
  -- Help message component
  COMPONENT help_msg
    PORT ( clk 			: IN std_logic ; 
           reset 		: IN std_logic ; 
           enable 		: IN std_logic ;  -- Signal to start the module 
           new_data 	: IN std_logic ; 
           data_in 		: IN std_logic_vector ( 7 downto 0) ; 
           TX_busy_n 	: IN std_logic ; 
           send_data 	: OUT  std_logic ; 
           done         : OUT std_logic ;  -- Signal to indicate when the module is done 
           data_out 	: OUT std_logic_vector ( 7 downto 0)
         );
  END COMPONENT;

----------------------------------------------
--          Signal declarations             --
----------------------------------------------
signal system_clk 	: std_logic ;  -- system clock
signal reset    	: std_logic ;  -- Reset active low
signal enable 		: std_logic ; 
signal new_data 	: std_logic ; 
signal data_in 		: std_logic_vector ( 7 downto 0) ;
signal TX_busy_n 	: std_logic ; 
signal done 		: std_logic ; 
signal data_out 	: std_logic_vector ( 7 downto 0) ; 
signal send_data    : std_logic ; 


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
      wait for 1 ns;
      system_clk <= '1';
      wait for 1 ns;
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

    wait for 1 ns;

    wait until send_data = '1';

    TX_busy_n <= '0';

    wait for 800 us;

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

    enable 		<= '0';	
    new_data 	<= '0'; 
    data_in 	<= (others => '0') ; 	
    
    wait for 150 ns;

    enable      <= '1';

    wait for 200 ns;


end process main_stim;


-- Combinational assignments


  -- Port map MP1_top_driver
UART_driver : help_msg 
port map
(
    clk 		=> system_clk,	
    reset 		=> reset,	
    enable 		=> enable,	
    new_data 	=> new_data, 
    data_in 	=> data_in,	
    TX_busy_n 	=> TX_busy_n,
    send_data 	=> send_data,
    done    	=> done, 
    data_out 	=> data_out 
);



end rtl;
