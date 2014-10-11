------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- coproc_config.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the various types and configuration
-- constants for the LEON3 coprocessor core. 
--
-- NOTES:
-- 11/1/12 by JAZ::Design created.
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library gaisler;
use gaisler.leon3.all;
library grlib;
use grlib.sparc.all;

package coproc_config is

  type coproc_core_in_type is record  
    op1    : std_logic_vector(63 downto 0); -- operand 1
    op2    : std_logic_vector(63 downto 0); -- operand 2
    opcode : std_logic_vector(8 downto 0);  -- operation to perform
    start  : std_logic; -- when start='1', ops are ready, can begin execution immediately
    load   : std_logic; -- unused
    flush  : std_logic; -- unused
  end record;

  type coproc_core_out_type is record  
    res  : std_logic_vector (63 downto 0); -- result
    cc   : std_logic_vector (1 downto 0);  -- unused, condition code
    exc  : std_logic_vector (5 downto 0);  -- unused, exception code
    busy : std_logic; --set to 1 immediately after receiving start='1', set to 0 when result is ready
  end record;

  component coproc_core
  port(clk : in  std_logic;        
       rst : in  std_logic; 
       cpi : in  coproc_core_in_type;
       cpo : out coproc_core_out_type);
  end component;

  -- opcodes; they do not need to be 1-hot encode as shown here
  constant CP_ANOTHER_OP : std_logic_vector(8 downto 0) := "000000001";
  constant CP_SIMPLE_ADD : std_logic_vector(8 downto 0) := "000000010";
  constant CP_COLOR_2_BW : std_logic_vector(8 downto 0) := "000000100";
 
  -- current control state
  type unit_status_type is (free, started, ready);
  type store_status_type is (free, wait_a, wait_e, first_half, second_half);
  type load_status_type is (free, first_half, second_half);

end coproc_config;