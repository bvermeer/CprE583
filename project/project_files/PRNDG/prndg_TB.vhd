----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:39:37 11/16/2014 
-- Design Name: 
-- Module Name:    prndg_TB - Behavioral 
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 
   component random_gen
	port(
		clk : in std_logic;
		rst : in std_logic;
		seed : in std_logic_vector(255 downto 0);
		random_num : out std_logic_vector(255 downto 0)
	);
	end component;
	
	-- Input and Output definitions.
   signal clk : std_logic := '0';
	signal rst : std_logic := '0';
   signal random_num : std_logic_vector(255 downto 0);
   -- Clock period definitions
   constant clk_period : time := 1 ns;
	-- seed = 123456;
	constant tmp : std_logic_vector(238 downto 0) := (others => '0');
	constant seed: std_logic_vector(255 downto 0) := tmp & "11110001001000000";
	
BEGIN
        -- Instantiate the Unit Under Test (UUT)
   uut: random_gen PORT MAP (
          clk => clk,
			 rst => rst,
			 seed => seed,
			 random_num => random_num
        );
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	-- Reset definition
	rst_process :process
	begin
		rst <= '0';
		wait for clk_period;
		rst <= '1';
		wait for clk_period;
		rst <= '0';
		wait for 30 ns;
		rst <= '1';
		wait for clk_period;
		rst <= '0';
		wait;
	end process;

END;

