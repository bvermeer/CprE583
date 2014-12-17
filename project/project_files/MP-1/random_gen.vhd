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
		enable 			: in std_logic;	-- start random number generation process
		new_data 		: in std_logic;
		TX_busy_n 		: in std_logic; 	-- Indicate a new byte has been captured from UART
		data_in			: in std_logic_vector(7 downto 0);
		send_data		: out std_logic;	-- Request UART to transmit data_out
		done			: out std_logic;	-- Indicate that output has finished transmitting
		data_out 		: out std_logic_vector(7 downto 0); -- byte of the random_number to be sent out
		random_num 		: out std_logic_vector(255 downto 0) -- random number being generated every clock cycle
		
		--debug_state	: out std_logic_vector(7 downto 0)
);
end random_gen;

--architecture
architecture Behavorial of random_gen is

-- types
type random_gen_state_type is (WAIT_START, REC_BYTE_ONE, REC_BYTE_TWO, RAND_GEN, LOAD_BYTE, SEND_BYTE);
--type random_num_bytes_type is array(0 to 31) of std_logic_vector(7 downto 0);

-- SIGNALS --

-- State machine
signal random_gen_state			: random_gen_state_type;
signal random_gen_state_next	: random_gen_state_type;	

--signal rdy_send_data_reg 		: std_logic; -- Indicate there is data that is ready to be sent
--signal rdy_send_data_reg_en 	: std_logic;
--signal rdy_send_data_reg_in 	: std_logic;

 -- Tell UART to send a byte of data
signal send_data_reg  			: std_logic;
--signal send_data_reg_en 		: std_logic;
--signal send_data_reg_in  		: std_logic;

-- Temp storage for new data
signal data_out_reg   			: std_logic_vector(7 downto 0);
signal data_out_reg_en	 		: std_logic;
signal data_out_reg_in  		: std_logic_vector(7 downto 0);

--signal random_num_reg			: std_logic_vector(255 downto 0);
--signal random_num_reg_en 	: std_logic;

-- Counter
signal counter_reg				: integer;
signal counter_count_up 		: std_logic;
signal counter_reset 			: std_logic;
signal counter_reset_sig	 	: std_logic;

-- Randum number storage
signal random_num_reg			: std_logic_vector(255 downto 0);
signal random_num_reg_byte		: std_logic_vector(7 downto 0);
signal random_num_reg_en 		: std_logic;
signal random_num_reg_offset	: std_logic_vector(7 downto 0);
signal random_num_reg_in		: std_logic_vector(255 downto 0);
--signal random_num_bytes_in		: std_logic_vector(7 downto 0);

-- Seed value storage
signal seed_val_reg_in			: std_logic_vector(7 downto 0);
signal seed_val_reg_en			: std_logic;
signal seed_val_reg_offset		: std_logic; -- either 0 or 1
signal seed_val_reg				: std_logic_vector(255 downto 0);

signal gen_once_reg				: std_logic; -- if random number has been generated once
signal gen_once_reg_en			: std_logic;
signal gen_once_reg_in			: std_logic;

begin
	
	-- Synchronous process that sets the next state
	update_next_state_random_gen : process(clk)
	begin
		if(clk'event and clk = '1') then
			
			if(rst = '1') then
				random_gen_state 	<= WAIT_START;
			else
				random_gen_state 	<= random_gen_state_next;
			end if;
			
		end if;
			
	end process update_next_state_random_gen;
	
	
	-- Combinational process to compute the next state of state machine
	compute_next_state_random_gen: process (random_gen_state, enable, new_data, TX_busy_n)
		variable tempSeed : unsigned(255 downto 0) := (others => '0');
		variable tempShift : unsigned(255 downto 0);
	begin
		
		-- setting defaults to avoid inferring latches
		
		--rdy_send_data_reg_in 	<= '0';
		--send_data_reg_in  		<= '0';
		data_out_reg_in  		 	<= (others => '0');
		seed_val_reg_in			<= (others => '0');
		gen_once_reg_in			<= '0';
		
		--rdy_send_data_reg_en 	<= '0';
		--send_data_reg_en 			<= '0';
		data_out_reg_en			<= '0';
		seed_val_reg_en			<= '0';
		gen_once_reg_en			<= '0';
		
		send_data_reg 				<= '0';
		random_num_reg_in			<= (others => '0');
		seed_val_reg_offset		<= '0';
		
		counter_count_up 			<= '0';
		counter_reset_sig			<= '0';
		
		--random_gen_state_next	<= random_gen_state; -- NOT SURE ABOUT THIS
		
		done 							<= '0';-- To indicate when random num has been sent to UART for transmission
		
		case random_gen_state is
		
			when WAIT_START =>	-- waiting for start signal
				
				--debug_state <= x"00";
				
				--seed_val <= (others => '0'); I'M THINKING I DONT NEED THIS
				
				if(enable = '1') then
				
					--debug_state <= x"F0";
				
					-- move state to receiving first byte of seed
					random_gen_state_next <= REC_BYTE_ONE;
					
				else 
				
					random_gen_state_next <= WAIT_START;
				
				end if;
				
			when REC_BYTE_ONE =>		-- receiving LSByte of seed via UART
				
				--debug_state <= x"01";
				
				if(new_data = '1') then 
					
					-- store the LSByte in the register for a seed
					seed_val_reg_en 		<= '1';
					seed_val_reg_in 		<= data_in;
					seed_val_reg_offset 	<= '0';
					
					-- move state to receiving second byte of seed
					random_gen_state_next <= REC_BYTE_TWO;
					
				else
					
					random_gen_state_next <= REC_BYTE_ONE;	
					
				end if;
			
			when REC_BYTE_TWO =>		-- receiving MSByte of seed via UART
				
				--debug_state <= x"02";
				
				if(new_data = '1') then 
					
					-- store the MSByte in the register for a seed
					seed_val_reg_en 		<= '1';
					seed_val_reg_in 		<= data_in;
					seed_val_reg_offset 	<= '1';
					
					-- move state to computing random number
					random_gen_state_next <= RAND_GEN;
					
				else
					
					random_gen_state_next <= REC_BYTE_TWO;
					
				end if;
			
			when RAND_GEN =>	-- computing the random number
				
				--debug_state <= x"03";
				
				 --initializing tempSeed
				if (gen_once_reg = '0') then
					tempSeed := unsigned(seed_val_reg);
					
					-- moving on to sending the random number generated
					random_gen_state_next <= LOAD_BYTE;
				else
					tempSeed := unsigned(random_num_reg);
					
					-- moving on to sending the random number generated
					random_gen_state_next <= RAND_GEN;
				end if;
		
				-- computing random number
				tempShift := "000000000000" & tempSeed(255 downto 12); 					-- shifting right by 12
				tempSeed	 := tempSeed XOR tempShift;	-- xor with shifted value
				tempShift := tempSeed(230 downto 0) & "0000000000000000000000000"; 	-- shift left by 25
				tempSeed  := tempSeed XOR tempShift;	-- xor with shifted value
				tempShift := "000000000000000000000000000" & tempSeed(255 downto 27);-- shift right by 27
				tempSeed  := tempSeed XOR tempShift;	-- xor with shifted value
				-- tempSeed holds random number
				
				-- indicate that the first number has been generated
				if (gen_once_reg = '0') then
					gen_once_reg_en <= '1';
					gen_once_reg_in <= '1';
				end if;
				
				-- store this random number generated in a register
				random_num_reg_en 		<= '1';
				random_num_reg_in			<= std_logic_vector(tempSeed);
				
				
			
			when LOAD_BYTE => 	-- loading byte to be sent out
				
				--debug_state <= x"04";
				
				-- load byte to be sent out
				data_out_reg_en <= '1';
				data_out_reg_in <= random_num_reg_byte;
				
				-- increase the counter value
				counter_count_up <= '1';
				
				-- move to sending the loaded byte
				random_gen_state_next <= SEND_BYTE;
			
			when SEND_BYTE => 	-- sending byte via the UART
				
				--debug_state <= x"05";
				
				-- Check if UART is busy transmitting
				if(TX_busy_n = '1') then
					
					send_data_reg <= '1';     -- tell UART to transmit a byte 
					
					-- check for counter value
					if(counter_reg = 32) then
						
						done <= '1';
						counter_reset_sig <= '1';
						random_gen_state_next <= RAND_GEN;
						
					else	
						random_gen_state_next <= LOAD_BYTE;
						
					end if;	
						
				else
				
					random_gen_state_next <= SEND_BYTE;
				
				end if;
				
			
			when OTHERS =>

				random_gen_state_next <= WAIT_START;

				--debug_state <= x"FF";
				-- something here
		
		end case;
		
	end process compute_next_state_random_gen;
	
-- Process to update the registers	
	update_regs : process(clk)
	begin
	
		if( falling_edge(clk) ) then
			
			if(rst = '1') then
			
				data_out_reg 	<= (others => '0');
				--rdy_send_data_reg <= '0';
				--send_data_reg 	<= '0';
				random_num_reg <= (others => '0'); -- set the registers to 0 over here
				gen_once_reg	<= '0';
			
			else
				
				if (data_out_reg_en = '1') then
					data_out_reg <= data_out_reg_in;
				end if;
				
				if (random_num_reg_en = '1') then
					random_num_reg <= random_num_reg_in;
				end if;
				
				if (gen_once_reg_en = '1') then
					gen_once_reg <= gen_once_reg_in;
				end if;
				
				-- add more if statements for different register signals
				
			end if;
			
		end if;
			
	end process update_regs;	
	
	-- Process to update Random Number OR Seed
	update_random_num_OR_seed : process(clk)
	begin
	
		if( falling_edge(clk) ) then
			
			if(rst = '1') then
				
				random_num_reg 	<= (others => '0');
				seed_val_reg 		<= (others => '0');
				
			else
			
				if(random_num_reg_en = '1') then
			
					random_num_reg <= random_num_reg_in;
			
				end if;
				
				if(seed_val_reg_en = '1') then
					
					case seed_val_reg_offset is
						
						when '0' =>
						
							seed_val_reg(7 downto 0) <= seed_val_reg_in;
						
						when '1' =>
					
							seed_val_reg(15 downto 8) <= seed_val_reg_in;
			
						when others =>
							
							--
						
					end case;
					
				end if; 
				
			end if;
			
		end if;
		
	end process update_random_num_OR_seed;
	
	-- Process to read the data from the random_num_reg
	read_random_num_reg : process(random_num_reg_offset, random_num_reg)
	begin
		
		case random_num_reg_offset is
		
			when x"00" =>
						
				random_num_reg_byte <= random_num_reg(7 downto 0);
			
			when x"01" =>
			
				random_num_reg_byte <= random_num_reg(15 downto 8);
			
			when x"02" =>
			
				random_num_reg_byte <= random_num_reg(23 downto 16);
			
			when x"03" =>
			
				random_num_reg_byte <= random_num_reg(31 downto 24);
			
			when x"04" =>
			
				random_num_reg_byte <= random_num_reg(39 downto 32);
			
			when x"05" =>
			
				random_num_reg_byte <= random_num_reg(47 downto 40);
			
			when x"06" =>
			
				random_num_reg_byte <= random_num_reg(55 downto 48);
		
			when x"07" =>
			
				random_num_reg_byte <= random_num_reg(63 downto 56);
			
			when x"08" =>
			
				random_num_reg_byte <= random_num_reg(71 downto 64);
			
			when x"09" =>
			
				random_num_reg_byte <= random_num_reg(79 downto 72);
			
			when x"0A" =>
			
				random_num_reg_byte <= random_num_reg(87 downto 80);
			
			when x"0B" =>
			
				random_num_reg_byte <= random_num_reg(95 downto 88);
			
			when x"0C" =>
			
				random_num_reg_byte <= random_num_reg(103 downto 96);
			
			when x"0D" =>
			
				random_num_reg_byte <= random_num_reg(111 downto 104);
			
			when x"0E" =>
			
				random_num_reg_byte <= random_num_reg(119 downto 112);
			
			when x"0F" =>
			
				random_num_reg_byte <= random_num_reg(127 downto 120);
			
			when x"10" =>

				random_num_reg_byte <= random_num_reg(135 downto 128);
			
			when x"11" =>

				random_num_reg_byte <= random_num_reg(143 downto 136);
			
			when x"12" =>

				random_num_reg_byte <= random_num_reg(151 downto 144);
			
			when x"13" =>

				random_num_reg_byte <= random_num_reg(159 downto 152);
			
			when x"14" =>

				random_num_reg_byte <= random_num_reg(167 downto 160);
			
			when x"15" =>

				random_num_reg_byte <= random_num_reg(175 downto 168);
			
			when x"16" =>

				random_num_reg_byte <= random_num_reg(183 downto 176);
			
			when x"17" =>

				random_num_reg_byte <= random_num_reg(191 downto 184);
			
			when x"18" =>

				random_num_reg_byte <= random_num_reg(199 downto 192);
			
			when x"19" =>

				random_num_reg_byte <= random_num_reg(207 downto 200);
			
			when x"1A" =>

				random_num_reg_byte <= random_num_reg(215 downto 208);
			
			when x"1B" =>

				random_num_reg_byte <= random_num_reg(223 downto 216);
			
			when x"1C" =>

				random_num_reg_byte <= random_num_reg(231 downto 224);
			
			when x"1D" =>

				random_num_reg_byte <= random_num_reg(239 downto 232);
			
			when x"1E" =>

				random_num_reg_byte <= random_num_reg(247 downto 240);
			
			when x"1F" =>

				random_num_reg_byte <= random_num_reg(255 downto 248);
		
			when others =>
				--
		end case;
	
	end process read_random_num_reg;
	
	-- Process to increment the counter when needed
	counter_proc : process(clk)
	begin
		if(falling_edge(clk)) then
			
			if(counter_reset = '1') then
			
				counter_reg <= 0 ;
				random_num_reg_offset <= x"00";
			else
				
				if(counter_count_up = '1') then
					counter_reg <= counter_reg + 1;
					
					case counter_reg is
					
						when 1 =>
						
							random_num_reg_offset <= x"01";
						
						when 2 =>
						
							random_num_reg_offset <= x"02";
						
						when 3 =>
						
							random_num_reg_offset <= x"03";
						
						when 4 =>
						
							random_num_reg_offset <= x"04";
						
						when 5 =>
					
							random_num_reg_offset <= x"05";
					
						when 6 =>
						
							random_num_reg_offset <= x"06";
						
						when 7 =>
						
							random_num_reg_offset <= x"07";
						
						when 8 =>
						
							random_num_reg_offset <= x"08";
						
						when 9 =>
						
							random_num_reg_offset <= x"09";
						
						when 10 =>
						
							random_num_reg_offset <= x"0A";
						
						when 11 =>
						
							random_num_reg_offset <= x"0B";
						
						when 12 =>
						
							random_num_reg_offset <= x"0C";
						
						when 13 =>
						
							random_num_reg_offset <= x"0D";
							
						when 14 =>
						
							random_num_reg_offset <= x"0E";
						
						when 15 =>
					
							random_num_reg_offset <= x"0F";
							
						when 16 =>
						
							random_num_reg_offset <= x"10";
						
						when 17 =>
						
							random_num_reg_offset <= x"11";
						
						when 18 =>
						
							random_num_reg_offset <= x"12";
						
						when 19 =>
						
							random_num_reg_offset <= x"13";
						
						when 20 =>
					
							random_num_reg_offset <= x"14";
					
						when 21 =>
						
							random_num_reg_offset <= x"15";
						
						when 22 =>
						
							random_num_reg_offset <= x"16";
						
						when 23 =>
						
							random_num_reg_offset <= x"17";
						
						when 24 =>
						
							random_num_reg_offset <= x"18";
						
						when 25 =>
						
							random_num_reg_offset <= x"19";
						
						when 26 =>
						
							random_num_reg_offset <= x"1A";
						
						when 27 =>
						
							random_num_reg_offset <= x"1B";
						
						when 28 =>
						
							random_num_reg_offset <= x"1C";
							
						when 29 =>
						
							random_num_reg_offset <= x"1D";
						
						when 30 =>
					
							random_num_reg_offset <= x"1E";
							
						when 31 =>
						
							random_num_reg_offset <= x"1F";
							
						when others =>
					
							-- 
					end case;
					
				end if;
			
			end if;
	
	end if;

	end process counter_proc;
	

-- Counter reset signal
counter_reset <= rst or counter_reset_sig;
	
-- Assign outputs
send_data <= send_data_reg;
data_out  <= data_out_reg;

-- Mapping random num output
random_num <= random_num_reg;
	
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



--if (gen_once_reg_en = '1') then
	--	gen_once_reg <= gen_once_reg_in;
	--end if;

--if (rdy_send_data_reg_en = '1') then
	--rdy_send_data_reg <= rdy_send_data_reg_in;
--end if;

--if (send_data_reg_en = '1') then
	--send_data_reg <= send_data_reg_in;
--end if;

--					case random_num_bytes_offset
--					
--						when x"00" =>
--						
--							random_num_bytes(7 downto 0) <= random_num_bytes_in;
--						
--						when x"01" =>
--						
--							random_num_bytes(15 downto 8) <= random_num_bytes_in;
--						
--						when x"02" =>
--						
--							random_num_bytes(23 downto 16) <= random_num_bytes_in;
--						
--						when x"03" =>
--						
--							random_num_bytes(31 downto 24) <= random_num_bytes_in;
--						
--						when x"04" =>
--						
--							random_num_bytes(39 downto 32) <= random_num_bytes_in;
--						
--						when x"05" =>
--						
--							random_num_bytes(47 downto 40) <= random_num_bytes_in;
--						
--						when x"06" =>
--						
--							random_num_bytes(55 downto 48) <= random_num_bytes_in;
--					
--						when x"07" =>
--						
--							random_num_bytes(63 downto 56) <= random_num_bytes_in;
--						
--						when x"08" =>
--						
--							random_num_bytes(71 downto 64) <= random_num_bytes_in;
--						
--						when x"09" =>
--						
--							random_num_bytes(79 downto 72) <= random_num_bytes_in;
--						
--						when x"0A" =>
--						
--							random_num_bytes(87 downto 80) <= random_num_bytes_in;
--						
--						when x"0B" =>
--						
--							random_num_bytes(95 downto 88) <= random_num_bytes_in;
--						
--						when x"0C" =>
--						
--							random_num_bytes(103 downto 96) <= random_num_bytes_in;
--						
--						when x"0D" =>
--						
--							random_num_bytes(111 downto 104) <= random_num_bytes_in;
--						
--						when x"0E" =>
--						
--							random_num_bytes(119 downto 112) <= random_num_bytes_in;
--						
--						when x"0F" =>
--						
--							random_num_bytes(127 downto 120) <= random_num_bytes_in;
--						
--						when x"10" =>
--
--							random_num_bytes(135 downto 128) <= random_num_bytes_in;
--						
--						when x"11" =>
--
--							random_num_bytes(143 downto 136) <= random_num_bytes_in;
--						
--						when x"12" =>
--
--							random_num_bytes(151 downto 144) <= random_num_bytes_in;
--						
--						when x"13" =>
--
--							random_num_bytes(159 downto 152) <= random_num_bytes_in;
--						
--						when x"14" =>
--
--							random_num_bytes(167 downto 160) <= random_num_bytes_in;
--						
--						when x"15" =>
--
--							random_num_bytes(175 downto 168) <= random_num_bytes_in;
--						
--						when x"16" =>
--
--							random_num_bytes(183 downto 176) <= random_num_bytes_in;
--						
--						when x"17" =>
--
--							random_num_bytes(191 downto 184) <= random_num_bytes_in;
--						
--						when x"18" =>
--
--							random_num_bytes(199 downto 192) <= random_num_bytes_in;
--						
--						when x"19" =>
--
--							random_num_bytes(207 downto 200) <= random_num_bytes_in;
--						
--						when x"1A" =>
--
--							random_num_bytes(215 downto 208) <= random_num_bytes_in;
--						
--						when x"1B" =>
--
--							random_num_bytes(223 downto 216) <= random_num_bytes_in;
--						
--						when x"1C" =>
--
--							random_num_bytes(231 downto 224) <= random_num_bytes_in;
--						
--						when x"1D" =>
--
--							random_num_bytes(239 downto 232) <= random_num_bytes_in;
--						
--						when x"1E" =>
--
--							random_num_bytes(247 downto 240) <= random_num_bytes_in;
--						
--						when x"1F" =>
--
--							random_num_bytes(255 downto 248) <= random_num_bytes_in;
--							
--						when x"FF" =>
--						
--							random_num_bytes <= random_num_reg_in;
--							
--						when others =>
--							
--							--
--					
--					end case;
