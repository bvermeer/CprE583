----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Company:  Iowa State University (Ames)
-- Engineer: Dr. Phillip H. Jones III (phjones@iastate.edu)
-- 
-- Create Date:    10:11:07 09/25/2008 
-- Design Name:    MP2_scnner
-- Module Name:    MP2_scanner - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Scan incoming UDP packtes for strings and count them
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MP2_scanner is
    Port ( rx_ll_clock            : in  STD_LOGIC;
           rx_ll_reset            : in  STD_LOGIC; -- active high
           rx_ll_data_in_scn      : in  STD_LOGIC_VECTOR (7 downto 0);
           rx_ll_sof_in_n_scn     : in  STD_LOGIC;
           rx_ll_eof_in_n_scn     : in  STD_LOGIC;
           rx_ll_src_rdy_in_n_scn : in  STD_LOGIC;
           rx_ll_dst_rdy_in_n_scn : in  STD_LOGIC;
           GPIO_LED_0             : out std_logic;
			  GPIO_LED_2             : out std_logic;
			  GPIO_LED_4             : out std_logic;
           rx_ll_data_in          : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_ll_sof_in_n         : out  STD_LOGIC;
           rx_ll_eof_in_n         : out  STD_LOGIC;
           rx_ll_src_rdy_in_n     : out  STD_LOGIC;
           rx_ll_dst_rdy_in_n     : out  STD_LOGIC);
end MP2_scanner;

architecture Behavioral of MP2_scanner is

-------------------------------------------------------
-- declare constants, types,signals, and components  --
-------------------------------------------------------

-- constants
constant DELAY : integer := 10;  -- number of clock cycles to delay the input
constant DELAY_MINUS_4 : integer := DELAY - 4;
constant DELAY_MINUS_2 : integer := DELAY - 2;
  -- index relative to begining of the ethernet packet header 
constant SOIP_INDEX         : std_logic_vector(15 downto 0) := x"000E";  -- Position of begining of IP header
  -- indexes relative to beginning of the IP packet header
constant SRC_IP_AVL_INDEX   : std_logic_vector(15 downto 0) := x"000F";  -- Position of incoming src IP final byte
constant DST_IP_AVL_INDEX   : std_logic_vector(15 downto 0) := x"0013";  -- Position of incoming dst IP final byte
constant UDP_LEN_AVL_INDEX  : std_logic_vector(15 downto 0) := x"0019";  -- Position of incoming UDP Lenght final byte
constant UDP_CKSUM_AVL_INDEX  : std_logic_vector(15 downto 0) := x"001B";  -- Position of incoming UDP Checksum final byte
constant UDP_DATA_AVL_INDEX : std_logic_vector(15 downto 0) := x"001C";  -- Postion of the start of UDP payload
constant SRC_INSERT_INDEX   : std_logic_vector(15 downto 0) := SRC_IP_AVL_INDEX + DELAY_MINUS_4; 
constant DST_INSERT_INDEX   : std_logic_vector(15 downto 0) := DST_IP_AVL_INDEX + DELAY_MINUS_4;
constant UDP_CKSUM_INSERT_INDEX : std_logic_vector(15 downto 0) := UDP_CKSUM_AVL_INDEX + DELAY_MINUS_2;



-- types
type scan_state_type is (WAIT_SOF, WAIT_SOIP, IP_SRC_AVL, IP_DST_AVL,
                         UDP_LEN_AVL, START_UDP_PAYLOAD, WAIT_EOF);

type corn_state_type is (WAIT_START_SCAN,WAIT_C,WAIT_O,WAIT_R,WAIT_N,WAIT_EXCL);

type ece_state_type is (WAIT_START_SCAN,WAIT_E_ONE,WAIT_E_TWO,WAIT_C_ECE,WAIT_E_OR_C);

type gataga_state_type is (WAIT_START_SCAN,WAIT_G_ONE,WAIT_G_TWO,WAIT_A_ONE,WAIT_A_TWO,WAIT_A_THR,WAIT_T,WAIT_GATAGA_END);

type data_scn_dly_array is array (DELAY-1 downto 0) of std_logic_vector(7 downto 0);
type sof_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type eof_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type src_rdy_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type dst_rdy_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type ip_src_shift_reg_array is array (3 downto 0) of std_logic_vector(7 downto 0);
type ip_dst_shift_reg_array is array (3 downto 0) of std_logic_vector(7 downto 0);



-- signals
signal  scan_state       : scan_state_type;
signal  scan_state_next  : scan_state_type;

 -- register entity inputs
signal rx_ll_data_in_scn_reg       : std_logic_vector(7 downto 0);
signal rx_ll_sof_in_n_scn_reg      : std_logic;
signal rx_ll_eof_in_n_scn_reg      : std_logic;
signal rx_ll_src_rdy_in_n_scn_reg  : std_logic;
signal rx_ll_dst_rdy_in_n_scn_reg  : std_logic;

  -- register entity outputs
signal rx_ll_data_in_reg      : std_logic_vector(7 downto 0);
signal rx_ll_sof_in_n_reg     : std_logic;
signal rx_ll_eof_in_n_reg     : std_logic;
signal rx_ll_src_rdy_in_n_reg : std_logic;
signal rx_ll_dst_rdy_in_n_reg : std_logic;  -- reg not used


  -- Delay shift registers
signal data_scn_dly       : data_scn_dly_array; 
signal sof_n_scn_dly      : sof_n_scn_dly_array;
signal eof_n_scn_dly      : eof_n_scn_dly_array;
signal src_rdy_n_scn_dly  : src_rdy_n_scn_dly_array;
signal dst_rdy_n_scn_dly  : dst_rdy_n_scn_dly_array;  -- delay shift reg not used


  -- Shift registers for shifting src and dest IP when swapping IP src/dst address
signal ip_src_shift_reg : ip_src_shift_reg_array;
signal ip_dst_shift_reg : ip_dst_shift_reg_array;


signal eth_index_reg         : std_logic_vector(15 downto 0); -- Store postion within the ethernet packet
signal ip_index_reg          : std_logic_vector(15 downto 0); -- Store postion within the IP packet
signal udp_payload_index_reg : std_logic_vector(15 downto 0); -- UDP payload position constant offset
                                                              -- from etherent packet position

signal udp_len_reg          : std_logic_vector(15 downto 0);  -- Store UDP length
signal ip_src_addr_reg      : std_logic_vector(31 downto 0);  -- Store UDP recieved src address
signal ip_dst_addr_reg      : std_logic_vector(31 downto 0);  -- Store UDP recieved dest address
signal src_insert_shift_reg : std_logic_vector(3 downto 0);   -- Control insertions of swapped src address
signal dst_insert_shift_reg : std_logic_vector(3 downto 0);   -- Control insertion of swaped dst address
signal zero_udp_cksum_insert_shift_reg : std_logic_vector(1 downto 0);  -- Control insertion of 0'ed UDP Checksum

signal data_out_sel         : std_logic_vector(3 downto 0);  -- output data: select 
signal rx_ll_data_in_insert : std_logic_vector(7 downto 0);  -- output of output data multiplixing


  -- Flag special events
signal eth_start_flag    : std_logic;
signal eth_end_flag      : std_logic;
signal ld_ip_index_flag  : std_logic;
signal ld_src_ip_flag    : std_logic;
signal ld_dst_ip_flag    : std_logic;
signal ld_udp_len_flag   : std_logic;
signal start_scan_flag   : std_logic;
signal wr_src_IP_flag    : std_logic;   -- write new src IP address
signal wr_dst_IP_flag    : std_logic;   -- write new dest IP address
signal wr_zero_udp_cksum : std_logic;   -- write zero'ed out UDP checksum


  -- used to remove invalid data from input processing pipeling, and flow control
signal pause_flag      : std_logic; -- Indicate sender has no valid data or recieve is not ready
                                    -- (pauses scanner, forwards flow control signals to next module)
signal rx_ll_src_rdy_in_n_mux : std_logic;       
signal eof_pend_reg           : std_logic;  -- indicate the eof of the most recent packet could still be in the pipeline
signal packet_done_reg        : std_logic;  -- indicate done processing the current packet


-- CORN! search signals

signal  corn_state        : corn_state_type;
signal  corn_state_next   : corn_state_type;
signal  ece_state			  : ece_state_type;
signal  ece_state_next	  : ece_state_type;
signal  gataga_state		  : gataga_state_type;
signal  gataga_state_next : gataga_state_type;

signal corn_flag           : std_logic;
signal corn_flag_LED_reg   : std_logic;
signal ece_flag 			   : std_logic;
signal ece_flag_LED_reg    : std_logic;
signal gataga_flag 		   : std_logic;
signal gataga_flag_LED_reg : std_logic;

-- components
  -- None


begin



-- register inputs
Reg_Inputs: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
    if(rx_ll_reset = '1') then  -- active high
      rx_ll_data_in_scn_reg      <= x"CC";  --(others => '0');
      rx_ll_sof_in_n_scn_reg     <= '1'; -- recieved sof (active low)
      rx_ll_eof_in_n_scn_reg     <= '1'; -- recived eof (active low) 
      rx_ll_src_rdy_in_n_scn_reg <= '1'; -- src does not have valid data (active low)
      rx_ll_dst_rdy_in_n_scn_reg <= '1'; -- dst not ready (active low)
    else      
      rx_ll_data_in_scn_reg      <= rx_ll_data_in_scn;
      rx_ll_sof_in_n_scn_reg     <= rx_ll_sof_in_n_scn;
      rx_ll_eof_in_n_scn_reg     <= rx_ll_eof_in_n_scn;
      rx_ll_src_rdy_in_n_scn_reg <= rx_ll_src_rdy_in_n_scn; -- src does not have valid data
      rx_ll_dst_rdy_in_n_scn_reg <= rx_ll_dst_rdy_in_n_scn; -- dst not ready
    end if;
  end if;

end process Reg_Inputs;



---------------------------------------------------
--       Begin: Flag Packet Events                 --
---------------------------------------------------  

-- UpdateNxtSt_pkt
UpdateNxtSt_pkt: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
  
    if(rx_ll_reset = '1') then
      scan_state <= WAIT_SOF;
    else
      if(pause_flag = '0') then -- active high
        scan_state <= scan_state_next;
      end if;
    end if;
	 
  end if;

end process UpdateNxtSt_pkt;



-- Comp_Next_State
Comp_Nxt_ST_pkt: process(scan_state, eth_index_reg, ip_index_reg,
                         rx_ll_sof_in_n_scn_reg, rx_ll_eof_in_n_scn_reg)
begin

  -- defaults
  scan_state_next  <= scan_state;
  eth_start_flag   <= '0';
  eth_end_flag     <= '0';
  ld_ip_index_flag <= '0';
  ld_src_ip_flag   <= '0';
  ld_dst_ip_flag   <= '0';
  ld_udp_len_flag  <= '0';
  start_scan_flag  <= '0';


  case scan_state is
  
  when WAIT_SOF =>  -- wait for an ethernet packet to arrive

    if(rx_ll_sof_in_n_scn_reg = '0') then  -- active low
      eth_start_flag <= '1';
      scan_state_next <= WAIT_SOIP;
    end if;

  when WAIT_SOIP =>  -- Wait for the start of the IP header

    if(eth_index_reg = SOIP_INDEX) then
      ld_ip_index_flag <= '1';
      scan_state_next <= IP_SRC_AVL;
    end if;
           
  when IP_SRC_AVL =>

    if(ip_index_reg = SRC_IP_AVL_INDEX) then
      ld_src_ip_flag <= '1';
      scan_state_next <= IP_DST_AVL;
    end if;

  when IP_DST_AVL =>

    if(ip_index_reg = DST_IP_AVL_INDEX) then
      ld_dst_ip_flag <= '1';
      scan_state_next <= UDP_LEN_AVL;
    end if;

  when UDP_LEN_AVL =>

    if(ip_index_reg = UDP_LEN_AVL_INDEX) then
      ld_udp_len_flag <= '1';
      scan_state_next <= START_UDP_PAYLOAD;
    end if;

  when START_UDP_PAYLOAD =>

    if(ip_index_reg = UDP_DATA_AVL_INDEX) then
      start_scan_flag <= '1';
      scan_state_next <= WAIT_EOF;
    end if;

  when WAIT_EOF => -- Wait for the end of the frame
  
    if(rx_ll_eof_in_n_scn_reg = '0') then  -- active low
      eth_end_flag <= '1';
      scan_state_next <= WAIT_SOF;
    end if;

  when OTHERS =>
    scan_state_next <= WAIT_SOF;   
  end case;
	
end process Comp_Nxt_ST_pkt;


---------------------------------------------------
--       End: Flag Packet Events                 --
---------------------------------------------------


---------------------------------------------------
--       Begin: Find CORN!     (Upper case only) --
---------------------------------------------------
-- UpdateNxtSt_corn!
UpdateNxtSt_corn: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
  
    if(rx_ll_reset = '1') then
      corn_state <= WAIT_START_SCAN;
    else
      if(pause_flag = '0') then -- active high
        corn_state <= corn_state_next;
      end if;
    end if;
	 
  end if;

end process UpdateNxtSt_corn;

  
-- Comp_Next_State
Comp_Nxt_ST_corn: process(corn_state, start_scan_flag, data_scn_dly(0), 
                          eof_n_scn_dly(1))
begin

  -- defaults
  corn_state_next <= corn_state;
  corn_flag       <= '0';   -- Indicate when CORN! found 


  if(eof_n_scn_dly(1) = '0') then -- check for the end of the payload
    corn_state_next <= WAIT_START_SCAN;
    
  else
  
    case corn_state is
  
    when WAIT_START_SCAN =>  -- wait for payload

      if(start_scan_flag = '1') then
        corn_state_next <= WAIT_C;
      end if;

      
    when WAIT_C =>

      if(data_scn_dly(0) = x"43") then
        corn_state_next <= WAIT_O;
      end if;
      
    when WAIT_O =>
     
      if(data_scn_dly(0) = x"4F") then
        corn_state_next <= WAIT_R;
      else
        corn_state_next <= WAIT_C;
      end if;
		
    when WAIT_R =>
     
      if(data_scn_dly(0) = x"52") then
        corn_state_next <= WAIT_N;
      else
        corn_state_next <= WAIT_C;
      end if;
     
    when WAIT_N =>
     
      if(data_scn_dly(0) = x"4E") then
        corn_state_next <= WAIT_EXCL;
      else
        corn_state_next <= WAIT_C;
      end if;
     
    when WAIT_EXCL =>
         
      if(data_scn_dly(0) = x"21") then
        corn_flag <= '1';               -- Flag found CORN!
        corn_state_next <= WAIT_C;
      else
        corn_state_next <= WAIT_C;
      end if;
      
    when OTHERS =>
      corn_state_next <= WAIT_START_SCAN;   
    end case;
    
  end if; -- check for end of payload
end process Comp_Nxt_ST_corn;

      

---------------------------------------------------
--       End: Find CORN!       (Upper case only) --
---------------------------------------------------



---------------------------------------------------
--       Begin: Find ECE        (Upper case only)--
---------------------------------------------------
-- UpdateNxtSt_ece
UpdateNxtSt_ece: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
  
    if(rx_ll_reset = '1') then
      ece_state <= WAIT_START_SCAN;
    else
      if(pause_flag = '0') then -- active high
        ece_state <= ece_state_next;
      end if;
    end if;
	 
  end if;

end process UpdateNxtSt_ece;

  
-- Comp_Next_State
Comp_Nxt_ST_ece: process(ece_state, start_scan_flag, data_scn_dly(0), 
                          eof_n_scn_dly(1))
begin

  -- defaults
  ece_state_next <= ece_state;
  ece_flag       <= '0';   -- Indicate when ECE found 


  if(eof_n_scn_dly(1) = '0') then -- check for the end of the payload
    ece_state_next <= WAIT_START_SCAN;
    
  else
  
    case ece_state is
  
    when WAIT_START_SCAN =>  -- wait for payload

      if(start_scan_flag = '1') then
        ece_state_next <= WAIT_E_ONE;
      end if;

      
    when WAIT_E_ONE =>

      if(data_scn_dly(0) = x"45") then
        ece_state_next <= WAIT_C_ECE;
      end if;
      
    when WAIT_C_ECE =>
     
      if(data_scn_dly(0) = x"43") then
        ece_state_next <= WAIT_E_TWO;
      elsif(data_scn_dly(0) = x"45") then
        ece_state_next <= WAIT_C_ECE;
		else
		  ece_state_next <= WAIT_E_ONE;
      end if;
		
    when WAIT_E_TWO =>
     
      if(data_scn_dly(0) = x"45") then
        ece_flag <= '1';					-- Flag found ECE
		  ece_state_next <= WAIT_E_OR_C;
      else
        ece_state_next <= WAIT_E_ONE;
      end if;
     
    when WAIT_E_OR_C =>
     
      if(data_scn_dly(0) = x"45") then
        ece_state_next <= WAIT_C_ECE;
      elsif(data_scn_dly(0) = x"43") then
        ece_state_next <= WAIT_E_TWO;
		else
		  ece_state_next <= WAIT_E_ONE;
      end if;
      
    when OTHERS =>
      ece_state_next <= WAIT_START_SCAN;   
    end case;
    
  end if; -- check for end of payload
end process Comp_Nxt_ST_ece;


---------------------------------------------------
--       End: Find ECE  (Upper case only)        --
---------------------------------------------------


---------------------------------------------------
--       Begin: Find GATAGA    (Upper case only) --
---------------------------------------------------
-- UpdateNxtSt_gataga
UpdateNxtSt_gataga: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
  
    if(rx_ll_reset = '1') then
      gataga_state <= WAIT_START_SCAN;
    else
      if(pause_flag = '0') then -- active high
        gataga_state <= gataga_state_next;
      end if;
    end if;
	 
  end if;

end process UpdateNxtSt_gataga;

  
-- Comp_Next_State
Comp_Nxt_ST_gataga: process(gataga_state, start_scan_flag, data_scn_dly(0), 
                          eof_n_scn_dly(1))
begin

  -- defaults
  gataga_state_next <= gataga_state;
  gataga_flag       <= '0';   -- Indicate when ECE found 


  if(eof_n_scn_dly(1) = '0') then -- check for the end of the payload
    gataga_state_next <= WAIT_START_SCAN;
    
  else
  
    case gataga_state is
  
    when WAIT_START_SCAN =>  -- wait for payload

      if(start_scan_flag = '1') then
        gataga_state_next <= WAIT_G_ONE;
      end if;

      
    when WAIT_G_ONE =>

      if(data_scn_dly(0) = x"47") then
        gataga_state_next <= WAIT_A_ONE;
      end if;
      
    when WAIT_A_ONE =>
     
      if(data_scn_dly(0) = x"41") then
        gataga_state_next <= WAIT_T;
      elsif(data_scn_dly(0) = x"47") then
        gataga_state_next <= WAIT_A_ONE;
		else
		  gataga_state_next <= WAIT_G_ONE;
      end if;
		
    when WAIT_T =>
     
      if(data_scn_dly(0) = x"54") then
        gataga_state_next <= WAIT_A_TWO;
      elsif(data_scn_dly(0) = x"47") then
        gataga_state_next <= WAIT_A_ONE;
		else
		  gataga_state_next <= WAIT_G_ONE;
      end if;
     
    when WAIT_A_TWO =>
     
      if(data_scn_dly(0) = x"41") then
        gataga_state_next <= WAIT_G_TWO;
      elsif(data_scn_dly(0) = x"47") then
        gataga_state_next <= WAIT_A_ONE;
		else
		  gataga_state_next <= WAIT_G_ONE;
      end if;
		
	 when WAIT_G_TWO =>
	 
	   if(data_scn_dly(0) = x"47") then
        gataga_state_next <= WAIT_A_THR;
		else
		  gataga_state_next <= WAIT_G_ONE;
      end if;
		
    when WAIT_A_THR =>	 
    
	   if(data_scn_dly(0) = x"41") then
		  gataga_flag <= '1';					-- Flag GATAGA found
        gataga_state_next <= WAIT_GATAGA_END;
      elsif(data_scn_dly(0) = x"47") then
        gataga_state_next <= WAIT_A_ONE;
		else
		  gataga_state_next <= WAIT_G_ONE;
      end if;

   when WAIT_GATAGA_END =>

      if(data_scn_dly(0) = x"47") then
        gataga_state_next <= WAIT_A_ONE;
      elsif(data_scn_dly(0) = x"54") then
        gataga_state_next <= WAIT_A_TWO;
		else
		  gataga_state_next <= WAIT_G_ONE;
      end if;
			
    when OTHERS =>
      gataga_state_next <= WAIT_START_SCAN;   
    end case;
    
  end if; -- check for end of payload
end process Comp_Nxt_ST_gataga;


---------------------------------------------------
------------  End: Find GATAGA  -------------------
---------------------------------------------------






-- Register and Counter Management
Reg_Cnt_Mgr: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
    if(rx_ll_reset = '1') then -- active high   

      -- Initialize shift registers
      -- (Note: this is a good use for varibles, and loops)
      for array_index in data_scn_dly'range loop
        data_scn_dly(array_index)      <= x"AA"; --(others => '0');
        sof_n_scn_dly(array_index)     <= '1'; -- active low
        eof_n_scn_dly(array_index)     <= '1'; -- active low
        src_rdy_n_scn_dly(array_index) <= '1'; -- active low
      end loop;

      for array_index in ip_src_shift_reg'range loop      
        ip_src_shift_reg(array_index) <= (others => '0');
        ip_dst_shift_reg(array_index) <= (others => '0');
      end loop;

      udp_len_reg           <= (others => '1');  -- Lenth of the UDP packect
      eth_index_reg         <= (others => '0');  -- Position within the ehternet packet
      ip_index_reg          <= (others => '0');  -- Position within the IP packet
      udp_payload_index_reg <= (others => '0');  -- Position within the UDP payload
      ip_src_addr_reg       <= (others => '0');  -- IP src address
      ip_dst_addr_reg       <= (others => '0');  -- IP dst address
      src_insert_shift_reg  <= (others => '0');  -- control spicing src address into output stream
      dst_insert_shift_reg  <= (others => '0');
      zero_udp_cksum_insert_shift_reg <= (others => '0'); -- control writing 0'ed UDP checksum into output stream 
      packet_done_reg       <= '1';
      eof_pend_reg          <= '0';
      corn_flag_LED_reg     <= '0';
		ece_flag_LED_reg		 <= '0';
		gataga_flag_LED_reg   <= '0';
      
    else

      if(pause_flag = '0')  then -- active high

        
        -- Your String Match Counter code starts here --
        if(corn_flag = '1') then
          corn_flag_LED_reg <= not corn_flag_LED_reg;  -- toggles LED each time CORN! found
        end if;
        if(ece_flag = '1') then
          ece_flag_LED_reg <= not ece_flag_LED_reg;  -- toggles LED each time ECE found
        end if;
        if(gataga_flag = '1') then
          gataga_flag_LED_reg <= not gataga_flag_LED_reg;  -- toggles LED each time GATAGA found
        end if;
        
        
        -- Your String Match Counter code ends here --
  
  
  
        -- delay all registered input by 10 clock cycles  
        data_scn_dly(data_scn_dly'high downto 0) <= 
          data_scn_dly(data_scn_dly'high-1 downto 0) & rx_ll_data_in_scn_reg;
	 
        sof_n_scn_dly(sof_n_scn_dly'high downto 0) <= 
          sof_n_scn_dly(sof_n_scn_dly'high-1 downto 0) & rx_ll_sof_in_n_scn_reg;
	 
        eof_n_scn_dly(eof_n_scn_dly'high downto 0) <= 
          eof_n_scn_dly(eof_n_scn_dly'high-1 downto 0) & rx_ll_eof_in_n_scn_reg;

        src_rdy_n_scn_dly(src_rdy_n_scn_dly'high downto 0) <= 
          src_rdy_n_scn_dly(src_rdy_n_scn_dly'high-1 downto 0) & rx_ll_src_rdy_in_n_scn_reg;

      
        -- store UDP payload length
	if(ld_udp_len_flag = '1') then
          udp_len_reg <= data_scn_dly(0) & rx_ll_data_in_scn_reg;
        elsif (rx_ll_eof_in_n_reg = '0') then  -- active low
          udp_len_reg <= (others => '1'); -- reset udp_length to 0xFFFF 
        else
          udp_len_reg <= udp_len_reg;
        end if;

        -- Track the postion within the ethernet packet
        if(eth_start_flag = '1') then
          eth_index_reg <= x"0001"; --set index postion to 1
        elsif (eth_end_flag = '1') then
          eth_index_reg <= (others => '0'); --set index position to 0
        else
          eth_index_reg <= eth_index_reg + 1; -- Increse payload position indicator 
        end if;

        -- Track the postion within the IP packet
        if(ld_ip_index_flag = '1') then
          ip_index_reg <= x"0001";  --set index position to 1
          packet_done_reg <= '0';
        elsif (packet_done_reg = '0') then  -- while IP packet is being processed
          ip_index_reg <= ip_index_reg + 1; -- increse payload position indicator
        else
          ip_index_reg <= ip_index_reg;          
        end if;

         -- Track the postion within the UDP payload
        if(start_scan_flag = '1') then
          udp_payload_index_reg <= x"0001";  --set index position to 1
        elsif (packet_done_reg = '0') then  -- while IP packet is being processed
          udp_payload_index_reg <= udp_payload_index_reg + 1; -- increse payload position indicator
        else
          udp_payload_index_reg <= udp_payload_index_reg;          
        end if;


        -- indicate finished processing the current IP packet
        if(rx_ll_eof_in_n_reg = '0') then
          packet_done_reg <= '1'; 
        end if;

        
        -- Load IP src address from input stream into a register
        if(ld_src_ip_flag = '1') then
          ip_src_addr_reg <= data_scn_dly(2) & data_scn_dly(1) & data_scn_dly(0) & rx_ll_data_in_scn_reg;
        end if;

        -- Load IP dst address from input stream into a register
        if(ld_dst_ip_flag = '1') then
          ip_dst_addr_reg <= data_scn_dly(2) & data_scn_dly(1) & data_scn_dly(0) & rx_ll_data_in_scn_reg;
        end if;

        -- Indicate time to write new src IP address into output stream
	-- and shift out new src IP address (i.e orginail dest IP address)
        if(SRC_INSERT_INDEX = ip_index_reg) then
          src_insert_shift_reg <= "1111";
          ip_src_shift_reg(3) <= ip_dst_addr_reg(31 downto 24);
          ip_src_shift_reg(2) <= ip_dst_addr_reg(23 downto 16);
          ip_src_shift_reg(1) <= ip_dst_addr_reg(15 downto 8);
          ip_src_shift_reg(0) <= ip_dst_addr_reg(7 downto 0);
        else
          src_insert_shift_reg(src_insert_shift_reg'high downto 0) <=
            src_insert_shift_reg(src_insert_shift_reg'high-1 downto 0) & '0';
		  
          ip_src_shift_reg(ip_src_shift_reg'high downto 0) <= 
            ip_src_shift_reg(ip_src_shift_reg'high-1 downto 0) & x"00";
        end if;	 

        -- Indicate time to write dst IP address into output stream
        if(DST_INSERT_INDEX = ip_index_reg) then
          dst_insert_shift_reg <= "1111";
          ip_dst_shift_reg(3) <= ip_src_addr_reg(31 downto 24);
          ip_dst_shift_reg(2) <= ip_src_addr_reg(23 downto 16);
          ip_dst_shift_reg(1) <= ip_src_addr_reg(15 downto 8);
          ip_dst_shift_reg(0) <= ip_src_addr_reg(7 downto 0);
        else
          dst_insert_shift_reg(dst_insert_shift_reg'high downto 0) <=
            dst_insert_shift_reg(dst_insert_shift_reg'high-1 downto 0) & '0';
		  
          ip_dst_shift_reg(ip_dst_shift_reg'high downto 0) <= 
            ip_dst_shift_reg(ip_dst_shift_reg'high-1 downto 0) & x"00";
        end if;	 

        -- Indicate time to write zeroed out UDP checksum into output stream
        if(UDP_CKSUM_INSERT_INDEX = ip_index_reg) then
          zero_udp_cksum_insert_shift_reg <= "11";
        else
          zero_udp_cksum_insert_shift_reg(zero_udp_cksum_insert_shift_reg'high downto 0) <=
            zero_udp_cksum_insert_shift_reg(zero_udp_cksum_insert_shift_reg'high-1 downto 0) & '0';
        end if;	 
        
        -- Indicate an eof has been detected, and the next sof has not arrived
	if(eth_end_flag = '1') then
          eof_pend_reg <= '1';
        elsif (eth_start_flag = '1') then
          eof_pend_reg <= '0'; 
        else
          eof_pend_reg <= eof_pend_reg;
        end if;
      
      end if; -- end pause
    end if; -- end reset
  end if; -- end clk'event
end process Reg_Cnt_Mgr;



------------------------------------------------------------
------------------------------------------------------------
-- Name: Sel_output                                       --
-- Description:  Choose between the following sources     -- 
--                                                        --
--  1. Src IP                                             --
--  2. Dest IP                                            --
--  4. Zero out UDP checksum                              --
--  8. ??                                                 --
--  others. Input stream                                  --
--                                                        --
------------------------------------------------------------
------------------------------------------------------------
Sel_output: process(data_out_sel, ip_src_shift_reg(ip_src_shift_reg'high),
                    ip_dst_shift_reg(ip_dst_shift_reg'high), data_scn_dly(data_scn_dly'high) )
begin

  case data_out_sel is
  when x"1" =>
    rx_ll_data_in_insert <= ip_src_shift_reg(ip_src_shift_reg'high); -- insert new src IP to output
  when x"2" =>
    rx_ll_data_in_insert <= ip_dst_shift_reg(ip_dst_shift_reg'high); -- insert new dest IP to output
  when x"4" =>
    rx_ll_data_in_insert <= x"00"; -- Zero out UDP checksum, tells OS to ignore checksum
  when OTHERS =>
    rx_ll_data_in_insert <= data_scn_dly(data_scn_dly'high); -- unmodified input data    
  end case;
	
end process Sel_output;

wr_src_IP_flag <= src_insert_shift_reg(src_insert_shift_reg'high);
wr_dst_IP_flag <= dst_insert_shift_reg(dst_insert_shift_reg'high);
wr_zero_udp_cksum <= zero_udp_cksum_insert_shift_reg(zero_udp_cksum_insert_shift_reg'high);
data_out_sel   <= "0" & wr_zero_udp_cksum & wr_dst_IP_flag & wr_src_IP_flag;     -- output data select 



------------------------------------------------------------
------------------------------------------------------------
-- Name: Reg_Outputs                                      --
-- Description:  Register the outputs of this entity      -- 
--                                                        --
------------------------------------------------------------
------------------------------------------------------------
Reg_Outputs: process(rx_ll_clock)
begin
  if(rx_ll_clock'event and rx_ll_clock = '1') then
    if(rx_ll_reset = '1') then -- active high
      rx_ll_data_in_reg        <= (others => '0');
      rx_ll_sof_in_n_reg       <= '1';  -- active low
      rx_ll_eof_in_n_reg       <= '1';  -- active low
      rx_ll_src_rdy_in_n_reg   <= '1';  -- active low
    else
      if(pause_flag = '0') then -- pause output if flow control active
        rx_ll_data_in_reg        <= rx_ll_data_in_insert;
        rx_ll_sof_in_n_reg       <= sof_n_scn_dly(sof_n_scn_dly'high);
        rx_ll_eof_in_n_reg       <= eof_n_scn_dly(eof_n_scn_dly'high);
        rx_ll_src_rdy_in_n_reg   <= src_rdy_n_scn_dly(src_rdy_n_scn_dly'high);
      end if;
    end if;
  end if;
end process Reg_Outputs;


-- Non-process Combinational assignments

  -- start flow control, and invaild data bubble removal
pause_flag <= '1' when (rx_ll_dst_rdy_in_n_scn_reg = '1') or
                       ((rx_ll_src_rdy_in_n_scn_reg = '1') and (eof_pend_reg = '0'))   -- pause active high,
                  else
              '0';


rx_ll_src_rdy_in_n_mux <=  '1' when ((rx_ll_src_rdy_in_n_scn_reg = '1') and (eof_pend_reg = '0')) 
                               else
                          rx_ll_src_rdy_in_n_reg;  -- src ready from delay reg 

  -- end flow control, and invalid data bubble removal



  -- Assign output ports
GPIO_LED_0           <= corn_flag_LED_reg;
GPIO_LED_2           <= ece_flag_LED_reg;
GPIO_LED_4           <= gataga_flag_LED_reg;

rx_ll_data_in        <= rx_ll_data_in_reg;
rx_ll_sof_in_n       <= rx_ll_sof_in_n_reg;
rx_ll_eof_in_n       <= rx_ll_eof_in_n_reg;
rx_ll_src_rdy_in_n   <= rx_ll_src_rdy_in_n_mux;     -- mux between direct input, and dly shift register  
rx_ll_dst_rdy_in_n   <= rx_ll_dst_rdy_in_n_scn_reg; -- pass flow control signal directly from register input


end Behavioral;

