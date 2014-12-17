----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:21:00 09/08/2011 
-- Design Name: 
-- Module Name:    cmd_parse - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Parse command from UART and control operation of module
--
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

entity cmd_parse is
    Port ( clk       	: in  STD_LOGIC;
	       reset     	: in STD_LOGIC;
           new_data  	: in  STD_LOGIC; -- Indicate a new byte has been captured from UART
           data_in   	: in  STD_LOGIC_VECTOR (7 downto 0);
           TX_busy_n 	: in  STD_LOGIC;
           send_data 	: out  STD_LOGIC; -- Request UART to transmit data_out
           data_out  	: out  STD_LOGIC_VECTOR (7 downto 0)

           -- debug_state : out std_logic_vector ( 3 downto 0) ;
           -- debug_date_in_reg : out std_logic_vector ( 7 downto 0) ;
           -- debug_help_msg_done : out std_logic 
			);
end cmd_parse;

architecture Behavioral of cmd_parse is

-- Components
  -- Help message component
  COMPONENT help_msg
    PORT ( clk 			: IN std_logic ; 
           reset 		: IN std_logic ; 
           enable 		: IN std_logic ;  -- Signal to start the module 
           new_data 	: IN std_logic ; 
           data_in 		: IN std_logic_vector ( 7 downto 0) ; 
           TX_busy_n 	: IN std_logic ; 
           send_data 	: OUT  std_logic ; 
           done         : OUT std_logic ;  -- Signal to indicate when the module is done 
           data_out 	: OUT std_logic_vector ( 7 downto 0)
         );
  END COMPONENT;

    COMPONENT random_gen
      PORT (
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
      );
    END COMPONENT;

  
-- signals
signal rdy_send_data_reg 	: std_logic; -- Indicate there is that is ready to be sent
signal send_data_reg  		: std_logic; -- Tell UART to send a byte of data
signal data_out_reg   		: std_logic_vector(7 downto 0); -- Temp storage for new data

-- Data in flip-flop signals
signal data_in_reg		: std_logic_vector ( 7 downto 0) ; 
signal data_in_reg_in	: std_logic_vector ( 7 downto 0) ; 
signal data_in_reg_en 	: std_logic ; 

-- Signals to support help_msg submodule
signal help_msg_enable 		: std_logic ; 
signal help_msg_data_in 	: std_logic_vector ( 7 downto 0) ;
signal help_msg_send_data 	: std_logic ; 
signal help_msg_done 		: std_logic ; 
signal help_msg_data_out 	: std_logic_vector ( 7 downto 0) ;


-- Signals to support the random_gen submodule
signal random_gen_enable    	: std_logic ; 
signal random_gen_data_in   	: std_logic_vector ( 7 downto 0) ;
signal random_gen_send_data 	: std_logic ; 
signal random_gen_done      	: std_logic ; 
signal random_gen_data_out  	: std_logic_vector ( 7 downto 0) ;
signal random_gen_random_num 	: std_logic_vector ( 255 downto 0) ;


-- Signals for UART multiplexor
signal mult_sel            : std_logic_vector ( 3 downto 0) ;

--State machine signals
type state_type is (ST_RST, ST_IDLE, ST_WAIT);
signal PS, NS : state_type;




begin


-- Connect the help_msg submodule
HELP_MODULE : help_msg
PORT MAP
(
    clk 		=> 	clk,
    reset 		=>  reset,	
    enable 		=>  help_msg_enable,	
    new_data	=>  new_data,	
    data_in 	=> 	help_msg_data_in,
    TX_busy_n 	=>  TX_busy_n,	
    send_data 	=>	help_msg_send_data,
    done      	=>  help_msg_done,
    data_out  	=>  help_msg_data_out	
);

-- Connect the random_gen submodule
RANDOM_GEN_MODULE : random_gen
PORT MAP
(
	clk 	    => clk,		
	rst 	    => reset,		
	enable 		=> random_gen_enable,	
	new_data 	=> new_data,	
	TX_busy_n 	=> TX_busy_n,	
	data_in		=> random_gen_data_in,	
	send_data	=> random_gen_send_data,	
	done		=> random_gen_done,	
	data_out 	=> random_gen_data_out,	
	random_num 	=> random_gen_random_num	
);



	-- Parse command and hand off control to appropriate submodule
	--Synchronous process for the state machine (with synchronous reset) 
	sync_proc : process(clk, NS)
	begin
		--Trigger on the rising edge
		if(clk'event and clk = '1') then
		  
		  if(reset = '1') then  -- Enter the reset state 
		  		PS <= ST_RST;
		  else 
				PS <= NS;
			end if;
		end if;
	end process sync_proc; 


	--Combinational process for the state machine
	comb_proc : process(PS, new_data, TX_busy_n, data_in_reg )
	begin
		
		--Set the default value for the signals to avoid inferring latches
		data_in_reg_in <= (others => '0');
        data_in_reg_en <= '0';

        -- help_msg default values
        help_msg_enable <= '0';


        -- random_gen default values
        random_gen_enable <= '0';

        -- Default value for UART multiplexor
        mult_sel <= x"0";

        -- debug_state <= x"0";


		case PS is 
			--This state is entered on reset and clears the regs
			when ST_RST =>

				--Set the next state to ST_WAIT
				NS <= ST_IDLE;

			--This state is entered when waiting for new data, when new data is received, 
			--from the UART
			when ST_IDLE =>

                -- debug_state <= x"1";


				if(new_data = '1') then

					--Capture the new data and save it in a register
					data_in_reg_in <= data_in;
					data_in_reg_en <= '1';


					NS <= ST_WAIT;

                 else

                    NS <= ST_IDLE;

				end if;

            -- In this state, control is passed onto the appropriate submodule until the done signal is received
            when ST_WAIT =>


                -- debug_state <= x"2";

		        case (data_in_reg) is
		        	-- Print the help message
		        	when x"3F"	=> -- '?'

                        help_msg_enable <= '1';

                        -- Set the multiplexor to connect the help core
                        mult_sel <= x"1";

                        -- Wait until the submodule is done
                        if( help_msg_done = '1' ) then
                            
                            -- debug_state <= x"3";

                            NS <= ST_IDLE;

						else
                            
                            -- debug_state <= x"4";

							NS <= ST_WAIT;

                        end if;
		        	
		        	when x"52"	=> -- 'R'

                        random_gen_enable <= '1';

                        -- Set the multiplexor to connect the help core
                        mult_sel <= x"2";

                        -- Wait until the submodule is done
                        if( random_gen_done = '1' ) then
                            
                            -- debug_state <= x"3";

                            NS <= ST_IDLE;

						else
                            
                            -- debug_state <= x"4";

							NS <= ST_WAIT;

                        end if;
		        	
		        	when others =>

                        NS <= ST_IDLE;
		        
		        end case;

			
			when others =>
				NS <= ST_RST;

		end case;

	end process comb_proc;



--D Flip-Flop for data_in_reg 
data_in_reg_proc : process(clk)
begin
        
    if(falling_edge(clk)) then

        if(reset = '1') then

            data_in_reg <= (others => '0') ; 

        else

            if(data_in_reg_en = '1') then

                data_in_reg <= data_in_reg_in;

            end if;

        end if;

    end if;

end process data_in_reg_proc;



-- Multiplexor for the UART signals between the cores
process (mult_sel, data_in, help_msg_data_out, help_msg_send_data, random_gen_data_out, random_gen_send_data)
begin

    -- Default signal values
    data_out_reg <= (others => '0') ;  
    send_data_reg <= '0'; 
    help_msg_data_in <= (others => '0') ;  
    random_gen_data_in <= (others => '0') ; 

    case mult_sel is

        when x"1" =>
            help_msg_data_in <= data_in ;  
            data_out_reg <= help_msg_data_out;
            send_data_reg <= help_msg_send_data;

        when x"2" =>
            random_gen_data_in <= data_in ;  
            data_out_reg <= random_gen_data_out;
            send_data_reg <= random_gen_send_data;

        when others =>

    end case;

end process;



-- Assign outputs
send_data <= send_data_reg;
data_out  <= data_out_reg;

-- Debug signals
-- debug_date_in_reg <= data_in_reg;
-- debug_help_msg_done <= help_msg_done;

end Behavioral;
