library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity generate_chain is port(
	clk		: in std_logic;
	reset		: in std_logic;
	debug		: in std_logic;				--indicates if in debug mode
	seed		: in std_logic_vector(255 downto 0);	--the 256 bit seed from prndg.vhd
	TX_busy_n	: in std_logic;				--active low, use to know when to send data out
	send_data	: out std_logic;			--tell UART to transmit a byte
	data_out	: out std_logic_vector(7 downto 0);	--data to send to the UART
);
end generate_chain;

architecture mixed of generate_chain is

-------------------------------------------
-- 	component declarations		 --
-------------------------------------------

-------------------------------------------
-- 	signal declarations		 --
-------------------------------------------

begin

end mixed;
