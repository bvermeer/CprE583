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

-- Components
  -- None
 
-- signals
signal rdy_send_data_reg 			: std_logic; -- Indicate there is that is ready to be sent
signal send_data_reg  				: std_logic; -- Tell UART to send a byte of data
signal data_out_reg   				: std_logic_vector(7 downto 0); -- Temp storage for new data
signal num_last_rec_flag			: std_logic; --This flag is sent when the last character echoed was 0-4
signal is_num_flag					: std_logic; --This flag is set when the current char is 0-4
signal last_num						: std_logic_vector (7 downto 0); -- Temp storage for last transmitted number 



--State machine signals
type state_type is (ST_RST, ST_WAIT, ST_READY, ST_TRANSMITT);
signal PS, NS : state_type;


begin

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
	end process sync_proc; 


	--Combinational process for the state machine
	comb_proc : process(PS)
	begin
		
		case PS is 
			--This state is entered on reset and clears the regs
			when ST_RST =>
				--Clear the registers
				last_num <= (others => '0');
		    	rdy_send_data_reg 	<= '0';
				send_data_reg     	<= '0';
		    	data_out_reg      	<= (others => '0');	 

				--Set the next state to ST_WAIT
				NS <= ST_WAIT;


			--This state is entered when waiting for new data
			--from the UART
			when ST_WAIT =>

				if(new_data = '1') then

					--Capture the new data
					data_out_reg <= data_in;

					--Check if the new data being received is 0-4
					if ( (data_in = x"30") OR 
						 (data_in = x"31") OR 
						 (data_in = x"32") OR 
						 (data_in = x"33") OR 
						 (data_in = x"34")  ) then
						
							is_num_flag <= '1';

					else

						is_num_flag <= '0';
						
						end if ;

					NS <= ST_READY;

				end
			
			--This state is entered after data has been received and is 
			--waiting to be transmitted
			when ST_READY =>

				--Wait for the UART to be ready to transmit
				if(TX_busy_n = '1') then
					
					NS <= ST_TRANSMITT;

				end

			--Data is sent to the UART in this state 
			when ST_TRANSMITT =>

				

			when others =>
				NS <= ST_RST;

		end case;

	end process comb_proc;



-- Assign outputs
send_data <= send_data_reg;
data_out  <= data_out_reg;


end Behavioral;
