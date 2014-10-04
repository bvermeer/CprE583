------------------------------------------------------------------------
-- Title      : Demo testbench
-- Project    : Virtex-5 Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : emac0_phy_tb.vhd
------------------------------------------------------------------------
-- Copyright (c) 2004-2008 by Xilinx, Inc. All rights reserved.
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you
-- a license to use this text/file solely for design, simulation,
-- implementation and creation of design files limited
-- to Xilinx devices or technologies. Use with non-Xilinx
-- devices or technologies is expressly prohibited and
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information
-- "as is" solely for use in developing programs and
-- solutions for Xilinx devices. By providing this design,
-- code, or information as one possible implementation of
-- this feature, application or standard, Xilinx is making no
-- representation that this implementation is free from any
-- claims of infringement. You are responsible for
-- obtaining any rights you may require for your implementation.
-- Xilinx expressly disclaims any warranty whatsoever with
-- respect to the adequacy of the implementation, including
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied
-- warranties of merchantability or fitness for a particular
-- purpose.
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications are
-- expressly prohibited.
--
-- This copyright and support notice must be retained as part
-- of this text at all times. (c) Copyright 2004-2008 Xilinx, Inc.
-- All rights reserved.
------------------------------------------------------------------------
-- Description: This testbench will exercise the PHY ports of the EMAC
--              to demonstrate the functionality.
------------------------------------------------------------------------
--
-- This testbench performs the following operations on the EMAC 
-- and its design example:

--  - Four frames are pushed into the receiver from the PHY 
--    interface (GMII/MII):
--    The first is of minimum length (Length/Type = Length = 46 bytes).
--    The second frame sets Length/Type to Type = 0x8000. 
--    The third frame has an error inserted. 
--    The fourth frame only sends 4 bytes of data: the remainder of the 
--    data field is padded up to the minimum frame length i.e. 46 bytes.

--  - These frames are then parsed from the MAC into the MAC's design
--    example.  The design example provides a MAC client loopback 
--    function so that frames which are received without error will be 
--    looped back to the MAC transmitter and transmitted back to the
--    testbench.  The testbench verifies that this data matches that 
--    previously injected into the receiver.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity emac0_phy_tb is
    port(
      ------------------------------------------------------------------
      -- GMII Interface
      ------------------------------------------------------------------
      gmii_txd              : in  std_logic_vector(7 downto 0); 
      gmii_tx_en            : in  std_logic;    
      gmii_tx_er            : in  std_logic;    
      gmii_tx_clk           : in  std_logic;    
      gmii_rxd              : out std_logic_vector(7 downto 0); 
      gmii_rx_dv            : out std_logic;    
      gmii_rx_er            : out std_logic;    
      gmii_rx_clk           : out std_logic;
      gmii_col              : out std_logic;
      gmii_crs              : out std_logic;
      mii_tx_clk            : out std_logic;

      ------------------------------------------------------------------
      -- Test Bench Semaphores
      ------------------------------------------------------------------
      configuration_busy    : in  boolean;
      monitor_finished_1g   : out boolean;
      monitor_finished_100m : out boolean;
      monitor_finished_10m  : out boolean
      );
end emac0_phy_tb;


architecture behavioral of emac0_phy_tb is

  
  ----------------------------------------------------------------------
  -- types to support frame data
  ----------------------------------------------------------------------
  -- Tx Data and Data_valid record
  type data_typ is record
      data : bit_vector(7 downto 0);  -- data
      valid : bit;                    -- data_valid
      error : bit;                    -- data_error
  end record;
  type frame_of_data_typ is array (natural range <>) of data_typ;

  -- Tx Data, Data_valid and underrun record
  type frame_typ is record
      columns   : frame_of_data_typ(0 to 255);-- data field
      bad_frame : boolean;  -- does this frame contain an error?
  end record;
  type frame_typ_ary is array (natural range <>) of frame_typ;

  ----------------------------------------------------------------------
  -- Stimulus - Frame data 
  ----------------------------------------------------------------------
  -- The following constant holds the stimulus for the testbench. It is 
  -- an ordered array of frames, with frame 0 being the first to be injected 
  -- into the core receiver PHY interface by the testbench. 
  ----------------------------------------------------------------------
  constant frame_data : frame_typ_ary := (
   -------------
   -- Frame 0
   -------------
    0          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       49      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       50      => ( DATA => X"28", VALID => '1', ERROR => '0'),  -- Word 10
       51      => ( DATA => X"29", VALID => '1', ERROR => '0'),
       52      => ( DATA => X"2A", VALID => '1', ERROR => '0'),
       53      => ( DATA => X"2B", VALID => '1', ERROR => '0'),
       54      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       55      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 1
   -------------
    1          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'), -- Must update feild if you change length!
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),  -- Must update field if you change lenghth!
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"28", VALID => '1', ERROR => '0'),  -- Word 10
       51      => ( DATA => X"29", VALID => '1', ERROR => '0'),
       52      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       53      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       54      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       55      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 2
   -------------
    2          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       52      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       53      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       54      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       55      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 3
   -------------
    3          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       52      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       53      => ( DATA => X"52", VALID => '1', ERROR => '0'),  -- R
       54      => ( DATA => X"4E", VALID => '1', ERROR => '0'),  -- N
       55      => ( DATA => X"21", VALID => '1', ERROR => '0'),  -- !
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 4
   -------------
    4          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       52      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       53      => ( DATA => X"52", VALID => '1', ERROR => '0'),  -- R
       54      => ( DATA => X"4E", VALID => '1', ERROR => '0'),  -- N
       55      => ( DATA => X"21", VALID => '1', ERROR => '0'),  -- !
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 5
   -------------
    5          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       52      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       53      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       54      => ( DATA => X"20", VALID => '1', ERROR => '0'),  -- "Space"
       55      => ( DATA => X"2E", VALID => '1', ERROR => '0'),  
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),




   -------------
   -- Frame 6
   -------------
    6          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       52      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       53      => ( DATA => X"52", VALID => '1', ERROR => '0'),  -- R
       54      => ( DATA => X"4E", VALID => '1', ERROR => '0'),  -- N
       55      => ( DATA => X"21", VALID => '1', ERROR => '0'),  -- !
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 7
   -------------
    7          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       52      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       53      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       54      => ( DATA => X"20", VALID => '1', ERROR => '0'),  --"Space"
       55      => ( DATA => X"21", VALID => '1', ERROR => '0'),  
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),



   -------------
   -- Frame 8
   -------------
    8          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       52      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       53      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       54      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       55      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E 
       56      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       57      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       58      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 9
   -------------
    9          => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       52      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       53      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       54      => ( DATA => X"20", VALID => '1', ERROR => '0'),  --"Space"
       55      => ( DATA => X"21", VALID => '1', ERROR => '0'),  
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 10
   -------------
    10         => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G
       52      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       53      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- T
       54      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       55      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G 
       56      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 11
   -------------
    11         => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       52      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       53      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E
       54      => ( DATA => X"20", VALID => '1', ERROR => '0'),  --"Space"
       55      => ( DATA => X"21", VALID => '1', ERROR => '0'),  
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 12
   -------------
    12         => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"26", VALID => '1', ERROR => '0'),  
       49      => ( DATA => X"27", VALID => '1', ERROR => '0'),  
       50      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- Word 10 -- O 
       51      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G
       52      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       53      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- T
       54      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       55      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G 
       56      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


   -------------
   -- Frame 13
   -------------
    13         => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G
       44      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       45      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- T
       46      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- Word 9 -- A
       47      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G
       48      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A 
       49      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- T
       50      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- Word 10 -- A 
       51      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G
       52      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       53      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- T
       54      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       55      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G 
       56      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),




   -------------
   -- Frame 14
   -------------
    14         => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"10", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 
       43      => ( DATA => X"11", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"12", VALID => '1', ERROR => '0'),
       45      => ( DATA => X"23", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"24", VALID => '1', ERROR => '0'),  -- Word 9
       47      => ( DATA => X"25", VALID => '1', ERROR => '0'),
       48      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C  
       49      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       50      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C Word 10
       51      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- 0
       52      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       53      => ( DATA => X"4F", VALID => '1', ERROR => '0'),  -- O
       54      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       55      => ( DATA => X"2D", VALID => '1', ERROR => '0'), 
       56      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       57      => ( DATA => X"2F", VALID => '1', ERROR => '0'),
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
    


   -------------
   -- Frame 15
   -------------
    15         => (
      columns  => (
        0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Ethernet Destination Address (DA)
        1      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"04", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"05", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"06", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Ethernet Source Address (5A)
        7      => ( DATA => X"02", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"03", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"06", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Ethernet Length = 46 (x"002E") bytes
       13      => ( DATA => X"2E", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- Word 1 of IP packet
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- Word 2 of IP packet
       19      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"02", VALID => '1', ERROR => '0'), 
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"FF", VALID => '1', ERROR => '0'),  -- Word 3 of IP packet
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'),    -- Protocol = UDP = 17 (x"11)
       24      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       25      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"AA", VALID => '1', ERROR => '0'),  -- Word 4 of IP packet (src address)
       27      => ( DATA => X"BB", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"CC", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"DD", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"55", VALID => '1', ERROR => '0'),  -- Word 5 of IP packet (dst address)
       31      => ( DATA => X"66", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"77", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"88", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"11", VALID => '1', ERROR => '0'),  -- UDP src port (x"1122"), Word 6 
       35      => ( DATA => X"22", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"EE", VALID => '1', ERROR => '0'),  -- UDP dst port (x"EEFF")
       37      => ( DATA => X"FF", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP length = 26 (x"001A") bytes, Word 7 
       39      => ( DATA => X"1A", VALID => '1', ERROR => '0'),
       40      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- UDP checksum
       41      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       42      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- UDP payload, Word 8 C
       43      => ( DATA => X"4F", VALID => '1', ERROR => '0'), -- O
       44      => ( DATA => X"52", VALID => '1', ERROR => '0'), -- R
       45      => ( DATA => X"4E", VALID => '1', ERROR => '0'), -- N
       46      => ( DATA => X"21", VALID => '1', ERROR => '0'),  -- ! Word 9 
       47      => ( DATA => X"20", VALID => '1', ERROR => '0'), -- Space
       48      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E  
       49      => ( DATA => X"43", VALID => '1', ERROR => '0'),  -- C
       50      => ( DATA => X"45", VALID => '1', ERROR => '0'),  -- E Word 10
       51      => ( DATA => X"20", VALID => '1', ERROR => '0'),  -- Space
       52      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G
       53      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       54      => ( DATA => X"54", VALID => '1', ERROR => '0'),  -- T
       55      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       56      => ( DATA => X"47", VALID => '1', ERROR => '0'),  -- G
       57      => ( DATA => X"41", VALID => '1', ERROR => '0'),  -- A
       58      => ( DATA => X"30", VALID => '1', ERROR => '0'),
       59      => ( DATA => X"31", VALID => '1', ERROR => '0'),	-- 46th Byte of Ethernet payload
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false)


    );



  ----------------------------------------------------------------------
  -- CRC engine 
  ----------------------------------------------------------------------
  function calc_crc (data : in std_logic_vector;
                     fcs  : in std_logic_vector)
  return std_logic_vector is   

     variable crc          : std_logic_vector(31 downto 0);
     variable crc_feedback : std_logic;	  
  begin

    crc := not fcs;

    for I in 0 to 7 loop
      crc_feedback      := crc(0) xor data(I);

      crc(4 downto 0)   := crc(5 downto 1);
      crc(5)            := crc(6)  xor crc_feedback;
      crc(7 downto 6)   := crc(8 downto 7);
      crc(8)            := crc(9)  xor crc_feedback;
      crc(9)            := crc(10) xor crc_feedback;
      crc(14 downto 10) := crc(15 downto 11);
      crc(15)           := crc(16) xor crc_feedback;
      crc(18 downto 16) := crc(19 downto 17);
      crc(19)           := crc(20) xor crc_feedback;
      crc(20)           := crc(21) xor crc_feedback;
      crc(21)           := crc(22) xor crc_feedback;
      crc(22)           := crc(23);
      crc(23)           := crc(24) xor crc_feedback;
      crc(24)           := crc(25) xor crc_feedback;
      crc(25)           := crc(26);
      crc(26)           := crc(27) xor crc_feedback;
      crc(27)           := crc(28) xor crc_feedback;
      crc(28)           := crc(29);
      crc(29)           := crc(30) xor crc_feedback;
      crc(30)           := crc(31) xor crc_feedback;
      crc(31)           :=             crc_feedback;
    end loop; 
      
    -- return the CRC result                                  
    return not crc;

  end calc_crc;



  -- Delay to provide setup and hold timing at the GMII/MII.
  constant dly : time := 2 ns; 


  -- testbench signals
  signal mii_tx_clk_int      : std_logic := '0';
  signal mii_tx_clk100       : std_logic := '0';
  signal mii_tx_clk10        : std_logic := '0';

  signal gmii_rx_clk_int     : std_logic := '0';
  signal gmii_rx_clk1000     : std_logic := '0';
  signal gmii_rx_clk100      : std_logic := '0';
  signal gmii_rx_clk10       : std_logic := '0';


  -- testbench control signals
  signal current_speed       : string(1 to 6);


  
begin  -- behavioral


  -- Currently not used in this testbench.
  gmii_col <= '0';
  gmii_crs <= '0';



  mii_tx_clk <= mii_tx_clk_int;


  ----------------------------------------------------------------------
  -- gmii_rx_clk clock driver
  ----------------------------------------------------------------------


  -- drives gmii_rx_clk at 125 MHz for 1000Mb/s operation
  p_gmii_rx_clk1000 : process    
  begin
    gmii_rx_clk_int <= '0';
    wait for 20 ns;
    loop
      wait for 4 ns;                  
      gmii_rx_clk_int <= '1';
      wait for 4 ns;
      gmii_rx_clk_int <= '0';
    end loop;
  end process p_gmii_rx_clk1000;

  gmii_rx_clk <= gmii_rx_clk_int;


  ----------------------------------------------------------------------
  -- Simulus process
  ------------------
  -- Send four frames through the MAC and Design Example
  --      -- frame 0 = Contains 2 CO's
  --      -- frame 1 = Contains a CCCO
  --      -- frame 2 = Contains a OOOCCO
  --      -- frame 3 = Contatins a COCOCOC
  ----------------------------------------------------------------------
  p_stimulus : process
    variable current_col : natural := 0;  -- Column counter within frame
    variable fcs         : std_logic_vector(31 downto 0);    
  begin

  -- Initialise GMII
  gmii_rxd     <= "00000000";
  gmii_rx_dv   <= '0';
  gmii_rx_er   <= '0';

  -- Wait for the configuration to initialise the MAC
  wait until configuration_busy;
  wait until not configuration_busy;

  current_speed <= "1gig  ";

  ------------------------------------
  -- Send frames at 1Gb/s speed
  ------------------------------------

  wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
	
  for current_frame in frame_data'low to frame_data'high loop

    assert false
      report "EMAC0: Sending Frame " & integer'image(current_frame) & " at 1Gb/s" & cr
      severity note;

    -- Adding the preamble field
    for j in 0 to 7 loop
      gmii_rxd   <= "01010101" after dly;
      gmii_rx_dv <= '1' after dly;
      gmii_rx_er <= '0' after dly;
      wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
    end loop;

    -- Adding the Start of Frame Delimiter (SFD)
    gmii_rxd   <= "11010101" after dly;
    gmii_rx_dv <= '1' after dly;
    wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
	  
    -- Sending the MAC frame
    fcs         := (others => '0'); -- reset the FCS field
    current_col := 0;
    gmii_rxd    <= to_stdlogicvector(frame_data(current_frame).columns(current_col).data) after dly;
    fcs         := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
    gmii_rx_dv  <= to_stdUlogic(frame_data(current_frame).columns(current_col).valid) after dly;
    gmii_rx_er  <= to_stdUlogic(frame_data(current_frame).columns(current_col).error) after dly;
    
    wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
	  
    current_col   := current_col + 1;
    -- loop over columns in frame.
    while frame_data(current_frame).columns(current_col).valid /= '0' loop
      -- send one column of data
      gmii_rxd    <= to_stdlogicvector(frame_data(current_frame).columns(current_col).data) after dly;
      fcs         := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
      gmii_rx_dv  <= to_stdUlogic(frame_data(current_frame).columns(current_col).valid) after dly;
      gmii_rx_er  <= to_stdUlogic(frame_data(current_frame).columns(current_col).error) after dly;
      current_col := current_col + 1;
      wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';  -- wait for next clock tick
	    
	end loop;

    -- Send the FCS.
    for j in 0 to 3 loop
      gmii_rxd   <= fcs(((8*j)+7) downto (8*j)) after dly;
      gmii_rx_dv <= '1' after dly;
      gmii_rx_er <= '0' after dly;
      wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';  -- wait for next clock tick
    end loop;

    -- Clear the data lines.
    gmii_rxd   <= (others => '0') after dly;
    gmii_rx_dv <=  '0' after dly;
    gmii_rx_er <=  '0' after dly;

    -- Adding the minimum Interframe gap for a receiver (8 idles)
    for j in 0 to 7 loop
      wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
    end loop;

  end loop;  -- current_frame



  -- Our work here is done
  wait;

  end process p_stimulus;



  ----------------------------------------------------------------------
  -- Monitor process 
  ------------------
  -- This process checks the data coming out of the
  -- transmitter to make sure that it matches that inserted into the
  -- receiver.
  --      -- frame 0 = Contains 2 CO's
  --      -- frame 1 = Contains a CCCO
  --      -- frame 2 = Contains a OOOCCO
  --      -- frame 3 = Contatins a COCOCOC
  --
  -- Repeated for all 3 speeds.
  ----------------------------------------------------------------------
  p_monitor : process
    variable f                  : frame_typ;       -- temporary frame variable
    variable current_col        : natural   := 0;  -- Column counter
    variable current_frame      : natural   := 0;
    variable fcs                : std_logic_vector(31 downto 0);    
  begin  -- process p_monitor

    monitor_finished_1g   <= false;  
    monitor_finished_100m <= false;
    monitor_finished_10m  <= false;     

    -- first, get synced up with the TX clock
    wait until gmii_tx_clk'event and gmii_tx_clk = '1';
    wait until gmii_tx_clk'event and gmii_tx_clk = '1';
    
    ------------------------------------
    -- Compare the frames at 1Gb/s speed
    ------------------------------------

    wait until gmii_tx_clk'event and gmii_tx_clk = '1';

    -- loop over all the frames in the stimulus vector
    loop
      current_col := 0;

      -- If the current frame had an error inserted then it would have been 
      -- dropped by the FIFO in the design example.  Therefore move 
      -- immediately on to the next frame.	   
      while frame_data(current_frame).bad_frame loop
        current_frame := current_frame + 1;
	    if current_frame = frame_data'high + 1 then
          exit;
        end if;
      end loop; 
      
      -- There are only 4 frames in this test.
      if current_frame = frame_data'high + 1 then
        exit;
      end if;
      
      -- Parse over the preamble field
      while gmii_tx_en /= '1' or gmii_txd = "01010101" loop
        wait until gmii_tx_clk'event and gmii_tx_clk = '1';
      end loop;
  
      assert false
        report "EMAC0: Comparing Frame " & integer'image(current_frame) & " at 1Gb/s" & cr
        severity note;

      -- Parse over the Start of Frame Delimiter (SFD)
      if (gmii_txd /= "11010101") then
        assert false
          report "EMAC0: SFD not present" & cr
          severity error;
      end if;
      fcs         := (others => '0'); -- reset the FCS field
      wait until gmii_tx_clk'event and gmii_tx_clk = '1';
  
      -- frame has started, loop over columns of frame
      while ((frame_data(current_frame).columns(current_col).valid)='1') loop         
          
          assert (gmii_tx_en = to_stdulogic(frame_data(current_frame).columns(current_col).valid))
            report "EMAC0: gmii_tx_en incorrect" & cr
            severity error;
         
          if gmii_tx_en = '1' then

          -- The transmitted Destination Address was the Source Address of the injected frame
            if current_col < 6 then 
              fcs := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col+6).data), fcs);
              assert (gmii_txd(7 downto 0) =
                    to_stdlogicvector(frame_data(current_frame).columns(current_col+6).data(7 downto 0)))
                report "EMAC0: gmii_txd incorrect"	& cr
                severity error;

          -- The transmitted Source Address was the Destination Address of the injected frame
            elsif current_col >= 6 and current_col < 12 then
              fcs := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col-6).data), fcs);
              assert (gmii_txd(7 downto 0) =
                    to_stdlogicvector(frame_data(current_frame).columns(current_col-6).data(7 downto 0)))
                report "EMAC0: gmii_txd incorrect"	& cr
                severity error;   
                 
          -- for remainder of frame
            else
              fcs := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
              assert (gmii_txd(7 downto 0) =
                    to_stdlogicvector(frame_data(current_frame).columns(current_col).data(7 downto 0)))
                report "EMAC0: gmii_txd incorrect"	& cr
                severity error;
            end if;
        end if;
        -- wait for next column of data
        current_col        := current_col + 1;
        wait until gmii_tx_clk'event and gmii_tx_clk = '1';
      end loop;  -- while data valid

      -- Check the FCS
      -- Having checked all data columns, txd must contain FCS.
      for j in 0 to 3 loop
        assert (gmii_txd = fcs(((8*j)+7) downto (8*j)))
          report "EMAC0: gmii_txd incorrect during FCS field"	& cr
          severity error;

        wait until gmii_tx_clk'event and gmii_tx_clk = '1';
      end loop;  -- j

      -- move to the next frame
      if current_frame = frame_data'high then
        exit;
      else		  
        current_frame := current_frame + 1;
      end if;

    end loop;

    monitor_finished_1g   <= true;  


    -- Our work here is done
    wait;

  end process p_monitor;


  
end behavioral;
