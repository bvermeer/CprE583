----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:21:00 09/08/2011 
-- Design Name: 
-- Module Name:    echo - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Echo data recived from the UART back to the PC
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

entity echo is
    Port ( clk       : in  STD_LOGIC;
	        reset     : in STD_LOGIC;
           new_data  : in  STD_LOGIC; -- Indicate a new byte has been captured from UART
           data_in   : in  STD_LOGIC_VECTOR (7 downto 0);
           TX_busy_n : in  STD_LOGIC;
           send_data : out  STD_LOGIC; -- Request UART to transmit data_out
           data_out  : out  STD_LOGIC_VECTOR (7 downto 0)
			);
end echo;

architecture Behavioral of echo is

-- Components
  -- None
  
-- signals
signal rdy_send_data_reg : std_logic; -- Indicate there is that is ready to be sent
signal send_data_reg  : std_logic; -- Tell UART to send a byte of data
signal data_out_reg   : std_logic_vector(7 downto 0); -- Temp storage for new data

begin

--Echo what was received back to the sender
process(clk)
begin
if(clk'event and clk = '1') then
  
  if(reset = '1') then  -- reset registers
    rdy_send_data_reg <= '0';
	 send_data_reg     <= '0';
    data_out_reg      <= (others => '0');	 
  else 
  
    -- default
	 send_data_reg <= '0';
  
    if(new_data = '1') then  -- recieved new data from UART
	   rdy_send_data_reg <= '1';  -- keep high until the UART is ready for us
		                           -- to transmit a byte
		 
       ---------------------------------------------------
		 -- Your VHDL below here: for the first part of MP-1
		 -- that has you convert from lower case to upper 
		 -- case ONLY.  For all other parts you should make your
		 -- own entity
		 ---------------------------------------------------
						
											
	   data_out_reg  <= data_in;  -- capture the new byte
		
		
		 ----------------------------------------------------------
		 -- Your VHDL above here: for the first part of MP-1 only 
		 -- for all other parts you should make your own entity  
		 ----------------------------------------------------------
		
    elsif(rdy_send_data_reg = '1') then
	   if(TX_busy_n = '1') then -- Check if UART is busy transmitting already
		  rdy_send_data_reg <= '0'; -- reset this signal
		  send_data_reg <= '1';     -- tell UART to transmit a byte 
		end if;
	 end if;
  
  end if;
	 
end if;
end process; 

-- Assign outputs
send_data <= send_data_reg;
data_out  <= data_out_reg;


end Behavioral;
