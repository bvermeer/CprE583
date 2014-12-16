----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:21:00 09/08/2011 
-- Design Name: 
-- Module Name:    help_msg - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Create and send out the help message 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity help_msg is
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
end help_msg;


architecture Behavioral of help_msg is

-- Signals
-- Signals for the data_out_reg
signal data_out_reg 	: std_logic_vector ( 7 downto 0) ;
signal data_out_reg_in  : std_logic_vector ( 7 downto 0) ;
signal data_out_reg_en 	: std_logic ; 

--State machine signals
type state_type is (ST_RST, ST_NCHAR, ST_TRANS);
signal PS, NS : state_type;

-- Signals for counter
signal counter_reg 			: integer ;
signal counter_count_up 	: std_logic ; 
signal counter_reset 		: std_logic ; 
signal counter_reset_sig 	: std_logic ; 


-- constants
-- Help message
-- constant HELP_MSG : string := "Command" & HT & "Description" & CR & 
--                              "?" & HT & "Help screen" & CR &
--						      "s" & HT & "Set random seed" & CR;

type help_string is array (0 to 5) of std_logic_vector(7 downto 0);
constant HELP_MSG : help_string := (x"48", x"65", x"6C", x"70", x"0A", x"0D");


begin

	-- Send out the help message and then return control to cmd_parse 
	--Synchronous process for the state machine (with synchronous reset) 
	sync_proc : process(clk, NS)
	begin
		--Trigger on the rising edge
		if(clk'event and clk = '1') then
		  
		  if(reset = '1') then  -- Enter the reset state 
		  		PS <= ST_RST;
		  else 
				PS <= NS;
			end if;
		end if;
	end process sync_proc; 


	--Combinational process for the state machine
	comb_proc : process(PS, TX_busy_n, enable)

       -- variable cnt : integer := 0;

	begin
		
		--Set the default value for the signals to avoid inferring latches
		send_data <= '0';
        data_out_reg_en <= '0';
        data_out_reg_in <= (others => '0') ; 

        -- Counter default values
        counter_reset_sig <= '0';
        counter_count_up <= '0';
		  
		  -- Default value for done signal
		  done <= '0';


		case PS is 
			--This state is entered on reset and clears the regs
			when ST_RST =>

                -- Reset the counter
                counter_reset_sig <= '1';
					 

                --cnt := 0;

				-- Wait for the enable signal
                if ( enable = '1' ) then
						NS <= ST_NCHAR;
                else
                    NS <= ST_RST;
                end if;

			-- This state prepares the next character to send over UART
			when ST_NCHAR =>

                -- Store the byte to send in the data_out register
                data_out_reg_in <= HELP_MSG(counter_reg);
                data_out_reg_en <= '1';

                -- Increase the counter value
                counter_count_up <= '1';
					 
					 --cnt := cnt + 1;

					NS <= ST_TRANS;

            -- For for the UART to become free and then transmit the next byte
            when ST_TRANS =>

	           if(TX_busy_n = '1') then -- Check if UART is busy transmitting already
	        	  send_data <= '1';     -- tell UART to transmit a byte 

                  if ( counter_reg = HELP_MSG'Length ) then

                      done <= '1';

                      NS <= ST_RST;
                  else
                      NS <= ST_NCHAR;
                  end if;

                else

                    NS <= ST_TRANS;

	            end if;


			
			when others =>
				NS <= ST_RST;

		end case;

	end process comb_proc;




--D Flip-Flop for data_out_reg
data_out_reg_proc : process(clk)
begin
        
    if(falling_edge(clk)) then

        if(reset = '1') then

            data_out_reg <= (others => '0') ; 

        else

            if(data_out_reg_en = '1') then

                data_out_reg <= data_out_reg_in;

            end if;

        end if;

    end if;

end process data_out_reg_proc;




-- Counter with reset and count enable
counter_proc : process(clk)
begin
        
    if(falling_edge(clk)) then

        if(counter_reset = '1') then

            counter_reg <= 0 ; 

        else

            if(counter_count_up = '1') then

               counter_reg <= counter_reg + 1; 

            end if;

        end if;

    end if;

end process counter_proc;




-- Map data_out to data_out_reg
data_out <= data_out_reg;

-- Counter reset signal
counter_reset <= reset or counter_reset_sig;


end Behavioral;
