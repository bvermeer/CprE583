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
		clk 			: in std_logic;
		rst 			: in std_logic;
		enable 		: in std_logic;	-- start random number generation process
		new_data 	: in std_logic;
		TX_busy_n 	: in std_logic; 	-- Indicate a new byte has been captured from UART
		data_in		: in std_logic_vector(7 downto 0);
		send_data	: out std_logic;	-- Request UART to transmit data_out
		done			: out std_logic;	-- Indicate that output has finished transmitting
		data_out 	: out std_logic_vector(7 downto 0); -- byte of the random_number to be sent out
		random_num 	: out std_logic_vector(255 downto 0) -- random number generated
);
end random_gen;

--architecture
architecture Behavorial of random_gen is

-- types
type random_gen_state_type is (WAIT_START, REC_BYTE_ONE, REC_BYTE_TWO, COMPUTE_NUM, SEND_BYTES);

-- signals
signal rdy_send_data_reg 		: std_logic; -- Indicate there is data that is ready to be sent
signal send_data_reg  			: std_logic; -- Tell UART to send a byte of data
signal data_out_reg   			: std_logic_vector(7 downto 0); -- Temp storage for new data
signal random_gen_state			: random_gen_state_type;
signal random_gen_state_next	: random_gen_state_type;	
signal seed_val					: std_logic_vector(255 downto 0);
signal random_num_reg			: std_logic_vector(255 downto 0);

begin
	
	update_next_state_random_gen : process(clk)
	begin
		if(clk'event and clk = '1') then
			
			if(rst = '1') then
				random_gen_state 		<= WAIT_START;
				rdy_send_data_reg 	<= '0';
				send_data_reg     	<= '0';
				data_out_reg      	<= (others => '0');
				--numOfBytesReceived 	<= 0;
			else
				random_gen_state <= random_gen_state_next;
			end if;
			
		end if;
			
	end process update_next_state_random_gen;
	
	compute_next_state_random_gen: process (random_gen_state)
		variable tempSeed : unsigned(255 downto 0) := (others => '0');
		variable tempShift : unsigned(255 downto 0);
	begin
		
		-- defaults
		send_data_reg <= '0';
		random_gen_next_state	<= random_gen_state; -- NOT SURE ABOUT THIS
		done 							<= '0';-- To indicate when random num has been sent to UART for transmission
		
		case random_gen_state is
		
		when WAIT_START =>	-- waiting for start signal
			
			seed_val <= (others => '0'); -- clearing the seed value
			
			if(enable = '1') then
				random_gen_next_state <= REC_BYTES;
			end if;
			
		when REC_BYTE_ONE =>		-- receiving LSByte of seed via UART
			
			if(new_data = '1') then 
				seed_val(7 downto 0) <= data_in;
				random_gen_next_state <= REC_BYTE_TWO;
			end if;
		
		when REC_BYTE_TWO =>		-- receiving MSByte of seed via UART
			
			if(new_data = '1') then 
				seed_val(15 downto 8) <= data_in;
				random_gen_next_state <= COMPUTE_NUM;
			end if;
		
		
		when COMPUTE_NUM =>	-- computing the random number
			
			rdy_send_data_reg <= '1'; -- keep high until the UART is ready for us
		
			tempShift := "000000000000" & tempSeed(255 downto 12); 	-- shifting right by 12
			tempSeed	 := tempSeed XOR tempShift;							-- 
			tempShift := tempSeed(230 downto 0) & "0000000000000000000000000"; -- shift left by 25
			tempSeed  := tempSeed XOR tempShift;
			tempShift := "000000000000000000000000000" & tempSeed(255 downto 27); -- shift right by 27
			tempSeed  := tempSeed XOR tempShift;
			
			random_num_reg <= std_logic_vector(tempSeed);
			
			random_gen_next_state <= SEND_BYTES;
		
		when SEND_BYTES => 	-- sending bytes via the UART
			
			data_out_reg <= ; -- NEED TO WORK FROM HERE
			
			if(TX_busy_n = '1') then -- Check if UART is busy transmitting already
				rdy_send_data_reg <= '0'; -- reset this signal
				send_data_reg <= '1';     -- tell UART to transmit a byte 
			end if;
		
		when OTHERS => 
			-- something here
		end case;
	end process compute_next_state_random_gen;
	
-- Assign outputs
send_data <= send_data_reg;
data_out  <= data_out_reg;
	
--	gen_process: process(clk) is
--		variable tempSeed : unsigned(255 downto 0) := (others => '0');
--		variable tempShift : unsigned(255 downto 0);
--		--constant const : integer := 736338717;
--	begin
--		if (rst = '1') then
--			tempSeed := unsigned(seed);
--		end if;
--		if (rising_edge(clk)) then
--			tempShift := "000000000000" & tempSeed(255 downto 12); 	-- shifting right by 12
--			tempSeed	 := tempSeed XOR tempShift;							-- 
--			tempShift := tempSeed(230 downto 0) & "0000000000000000000000000"; -- shift left by 25
--			tempSeed  := tempSeed XOR tempShift;
--			tempShift := "000000000000000000000000000" & tempSeed(255 downto 27); -- shift right by 27
--			tempSeed  := tempSeed XOR tempShift;
--			--tempSeed  := unsigned(tempSeed * const);
--		end if;
--		random_num <= std_logic_vector(tempSeed);
--	end process gen_process;
	
end Behavorial;
