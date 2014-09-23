----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:40:11 09/08/2011 
-- Design Name: 
-- Module Name:    process_data - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Process data recived by the UART, and send a response back to the PC
-- over the UART interface
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

entity process_data is
    Port ( clk : in  STD_LOGIC;
	        reset : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0); -- Data from the UART
           RX_full : in  STD_LOGIC; -- Indicate a is available from the UART
           TX_busy_n : in  STD_LOGIC; -- Indicate UART busy transmitting
           RD_n : out  STD_LOGIC; -- Read a byte from the UART
           WR_n : out  STD_LOGIC; -- Write a byte to the UART
           data_out : out  STD_LOGIC_VECTOR (7 downto 0) -- Data for UART to transmit
           );
end process_data;

architecture mixed of process_data is

-- Component declarations

-- Component that echos data recived from the PC
-- back to the PC.
component num_adder
port
		   ( clk       	: in  STD_LOGIC;
	        reset     	: in STD_LOGIC;
           new_data  	: in  STD_LOGIC; -- Indicate a new byte has been captured from UART
           data_in   	: in  STD_LOGIC_VECTOR (7 downto 0);
           TX_busy_n 	: in  STD_LOGIC;
           send_data 	: out  STD_LOGIC; -- Request UART to transmit data_out
           data_out  	: out  STD_LOGIC_VECTOR (7 downto 0)
			);
end component;

-- signal declarations

  -- reading data from the UART
signal data_in_reg : std_logic_vector(7 downto 0); -- temp store incomming data
signal RX_full_reg: std_logic; -- One clock delayed version of RX_full
signal RD_n_reg : std_logic; -- Read byte from UART

  -- writing data to the UART
signal data_out_reg : std_logic_vector(7 downto 0);  -- Data for the UART to transmit
signal data_to_send : std_logic_vector(7 downto 0); -- Temp signal to connect component
signal WR_n_reg     : std_logic; -- active low, tells UART to transmit a byte 

  -- temp signals
signal new_data_reg : std_logic;
signal send_data : std_logic;


begin


-- Get data from UART
process(clk)
begin

if(clk'event and clk = '1') then
  if(reset = '1') then
    RX_full_reg    <= '0';
	 RD_n_reg       <= '1';  -- active low
	 new_data_reg   <= '0';
	 data_in_reg    <= (others => '0');
  else    
	 
    RX_full_reg <= RX_full; -- keep track of the last value of RX_full
	 
    if(RX_full = '1' and RX_full_reg = '0') then -- check if a new byte has arrived
	   RD_n_reg <= '0';  -- Active low: Get byte from UART (will be aviable next clock cycle)
		new_data_reg <= '0'; 
	   data_in_reg <= data_in_reg;
    elsif(RD_n_reg = '0') then
	   RD_n_reg <= '1';
		new_data_reg <= '1';  -- tell subcomponent a new byte has been captured
	   data_in_reg <= data_in; -- store the new byte
	 else
	   RD_n_reg <= '1'; 
	   new_data_reg <= '0';
		data_in_reg <= data_in_reg;
    end if;	 
  end if;
end if;

end process;


-- Send Data to UART
process(clk)
begin

if(clk'event and clk = '1') then
  if(reset = '1') then
    data_out_reg  <= (others => '0');
    WR_n_reg      <= '1'; -- active low  
  else
    if(send_data = '1') then -- lower level component has a byte to send,
	                          -- and has check that the UART free from transmitting  
	   WR_n_reg <= '0';  -- Tell the UART to transmit
	   data_out_reg <= data_to_send; -- data to transmit
    else
	   WR_n_reg <= '1';
		data_out_reg <= (others => '0');
    end if;	 
  end if;
end if;

end process;

-- assign outputs
RD_n <= RD_n_reg;
WR_n <= WR_n_reg;
data_out <= data_out_reg;


-- Component instantiations

-- Component that echos data recived from the PC
-- back to the PC.
num_adder1 : num_adder
port map
( 
  clk       => clk,
  reset     => reset,
  new_data  => new_data_reg,
  data_in   => data_in_reg,
  TX_busy_n => TX_busy_n,
  send_data => send_data,
  data_out  => data_to_send
);


end mixed;

