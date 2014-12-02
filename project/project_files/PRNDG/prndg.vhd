----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:36:50 11/16/2014 
-- Design Name: 
-- Module Name:    prndg - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- entity
entity random_gen is
port(
		clk : in std_logic;
		rst : in std_logic;
		seed : in std_logic_vector(255 downto 0);
		random_num : out std_logic_vector(255 downto 0)
);
end random_gen;

--architecture
architecture Behavorial of random_gen is
begin
	gen_process: process(clk) is
		variable tempSeed : unsigned(255 downto 0) := (others => '0');
		variable tempShift : unsigned(255 downto 0);
		--constant const : integer := 736338717;
	begin
		if (rst = '1') then
			tempSeed := unsigned(seed);
		end if;
		if (rising_edge(clk)) then
			tempShift := "000000000000" & tempSeed(255 downto 12); 	-- shifting right by 12
			tempSeed	 := tempSeed XOR tempShift;							-- 
			tempShift := tempSeed(230 downto 0) & "0000000000000000000000000"; -- shift left by 25
			tempSeed  := tempSeed XOR tempShift;
			tempShift := "000000000000000000000000000" & tempSeed(255 downto 27); -- shift right by 27
			tempSeed  := tempSeed XOR tempShift;
			--tempSeed  := unsigned(tempSeed * const);
		end if;
		random_num <= std_logic_vector(tempSeed);
	end process gen_process;
end Behavorial;