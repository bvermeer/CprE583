------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- coproc.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the coprocessor wrapper code and 
-- register file instantiation for the LEON3 SPARCv8 coprocessor 
-- interface. 
--
-- NOTES:
-- 11/1/12 by JAZ::Design created.
-- 8/1/13  by TJB::Finished base for add and future operations.
------------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library gaisler;
use gaisler.leon3.all;
library iastate;
use iastate.coproc_config.all;


entity coproc_core is
  port (rst : in  std_ulogic;      
        clk : in  std_ulogic;
        cpi : in  coproc_core_in_type;
        cpo : out coproc_core_out_type);
end;

architecture rtl of coproc_core is
  -- Execution starts when cpi.start='1'; the data is assumed to be ready at this time.
  -- cpo.busy must be set to '1' while executing and set to '0' when cpo.res (result) is ready
  -- This state machine is probably the most straightforward way to implement functionality
  
  signal control_state : unit_status_type; -- add more states to this type in coproc_config if needed
  
  
begin
  
  execution: process(clk, rst, cpi)
  
  variable op1, op2 : std_logic_vector(63 downto 0);
  variable opc : std_logic_vector(8 downto 0);
   
  variable pixel1, pixel2, pixel3, pixel4 : pixel_type;
  variable up_shift, mid_shift, low_shift : pixel_shift_type;

  variable temp1, temp2 : signed(19 downto 0);

  variable y1, y2, y3, y4 : std_logic_vector ( 15 downto 0) ;

  -- Note the difference between using signals and variables. Variables take their assigned value
  -- immediately but can only be used inside a single process.

  begin
    if rst = '0' then -- reset low
      cpo.cc <= "00"; -- unused, condition code
      cpo.exc <= "000000"; -- unused, exception code
      
      cpo.res <= (others => '0'); -- result
      control_state <= free; -- execution state

      --reset the upper shift register
      up_shift.S4 := (others => '0');
      up_shift.S3 := (others => '0');
      up_shift.S2 := (others => '0');
      up_shift.S1 := (others => '0');

      --reset the middle shift register
      mid_shift.S4 := (others => '0');
      mid_shift.S3 := (others => '0');
      mid_shift.S2 := (others => '0');
      mid_shift.S1 := (others => '0');

      --reset the lower shift register
      low_shift.S4 := (others => '0');
      low_shift.S3 := (others => '0');
      low_shift.S2 := (others => '0');
      low_shift.S1 := (others => '0');

      temp1 := (others => '0');
      temp2 := (others => '0');
      
    elsif rising_edge(clk) then
      if control_state = free then -- wait to receive a command
        if cpi.start = '1' then -- perform setup
          op1 := cpi.op1; -- get the inputs, they may become invalid
          op2 := cpi.op2;
          opc := cpi.opcode;
        
          case opc is
            when CP_SIMPLE_ADD =>
              -- could process it now, but let's say the operation waits a cycle before starting
              control_state <= started;
              
            when CP_COLOR_2_BW =>
              -- perform grayscale conversion
              -- First, extract the individual pixels
              pixel1.R := unsigned( "00000000000" & op1(47 downto 43) );
              pixel1.G := unsigned( "0000000000"  & op1(42 downto 37) );
              pixel1.B := unsigned( "00000000000" & op1(36 downto 32) );
              
              pixel2.R := unsigned( "00000000000" & op1(63 downto 59) );
              pixel2.G := unsigned( "0000000000"  & op1(58 downto 53) );
              pixel2.B := unsigned( "00000000000" & op1(52 downto 48) );

              pixel3.R := unsigned( "00000000000" & op2(47 downto 43) );
              pixel3.G := unsigned( "0000000000"  & op2(42 downto 37) );
              pixel3.B := unsigned( "00000000000" & op2(36 downto 32) );
              
              pixel4.R := unsigned( "00000000000" & op2(63 downto 59) );
              pixel4.G := unsigned( "0000000000"  & op2(58 downto 53) );
              pixel4.B := unsigned( "00000000000" & op2(52 downto 48) );


              -- Now, do the fixed point math
              y1 := std_logic_vector( (158*pixel1.R) + (152*pixel1.G) + (60*pixel1.B) ); 
              y2 := std_logic_vector( (158*pixel2.R) + (152*pixel2.G) + (60*pixel2.B) ); 
              y3 := std_logic_vector( (158*pixel3.R) + (152*pixel3.G) + (60*pixel3.B) ); 
              y4 := std_logic_vector( (158*pixel4.R) + (152*pixel4.G) + (60*pixel4.B) ); 
               
              -- Finally, save the result in the correct format
              cpo.res <= y2(13 downto 9) & y2(13 downto 8) & y2(13 downto 9) & y1(13 downto 9) & y1(13 downto 8) & y1(13 downto 9) & y4(13 downto 9) & y4(13 downto 8) & y4(13 downto 9) & y3(13 downto 9) & y3(13 downto 8) & y3(13 downto 9);
              
              control_state <= ready;
            
            
            when CP_EDGE_DETECT =>
              -- shift the old data over and load in new data
		up_shift.S4 := up_shift.S2;
		up_shift.S3 := up_shift.S1;
		up_shift.S2 := signed( "0000" & op1(63 downto 48) );
		up_shift.S1 := signed( "0000" & op1(47 downto 32) );

		mid_shift.S4 := mid_shift.S2;
		mid_shift.S3 := mid_shift.S1;
		mid_shift.S2 := signed( "0000" & op1(31 downto 16) );
		mid_shift.S1 := signed( "0000" & op1(15 downto 0) );

		low_shift.S4 := low_shift.S2;
		low_shift.S3 := low_shift.S1;
		low_shift.S2 := signed( "0000" & op2(63 downto 48) );
		low_shift.S1 := signed( "0000" & op2(47 downto 32) );

		control_state <= started;

	    when CP_PRELOAD =>
		up_shift.S2 := signed( "0000" & op1(63 downto 48) );
		up_shift.S1 := signed( "0000" & op1(47 downto 32) );
		mid_shift.S2 := signed( "0000" & op1(31 downto 16) );
		mid_shift.S1 := signed( "0000" & op1(15 downto 0) );
		low_shift.S2 := signed( "0000" & op2(63 downto 48) );
		low_shift.S1 := signed( "0000" & op2(47 downto 32) );

		control_state <= ready;
              
            when others => -- invalid opcode; add more CP_OP constants in coproc_config as needed
          end case;
        end if;
      
      elsif control_state = started then -- begin secondary execution, only necessary if it takes multiple cycles
        case opc is
          when CP_SIMPLE_ADD =>
            cpo.res <= std_logic_vector(signed(op1) + signed(op2));
            control_state <= ready;

	  when CP_EDGE_DETECT =>
	    temp1 := (8 * mid_shift.S3) - up_shift.S4 - up_shift.S3 - up_shift.S2 - mid_shift.S4 - mid_shift.S2 - low_shift.S4 - low_shift.S3 -
 			low_shift.S2;
	    temp2 := (8 * mid_shift.S2) - up_shift.S3 - up_shift.S2 - up_shift.S1 - mid_shift.S3 - mid_shift.S1 - low_shift.S3 - low_shift.S2 -
			low_shift.S1;

	    if(temp1 > 65535) then
		cpo.res(63 downto 48) <= X"FFFF";
	    elsif(temp1 < 0) then
		cpo.res(63 downto 48) <= X"0000";
	    else
		cpo.res(63 downto 48) <= std_logic_vector(temp1(15 downto 0));
	    end if;

	    if(temp2 > 65535) then
		cpo.res(47 downto 32) <= X"FFFF";
	    elsif(temp2 < 0) then
		cpo.res(47 downto 32) <= X"0000";
	    else
		cpo.res(47 downto 32) <= std_logic_vector(temp2(15 downto 0));
	    end if;

	    cpo.res(31 downto 0) <= X"00000000";
            
	    control_state <= ready;
          
          when others => -- invalid opcode
        end case;
        
      elsif control_state = ready then -- begin tertiary execution
        control_state <= free; -- must return to free state so coproc controller stops waiting for coproc core
        
      end if;
    end if;
  end process;
  
  cpo.busy <= '1' when control_state /= free -- busy unless waiting for a command
    else '0';
  
end;
