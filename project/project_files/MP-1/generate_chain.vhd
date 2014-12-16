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
	data_out	: out std_logic_vector(7 downto 0);	--data to send to the UART
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
		dout	:	out std_logic_vector(15 downto 0);
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
signal candidate_state_prev	:	generate_candidate_type;	--the previous state in candidate generation

--registers
signal gen_complete_flag	:	std_logic;			--register holding the value of whether or not generation of a candidate is complete
signal is_prime_flag		:	std_logic;			--register holding the value of whether or not a candidate is prime
signal mm_complete_flag		:	std_logic;			--register holding the value of whether or not the multiplier is done calculating
signal gen_start_reg		:	std_logic;			--register to store the start bit sent to the module
signal debug_reg		:	std_logic;			--register to store if we are running in debug mode
signal done_reg			:	std_logic;			--register that states whether or not the chain is complete
signal seed_in_reg		:	unsigned(255 downto 0);		--register for the seed value used to calculate a candidate
signal candidate_reg		:	unsigned(255 downto 0);		--register to store the current candidate
signal mm_addr_reg		:	std_logic_vector(41 downto 0);	--address register for the montgomery multiplier
signal read_d_reg		:	std_logic;			--register to inform the mm if it is reading
signal write_d_reg		:	std_logic;			--register to inform the mm if it is writing
signal data_in_reg		:	std_logic_vector(15 downto 0);	--register for din of mm
signal data_out_reg		:	std_logic_vector(15 downto 0);	--register for dout of mm

begin
	--portmap of the montgomery multiplier
	Mont_Mult	:	mm_bridge
		port map(
			clk		=>	clk,
			addr	=>	mm_addr_reg,
			read_d	=>	read_d_reg,
			write_d	=>	write_d_reg,
			din		=>	data_in_reg,
			dout	=>	data_out_reg
		);

	--handles all register inputs
	Register_Inputs : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				gen_start_reg <= '0';
				debug_reg <= '0';
				seed_in_reg <= (others => '0');
				
			else
				gen_start_reg <= start;
				debug_reg <= debug;
				
				if(is_prime_flag = '0') then		--if the previous candidate is not prime
					seed_in_reg <= seed;		--set the seed to the pseudo-random seed
				else					--otherwise
					seed_in_reg <= candidate_reg;	--set the seed to the previous candidate
				end if;
			end if;
		end if;
	end process Register_Inputs;

	--update process for the state machine
	State_Update : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				candidate_state_prev	<= IDLE;
				candidate_state 	<= IDLE;
			else
				if(candidate_state_prev = candidate_state) then
					candidate_state_prev	<= candidate_state_prev;
				else
					candidate_state_prev	<= candidate_state;
				end if;
				candidate_state 	<= candidate_state_next;
			end if;
		end if;
	end process State_Update;

	--process to get the next state
	Next_State_Comp : process(candidate_state, gen_complete_flag, gen_start_reg
					mm_complete_flag, debug_reg)
	begin
	
	--defaults
	candidate_state_next	<= candidate_state;
	
	case candidate_state is
	
	when IDLE =>	--waiting for the start bit to be set
		if(gen_start_reg = '1') then
			candidate_state_next <= CAND_GEN;
		end if;
	
	when CAND_GEN =>	--generation of a candidate
		if(gen_complete_flag = '1') then
			candidate_state_next <= CHECK;
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
		if() then

		elsif() then

		end if;

	end process Next_State_Comp;

end mixed;
