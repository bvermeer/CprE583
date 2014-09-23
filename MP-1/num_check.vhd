----------------------------------------------------------------------------------
-- Company: CprE 583 
-- Engineer: Blake Vermeer
-- 
-- Create Date:    09/22/2014 
-- Design Name: 
-- Module Name:    num_check - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Check if the two inputs are both 0-4. If they are set the output 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY num_check IS
    PORT ( clk       	: IN  STD_LOGIC;
           in_one		: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
           in_two 		: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
           both_nums	: OUT  STD_LOGIC
	     );
END num_check;

ARCHITECTURE Behavioral OF num_check IS
begin

	output_reg : process(clk)
	begin

		if(rising_edge(clk)) then

			--Set the default value for both_nums
			both_nums <= '0';

			if( in_one = x"30" OR
				in_one = x"31" OR
				in_one = x"32" OR
				in_one = x"33" OR
				in_one = x"34" ) then

				if( in_two = x"30" OR
					in_two = x"31" OR
					in_two = x"32" OR
					in_two = x"33" OR
					in_two = x"34" ) then

					both_nums <= '1';

				end if;

			end if;
			
		end if;

	end process output_reg ;

END Behavioral;
