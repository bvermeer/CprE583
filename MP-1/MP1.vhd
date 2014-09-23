-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                                                                           --
-- File Name: MP1.vhd                                                    --
-- Author: Phillip Jones (phjones@iastate.edu)                               --
-- Date: 9/2/2011                                                           --
--                                                                           --
-- Description: Top level for MP1 UART-based MP                              --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY MP1_top IS
 PORT(
  sysclk    : IN  std_logic;  -- system clock
  RESET_low : IN  std_logic;  -- Active low (but polarity is immediately made active high)
  FPGA_SERIAL1_TX  : OUT std_logic;
  FPGA_SERIAL1_RX  : IN  std_logic);  
END MP1_top;

ARCHITECTURE rtl OF MP1_top IS

----------------------------------------------
--       Component declarations             --
----------------------------------------------


-- UART component: Connect the FPGA to the PC
-- over a serial (i.e. UART) cable
COMPONENT mmu_uart_top
PORT
(
        Clk     : IN std_logic;         -- main clock
        Reset_n : IN std_logic;         -- main reset(phjones made active high)
        TXD     : OUT std_logic;        -- RS232 TX data
        RXD     : IN std_logic;         -- RS232 RX data

        ck_div  : IN std_logic_vector(15 DOWNTO 0);
                                        -- clock divider value
                                        -- used to get the baud rate
                                        -- baud_rate = F(clk) / (ck_div * 3)
        -- bus interface

        CE_N    : IN std_logic;         -- chip enable
        WR_N    : IN std_logic;         -- write enable
        RD_N    : IN std_logic;         -- read enable
        A0      : IN std_logic;         -- 0 - Rx/TX data reg; 1 - status reg
        D_IN    : IN std_logic_vector(7 DOWNTO 0);
        D_OUT   : OUT std_logic_vector(7 DOWNTO 0);

        -- interrupt signals- same signals as the status register bits
        RX_full     : OUT std_logic;  -- Indicate a byte is ready to be ready from UART
        TX_busy_n   : OUT std_logic

);
END COMPONENT;



-- Component that passes data to/from a 
-- subcomponent that does the actual data processing
COMPONENT process_data
PORT
(
  clk       : IN  STD_LOGIC;
  reset     : IN  STD_LOGIC;
  data_in   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); -- data recived
  RX_full   : IN  STD_LOGIC;  -- Indicate a byte is ready to be read from UART
  TX_busy_n : IN  STD_LOGIC;  -- Active low: indicate UART is busy transmitting
  RD_n      : OUT  STD_LOGIC; -- Active low: read a byte from the UART
  WR_n      : OUT  STD_LOGIC; -- Active low: write a byte to UART for transmission
  data_out  : OUT  STD_LOGIC_VECTOR (7 DOWNTO 0) -- data to transmit

);
END COMPONENT;



----------------------------------------------
--          Signal declarations             --
----------------------------------------------
SIGNAL reset     : STD_LOGIC;  -- Reset active high
SIGNAL WR_N      : STD_LOGIC;  -- Active low write enable
SIGNAL RD_N      : STD_LOGIC;  -- Active low read enable
 
SIGNAL D_IN   : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Data to Transmit
SIGNAL D_OUT  : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Data Recieved

SIGNAL RX_full   : STD_LOGIC;     -- Byte of Data Ready to read
SIGNAL TX_busy_n : STD_LOGIC;     -- Active low indicate busy transmitting
  

BEGIN



-- Combinational assignments
reset <= NOT RESET_low;  -- convert to active high reset

-- Port map UART interface component
-- One side of the interface connects to the UART cable
-- The other side connects to your FPGA logic (i.e. the process_data component)
UART_1  : MMU_UART_TOP
PORT MAP
(
  Clk     => sysclk,          -- main clock (33 MHz)
  Reset_n => reset,           -- main reset(phjones made active high)
  TXD     => FPGA_SERIAL1_TX, -- RS232 TX data
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

  -- interrupt signals - same signals as the status register bits
  RX_full     => RX_full,  -- Received byte available next clock cycle
  TX_busy_n   => TX_busy_n
);


-- Port map process_data for processing received data
process_data_1  : PROCESS_DATA
PORT MAP
(
  clk       => sysclk,
  reset     => reset,
  data_in   => D_OUT,  -- Data received by the FPGA
  RX_full   => RX_full, -- Indicate a byte has been received by the UART
  TX_busy_n => TX_busy_n, -- Indicate UART is busy transmitting
  RD_n      => RD_n,   -- Request to read a byte from the UART
  WR_n      => WR_n,  -- Write a byte to the UART inteface for transmission
  data_out  => D_IN  -- Data to be transmitted by the FPGA
);


END rtl;
