library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity generate_chain is port(
	clk		: in std_logic;
	reset		: in std_logic;
	debug		: in std_logic;				--indicates if in debug mode
	seed		: in unsigned(255 downto 0);		--the 256 bit seed from prndg.vhd
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
--	type declarations		 --
-------------------------------------------
type generate_candidate_type is (IDLE, CAND_GEN, CHECK, PRINT);		--type for the different states for generating primes
type prime_array is array (0 to 9) of unsigned(255 downto 0);		--array to store the confirmed prime numbers(maximum of ten)

-------------------------------------------
--   signal and register declarations	 --
-------------------------------------------
signal candidate_state		:	generate_candidate_type;	--current state of candidate generation
signal candidate_state_next	:	generate_candidate_type;	--the next state in candidate generation

--registers
signal generation_complete	:	std_logic;			--register holding the value of whether or not generation of a candidate is complete
signal is_prime			:	std_logic;			--register holding the value of whether or not a candidate is prime
signal prime_counter		:	unsigned(3 downto 0);		--register that holds the number of 
signal seed_in_reg		:	unsigned(255 downto 0);		--register for the seed value that is inputted
signal candidate_reg		:	unsigned(255 downto 0);		--register to store the current candidate
signal found_prime_array	:	prime_array;			--register to hold all the primes found with current seed

begin
	State_Update : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				candidate_state <= IDLE;
			else
				candidate_state <= candidate_state_next;
			end if;
		end if;
	end process State_Update;

	Next_State_Comp : process()
	begin

	end process Next_State_Comp;

end mixed;
