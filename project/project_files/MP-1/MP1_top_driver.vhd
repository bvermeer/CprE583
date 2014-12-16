-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: MP1_top_driver.vhd                                             --
-- Author: Phillip Jones (phjones@iastate.edu)                               --
-- Date: 8/27/2010                                                           --
--                                                                           --
-- Description: Drives to MP1_top for simulation                             --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MP1_top_driver is
port
(
  sysclk    : in  std_logic;  -- system clock
  RESET_low : in  std_logic;  -- Active low (polartity immediately change to active high)
  FPGA_SERIAL1_TX  : out std_logic;
  FPGA_SERIAL1_RX  : in  std_logic
);  
end MP1_top_driver;

architecture rtl of MP1_top_driver is

----------------------------------------------
--       Component declarations             --
----------------------------------------------

component mmu_uart_top
port
(
        Clk     : in std_logic;         -- main clock
        Reset_n : in std_logic;         -- main reset(phjones made active high)
        TXD     : out std_logic;        -- RS232 TX data
        RXD     : in std_logic;         -- RS232 RX data

        ck_div  : in std_logic_vector(15 downto 0);
                                        -- clock divider value
                                        -- used to get the baud rate
                                        -- baud_rate = F(clk) / (ck_div * 3)
        -- bus interface

        CE_N    : in std_logic;         -- chip enable
        WR_N    : in std_logic;         -- write enable
        RD_N    : in std_logic;         -- read enable
        A0      : in std_logic;         -- 0 - Rx/TX data reg; 1 - status reg
        D_IN    : in std_logic_vector(7 downto 0);
        D_OUT   : out std_logic_vector(7 downto 0);

        -- interrupt signals- same signals as the status register bits
        RX_full     : out std_logic;
        TX_busy_n   : out std_logic

);
end component;


----------------------------------------------
--          type declarations             --
----------------------------------------------
  -- type to hold simulation data
type TEST_DATA_type is array (0 to 7) of std_logic_vector(7 downto 0);

----------------------------------------------
--          Signal declarations             --
----------------------------------------------
signal reset     : std_logic;  -- Reset active high
signal WR_N      : std_logic;  -- Active low write enable
signal RD_N      : std_logic;  -- Active low read enable
signal TXD_temp  : std_logic;  -- Allow output of TXD to test pin 

signal D_IN   : std_logic_vector(7 downto 0);  -- Data to Transmit
signal D_OUT  : std_logic_vector(7 downto 0);  -- Data Recieved
signal Data_RX_reg : std_logic_vector(7 downto 0);  -- Register RX Data

signal RX_full   : std_logic;     -- Byte of Data to Ready to read
signal TX_busy_n : std_logic;     -- Active low indicate busy transmitting
signal my_pulse  : std_logic;     -- Ensure WE_N on low for 1 clk

signal my_pause_cnt : std_logic_vector (19 downto 0); -- Slow down input ~5x

signal array_index : integer range 0 to 255; -- Index into test
                                              -- Send_Data_array  
signal Send_Data_array : TEST_DATA_type :=
  (
    x"3F", x"0A", x"02", x"03", x"04", x"05", x"06", x"07"
  );

begin


------------------------------------------------------------
------------------------------------------------------------
--                                                        --
-- Process Name: Send_chars                               --
--                                                        --
-- Send characters to MP1_top                             --
--                                                        --
------------------------------------------------------------
------------------------------------------------------------
Send_chars : process(sysclk)
begin
  if (sysclk = '1' and sysclk'event) then
    -- Defaults
    WR_N  <= '1';
    D_IN  <= D_IN;
    array_index <= array_index;
	 my_pulse <= '1'; -- Ensure WR_N on active for on clk
    
    if(reset = '1') then
      WR_N  <= '1';
      D_IN  <= (others => '0');
      array_index <= 0;
		my_pulse <= '1';
		my_pause_cnt <= (others => '0'); -- Slow down input by ~5x
    else
	 
	   my_pause_cnt <= my_pause_cnt + 1; -- Slow down input by ~5x
	 
	   if(TX_busy_n = '0') then
	     my_pulse <= '1';
	   end if;
		                                           -- Slow down input ~5x
      if(TX_busy_n = '1' and my_pulse = '1' and my_pause_cnt = x"30D40") then
		  my_pause_cnt <= (others => '0');  -- Slow down input by ~5x
		  my_pulse <= '0';
        WR_N     <= '0';   -- start transmission	  
        D_IN     <= Send_Data_array(array_index);
        array_index  <= array_index + 1;
      end if;
    end if;
      
  end if;
end process Send_chars;


------------------------------------------------------------
------------------------------------------------------------
--                                                        --
-- Process Name: Recv_chars                               --
--                                                        --
-- Send characters to MP1_top                             --
--                                                        --
------------------------------------------------------------
------------------------------------------------------------
Recv_chars : process(sysclk)
begin
  if (sysclk = '1' and sysclk'event) then
    -- Defaults
    RD_N         <= '1';
    Data_RX_reg  <= Data_RX_reg;

    if(reset = '1') then
      RD_N        <= '1';
      Data_RX_reg <= (others => '0');
    else
    
      -- Check if a byte has arrived
      if(RX_full = '1') then
        Data_RX_reg <= D_OUT;  -- Capture data from VHDL under test
        RD_N        <= '0';    -- clear read full flag
      end if;

    end if;
      
  end if;
end process Recv_chars;



-- Combinational assignments
FPGA_SERIAL1_TX  <= TXD_temp;
reset <= not RESET_low;  -- change reset to active high

-- Port map UART
UART_1  : mmu_uart_top
port map
(
  Clk     => sysclk,          -- main clock (33 MHz)
  Reset_n => reset,           -- main reset(phjones made active high)
  TXD     => TXD_temp,        -- RS232 TX data
  RXD     => FPGA_SERIAL1_RX, -- RS232 RX data

  ck_div  => x"0478",
                              -- clock divider value
                              -- used to get the baud rate
                              -- baud_rate = F(clk) / (ck_div * 3)
  -- bus interface

  CE_N    => '0',            -- chip enable
  WR_N    => WR_N,           -- write enable
  RD_N    => RD_N,           -- read enable
  A0      => '0',            -- 0 - Rx/TX data reg; 1 - status reg
  D_IN    => D_IN,           -- Data to send off-chip
  D_OUT   => D_OUT,          -- Data recieved to the chip 

  -- interrupt signals- same signals as the status register bits
  RX_full     => RX_full,
  TX_busy_n   => TX_busy_n
);


end rtl;
