library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity generate_chain is port(
	clk		: in std_logic;
	reset		: in std_logic;
	start		: in std_logic;				--indicates if generation is to start
	debug		: in std_logic;				--indicates if in debug mode
	seed		: in unsigned(255 downto 0);		--the 256 bit seed from prndg.vhd
	TX_busy_n	: in std_logic;				--active low, use to know when to send data out
	done		: out std_logic;			--a signal to tell the interpretter that a chain is done
	send_data	: out std_logic;			--tell UART to transmit a byte
	data_out	: out std_logic_vector(7 downto 0)	--data to send to the UART
);
end generate_chain;

architecture mixed of generate_chain is

-------------------------------------------
-- 	component declarations		 --
-------------------------------------------
component mm_bridge
	port(
		clk	:	in std_logic;
		addr	:	in std_logic_vector(41 downto 0);
		read_d	:	in std_logic;
		write_d	:	in std_logic;
		din	:	in std_logic_vector(15 downto 0);
		dout	:	out std_logic_vector(15 downto 0)
	);
end component;
-------------------------------------------
--	type declarations		 --
-------------------------------------------
type generate_candidate_type is (IDLE, CAND_GEN, CHECK, PRINT);		--type for the different states for generating primes

-------------------------------------------
--   signal and register declarations	 --
-------------------------------------------
signal candidate_state		:	generate_candidate_type;	--current state of candidate generation
signal candidate_state_next	:	generate_candidate_type;	--the next state in candidate generation

--state machine registers and flags
signal seed_en			:	std_logic;			--enable for the seed value coming in
signal gen_complete_flag	:	std_logic;			--register holding the value of whether or not generation of a candidate is complete
signal from_gen_cand		:	std_logic;			--a register to keep track of whether or not the last state was GEN_CAND
signal is_prime_flag		:	std_logic;			--register holding the value of whether or not a candidate is prime
signal mm_complete_flag		:	std_logic;			--register holding the value of whether or not the multiplier is done calculating
signal print_complete_flag	:	std_logic;			--register holding the value of whether or not printing it complete
signal gen_start_reg		:	std_logic;			--register to store the start bit sent to the module
signal debug_reg		:	std_logic;			--register to store if we are running in debug mode
signal done_reg			:	std_logic;			--register that states whether or not the chain is complete
signal seed_in_reg		:	unsigned(255 downto 0);		--register for the seed value used to calculate a candidate
signal candidate_reg		:	unsigned(255 downto 0);		--register to store the current candidate

--montgomery multiplier signals and regs
signal mm_addr_reg		:	std_logic_vector(41 downto 0);	--address register for the montgomery multiplier
signal read_d_reg		:	std_logic;			--register to inform the mm if it is reading
signal write_d_reg		:	std_logic;			--register to inform the mm if it is writing
signal din_reg			:	std_logic_vector(15 downto 0);	--register for din of mm
signal dout_reg			:	std_logic_vector(15 downto 0);	--register for dout of mm

--UART signals and regs
signal data_out_reg		:	std_logic_vector(7 downto 0);	--register for sending data out to UART
signal send_data_reg		:	std_logic;			--register for telling UART to read data_out
signal rdy_send_data		:	std_logic;			--register to tell when data is ready to be sent
signal byte_count		:	unsigned(4 downto 0);		--register to keep track of the byte count for the result printing
signal candidate_sent		:	std_logic;			--register for telling the circuit that the candidate is sent
signal debug_byte_count		:	unsigned(6 downto 0);		--register to keep track of the byte count for the printing of debug info

begin
	--portmap of the montgomery multiplier
	Mont_Mult	:	mm_bridge
		port map(
			clk	=>	clk,
			addr	=>	mm_addr_reg,
			read_d	=>	read_d_reg,
			write_d	=>	write_d_reg,
			din	=>	din_reg,
			dout	=>	dout_reg
		);

	--handles all register inputs
	Register_Inputs : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				gen_start_reg <= '0';
				debug_reg <= '0';
				seed_in_reg <= (others => '0');
				seed_en <= '1';
			else
				gen_start_reg <= start;
				debug_reg <= debug;

				if(is_prime_flag = '0' and seed_en = '1') then		--if the previous candidate is not prime
					seed_in_reg <= seed;				--set the seed to the pseudo-random seed
				elsif(is_prime_flag = '1' and seed_en = '1') then
					seed_in_reg <= candidate_reg;
				else					--otherwise
					seed_in_reg <= seed_in_reg;	--set the seed to the previous candidate
				end if;

				if(start = '1') then
					seed_en <= '0'
				end if;
			end if;
		end if;
	end process Register_Inputs;

	--update process for the state machine
	State_Update : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				candidate_state 	<= IDLE;
			else
				candidate_state 	<= candidate_state_next;
			end if;
		end if;
	end process State_Update;

	--process to get the next state
	Next_State_Comp : process(candidate_state, gen_complete_flag, gen_start_reg,
					mm_complete_flag, debug_reg, print_complete_flag)
	begin
	
	--defaults
	candidate_state_next	<= candidate_state;
	
	case candidate_state is
	
	when IDLE =>	--waiting for the start bit to be set
		if(gen_start_reg = '1') then
			candidate_state_next <= CAND_GEN;
		end if;
	
	when CAND_GEN =>	--generation of a candidate
		if(gen_complete_flag = '1' and debug_reg = '0') then
			candidate_state_next <= CHECK;
		elsif(gen_complete_flag = '1' and debug_reg = '1') then
			candidate_state_next <= PRINT;
		else
			candidate_state_next <= CAND_GEN;
		end if;
	
	when CHECK =>		--check if the candidate generated is prime
		if(mm_complete_flag = '1') then
			candidate_state_next <= PRINT;
		else
			candidate_state_next <= CHECK;
		end if;
	
	when PRINT =>		--print out the prime candidate, or 'done' if the candidate was not prime
		if(print_complete_flag = '1' and debug_reg = '0') then
			candidate_state_next <= IDLE;
		elsif(print_complete_flag = '1' and debug_reg = '1') then
			candidate_state_next <= CHECK;
		else
			candidate_state_next <= PRINT;
		end if;
	when Others =>
		candidate_state_next <= IDLE;
	end case;

	end process Next_State_Comp;

	--process to calculate the candidate prime value
	Candidate_Comp_Process : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				candidate_reg		<= (others => '0');
				gen_complete_flag	<= '0';
				from_gen_cand		<= '0';
			else
				if(candidate_state = CAND_GEN) then
					candidate_reg		<= seed_in_reg(254 downto 0) & '1';
					gen_complete_flag	<= '1';
					from_gen_cand		<= '1';
				elsif(candidate_state = PRINT) then
					from_gen_cand		<= from_gen_cand;
					candidate_reg		<= candidate_reg;
					gen_complete_flag	<= '0';
				else
					candidate_reg		<= candidate_reg;
					gen_complete_flag	<= '0';
					from_gen_cand		<= '0';
				end if;
			end if;
		end if;
	end process Output_Generation;

	--process to handle the printing of stuff
	Print_Process : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				print_complete_flag	<= '0';
				send_data_reg		<= '0';
				data_out_reg		<= (others => '0');
				rdy_send_data		<= '0';
				byte_count		<= (others => '0');
				done_reg		<= '0';
				from_gen_cand		<= '0';
				debug_byte_count	<= (others => '0');
			else
				if(candidate_state = PRINT and debug_reg = '0') then
					if(rdy_send_data = '0') then
						rdy_send_data <= '1';
						if(is_prime_flag = '1') then
							if(byte_count = 0) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(7 downto 0);
							elsif(byte_count = 1) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(15 downto 8);
							elsif(byte_count = 2) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(23 downto 16);
							elsif(byte_count = 3) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(31 downto 24);
							elsif(byte_count = 4) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(39 downto 32);
							elsif(byte_count = 5) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(47 downto 40);
							elsif(byte_count = 6) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(55 downto 48);
							elsif(byte_count = 7) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(63 downto 56);
							elsif(byte_count = 8) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(71 downto 64);
							elsif(byte_count = 9) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(79 downto 72);
							elsif(byte_count = 10) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(87 downto 80);
							elsif(byte_count = 11) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(95 downto 88);
							elsif(byte_count = 12) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(103 downto 96);
							elsif(byte_count = 13) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(111 downto 104);
							elsif(byte_count = 14) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(119 downto 112);
							elsif(byte_count = 15) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(127 downto 120);
							elsif(byte_count = 16) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(135 downto 128);
							elsif(byte_count = 17) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(143 downto 136);
							elsif(byte_count = 18) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(151 downto 144);
							elsif(byte_count = 19) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(159 downto 152);
							elsif(byte_count = 20) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(167 downto 160);
							elsif(byte_count = 21) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(175 downto 168);
							elsif(byte_count = 22) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(183 downto 176);
							elsif(byte_count = 23) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(191 downto 184);
							elsif(byte_count = 24) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(199 downto 192);
							elsif(byte_count = 25) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(207 downto 200);
							elsif(byte_count = 26) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(215 downto 208);
							elsif(byte_count = 27) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(223 downto 216);
							elsif(byte_count = 28) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(231 downto 224);
							elsif(byte_count = 29) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(239 downto 232);
							elsif(byte_count = 30) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= candidate(247 downto 240);
							else
								data_out_reg	<= candidate(255 downto 248);
								candidate_sent	<= '1';
							end if;
						else
							if(byte_count = 0) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= x"44";	--send "D"
							elsif(byte_count = 1) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= x"4F";	--send "O"
							elsif(byte_count = 2) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= x"4E";	--send "N"
							elsif(byte_count = 3) then
								byte_count	<= byte_count + 1;
								data_out_reg	<= x"45";	--send "E"
							else
								data_out_reg	<= x"00";	--send NULL
								candidate_sent	<= '1';
								done_reg	<= '1';
							end if;
						end if;
					else
						if(TX_busy_n = '1') then
							rdy_send_data	<= '0';
							send_data_reg	<= '1';
							if(candidate_sent = '1') then
								print_complete_flag	<= '1';
								byte_count		<= (others => '0');
							end if;
						end if;
					end if;
				elsif(candidate_state = PRINT and debug_reg = '1') then
					if(rdy_send_data = '0') then
						if(from_gen_cand = '1') then			--if it just came from gen_gand
							if(debug_byte_count = 0) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= x"53";			--print S
							elsif(debug_byte_count = 1) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(7 downto 0);
							elsif(debug_byte_count = 2) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(15 downto 8);
							elsif(debug_byte_count = 3) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(23 downto 16);
							elsif(debug_byte_count = 4) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(31 downto 24);
							elsif(debug_byte_count = 5) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(39 downto 32);
							elsif(debug_byte_count = 6) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(47 downto 40);
							elsif(debug_byte_count = 7) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(55 downto 48);
							elsif(debug_byte_count = 8) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(63 downto 56);
							elsif(debug_byte_count = 9) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(71 downto 64);
							elsif(debug_byte_count = 10) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(79 downto 72);
							elsif(debug_byte_count = 11) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(87 downto 80);
							elsif(debug_byte_count = 12) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(95 downto 88);
							elsif(debug_byte_count = 13) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(103 downto 96);
							elsif(debug_byte_count = 14) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(111 downto 104);
							elsif(debug_byte_count = 15) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(119 downto 112);
							elsif(debug_byte_count = 16) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(127 downto 120);
							elsif(debug_byte_count = 17) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(135 downto 128);
							elsif(debug_byte_count = 18) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(143 downto 136);
							elsif(debug_byte_count = 19) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(151 downto 144);
							elsif(debug_byte_count = 20) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(159 downto 152);
							elsif(debug_byte_count = 21) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(167 downto 160);
							elsif(debug_byte_count = 22) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(175 downto 168);
							elsif(debug_byte_count = 23) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(183 downto 176);
							elsif(debug_byte_count = 24) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(191 downto 184);
							elsif(debug_byte_count = 25) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(199 downto 192);
							elsif(debug_byte_count = 26) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(207 downto 200);
							elsif(debug_byte_count = 27) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(215 downto 208);
							elsif(debug_byte_count = 28) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(223 downto 216);
							elsif(debug_byte_count = 29) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(231 downto 224);
							elsif(debug_byte_count = 30) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(239 downto 232);
							elsif(debug_byte_count = 31) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(247 downto 240);
							elsif(debug_byte_count = 32) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= seed_in_reg(255 downto 248);
							elsif(debug_byte_count = 33) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= x"43";			--print C
							elsif(debug_byte_count = 34) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(7 downto 0);
							elsif(debug_byte_count = 35) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(15 downto 8);
							elsif(debug_byte_count = 36) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(23 downto 16);
							elsif(debug_byte_count = 37) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(31 downto 24);
							elsif(debug_byte_count = 38) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(39 downto 32);
							elsif(debug_byte_count = 39) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(47 downto 40);
							elsif(debug_byte_count = 40) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(55 downto 48);
							elsif(debug_byte_count = 41) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(63 downto 56);
							elsif(debug_byte_count = 42) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(71 downto 64);
							elsif(debug_byte_count = 43) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(79 downto 72);
							elsif(debug_byte_count = 44) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(87 downto 80);
							elsif(debug_byte_count = 45) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(95 downto 88);
							elsif(debug_byte_count = 46) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(103 downto 96);
							elsif(debug_byte_count = 47) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(111 downto 104);
							elsif(debug_byte_count = 48) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(119 downto 112);
							elsif(debug_byte_count = 49) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(127 downto 120);
							elsif(debug_byte_count = 50) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(135 downto 128);
							elsif(debug_byte_count = 51) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(143 downto 136);
							elsif(debug_byte_count = 52) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(151 downto 144);
							elsif(debug_byte_count = 53) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(159 downto 152);
							elsif(debug_byte_count = 54) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(167 downto 160);
							elsif(debug_byte_count = 55) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(175 downto 168);
							elsif(debug_byte_count = 56) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(183 downto 176);
							elsif(debug_byte_count = 57) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(191 downto 184);
							elsif(debug_byte_count = 58) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(199 downto 192);
							elsif(debug_byte_count = 59) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(207 downto 200);
							elsif(debug_byte_count = 60) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(215 downto 208);
							elsif(debug_byte_count = 61) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(223 downto 216);
							elsif(debug_byte_count = 62) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(231 downto 224);
							elsif(debug_byte_count = 63) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(239 downto 232);
							elsif(debug_byte_count = 64) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(247 downto 240);
							elsif(debug_byte_count = 65) then
								debug_byte_count	<= debug_byte_count + 1;
								data_out_reg		<= candidate(255 downto 248);
								candidate_sent		<= '1';
							else
								--do nothing
							end if;
						else						--otherwise
							if(is_prime_flag = '1') then
								if(byte_count = 0) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(7 downto 0);
								elsif(byte_count = 1) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(15 downto 8);
								elsif(byte_count = 2) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(23 downto 16);
								elsif(byte_count = 3) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(31 downto 24);
								elsif(byte_count = 4) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(39 downto 32);
								elsif(byte_count = 5) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(47 downto 40);
								elsif(byte_count = 6) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(55 downto 48);
								elsif(byte_count = 7) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(63 downto 56);
								elsif(byte_count = 8) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(71 downto 64);
								elsif(byte_count = 9) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(79 downto 72);
								elsif(byte_count = 10) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(87 downto 80);
								elsif(byte_count = 11) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(95 downto 88);
								elsif(byte_count = 12) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(103 downto 96);
								elsif(byte_count = 13) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(111 downto 104);
								elsif(byte_count = 14) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(119 downto 112);
								elsif(byte_count = 15) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(127 downto 120);
								elsif(byte_count = 16) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(135 downto 128);
								elsif(byte_count = 17) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(143 downto 136);
								elsif(byte_count = 18) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(151 downto 144);
								elsif(byte_count = 19) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(159 downto 152);
								elsif(byte_count = 20) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(167 downto 160);
								elsif(byte_count = 21) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(175 downto 168);
								elsif(byte_count = 22) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(183 downto 176);
								elsif(byte_count = 23) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(191 downto 184);
								elsif(byte_count = 24) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(199 downto 192);
								elsif(byte_count = 25) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(207 downto 200);
								elsif(byte_count = 26) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(215 downto 208);
								elsif(byte_count = 27) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(223 downto 216);
								elsif(byte_count = 28) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(231 downto 224);
								elsif(byte_count = 29) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(239 downto 232);
								elsif(byte_count = 30) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= candidate(247 downto 240);
								else
									data_out_reg	<= candidate(255 downto 248);
									candidate_sent	<= '1';
								end if;
							else
								if(byte_count = 0) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= x"44";	--send "D"
								elsif(byte_count = 1) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= x"4F";	--send "O"
								elsif(byte_count = 2) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= x"4E";	--send "N"
								elsif(byte_count = 3) then
									byte_count	<= byte_count + 1;
									data_out_reg	<= x"45";	--send "E"
								else
									data_out_reg	<= x"00";	--send NULL
									candidate_sent	<= '1';
									done_reg	<= '1';
								end if;
							end if;
						end if;
					else
						if(TX_busy_n = '1') then
							rdy_send_data	<= '0';
							send_data_reg	<= '1';
							if(candidate_sent = '1') then
								print_complete_flag	<= '1';
								byte_count		<= (others => '0');
								debug_byte_count	<= (others => '0');
							end if;
						end if;
					end if;
				else
					print_complete_flag	<= '0';
					send_data_reg		<= '0';
					rdy_send_data		<= '0';
					done_reg		<= '0';
				end if;
			end if;
		end if;
	end process Print_Process;

done		<= done_reg;
send_data	<= send_data_reg;
data_out	<= data_out_reg;

end mixed;
