----------------------------------------------------------------------------------
-- Company: CprE 583 
-- Engineer: Blake Vermeer
-- 
-- Create Date:    09/21/2014 
-- Design Name: 
-- Module Name:    num_adder - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Echo data received from the UART back to the PC unless there are
--				two current numbers. Then echo the number and the sum of the 
--				previous two numbers.
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity num_adder is
    Port ( clk       	: in  STD_LOGIC;
           reset     	: in STD_LOGIC;
           new_data  	: in  STD_LOGIC; -- Indicate a new byte has been captured from UART
           data_in   	: in  STD_LOGIC_VECTOR (7 downto 0);
           TX_busy_n 	: in  STD_LOGIC;
           send_data 	: out  STD_LOGIC; -- Request UART to transmit data_out
           data_out  	: out  STD_LOGIC_VECTOR (7 downto 0)
	     );
end num_adder;

architecture Behavioral of num_adder is

----------------------------------------------------------------------------- 
-- Component Declaration
----------------------------------------------------------------------------- 
COMPONENT num_check
    PORT ( clk       	: IN  STD_LOGIC;
           in_one		: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
           in_two 		: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
           both_nums	: OUT  STD_LOGIC
	     );
END COMPONENT;
 
-- signals
signal send_data_reg  				: std_logic; -- Tell UART to send a byte of data
signal data_out_reg   				: std_logic_vector(7 downto 0); -- Temp storage for new data
signal data_out_reg_in              : std_logic_vector(7 downto 0); -- Input to the data_out_reg D Flip-Flop
signal data_out_reg_en              : std_logic; --Enable for the data_out_reg D Flip-Flop
signal last_two_num_flag			: std_logic; --This flag is set when the last two character received were both numbers from 0-4
signal current_data_in_reg			: std_logic_vector (7 downto 0); -- Temp storage for current received character
signal current_data_in_reg_en       : std_logic; --Enable input for the current_data_in_reg D Flip-Flop
signal last_data_in_reg				: std_logic_vector (7 downto 0); -- Temp storage for last received character


--State machine signals
type state_type is (ST_RST, ST_WAIT, ST_READY, ST_TRANSMIT, ST_READY2, ST_TRANSMIT2);
signal PS, NS : state_type;


begin

CONSECUTIVE_NUMBERS : num_check 
PORT MAP
(
	clk       	=> clk,
	in_one 		=> last_data_in_reg,
	in_two 		=> current_data_in_reg,
	both_nums 	=> last_two_num_flag
);


	--Echo what was received back to the sender
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
	comb_proc : process(PS, new_data, TX_busy_n)
	begin
		
		--Set the default value for the signals to avoid inferring latches
		send_data_reg <= '0';
        current_data_in_reg_en <= '0';
		data_out_reg_en <= '0';
        data_out_reg_in <= (others => '0') ; 


		case PS is 
			--This state is entered on reset and clears the regs
			when ST_RST =>

				--Set the next state to ST_WAIT
				NS <= ST_WAIT;

			--This state is entered when waiting for new data
			--from the UART
			when ST_WAIT =>

				if(new_data = '1') then

					--Capture the new data and save the last data
					data_out_reg_in <= data_in;
					data_out_reg_en <= '1';
                    current_data_in_reg_en <= '1'; 


					NS <= ST_READY;

                else

                    NS <= ST_WAIT;

				end if;

			
			--This state is entered after data has been received and is waiting to be transmitted
			when ST_READY =>

				--Wait for the UART to be ready to transmit
				if(TX_busy_n = '1') then
					
					NS <= ST_TRANSMIT;

                else

                    NS <= ST_READY;

				end if;



			--Data is sent to the UART in this state 
			when ST_TRANSMIT =>

				send_data_reg <= '1';

				if(last_two_num_flag = '1') then

					NS <= ST_READY2;

				else

					NS <= ST_WAIT;

				end if;


            --Wait to transmit the second data byte
            when ST_READY2 =>
					
				data_out_reg_in <= std_logic_vector((unsigned(current_data_in_reg) - 48) + (unsigned(last_data_in_reg) - 48) + 48);
                data_out_reg_en <= '1';

				--Wait for the UART to be ready to transmit
				if(TX_busy_n = '1') then
					
					NS <= ST_TRANSMIT2;

                else

                    NS <= ST_READY2;

				end if;



			--Data is sent to the UART in this state 
			when ST_TRANSMIT2 =>

				send_data_reg <= '1';

				NS <= ST_WAIT;




			when others =>
				NS <= ST_RST;

		end case;

	end process comb_proc;



--D Flip-Flop for current_data_in_reg and last_data_in_reg
current_data_in_reg_proc : process(clk)
begin
        
    if(rising_edge(clk)) then

        if(reset = '1') then

            current_data_in_reg <= (others => '0') ; 
            last_data_in_reg <= (others => '0') ; 

        else

            if(current_data_in_reg_en = '1') then

                --Capture the current data and also move the previous data to last_data_in_reg
                current_data_in_reg <= data_in;
                last_data_in_reg <= current_data_in_reg;

            end if;

        end if;

    end if;

end process current_data_in_reg_proc ;




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




-- Assign outputs
send_data <= send_data_reg;
data_out  <= data_out_reg;


end Behavioral;
