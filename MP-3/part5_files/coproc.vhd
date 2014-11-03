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
-- 8/1/13  by TJB::Finished base for STDC, LDDC, STC, LDC, and CPOP1.
------------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library gaisler;
use gaisler.leon3.all;
library grlib;
use grlib.sparc.all;
library techmap;
use techmap.gencomp.all;
use techmap.netcomp.all;
library iastate;
use iastate.coproc_config.all;


entity coproc is
  generic (memtech : integer range 0 to NTECH := 0);
  port (rst   : in  std_ulogic;
        clk   : in  std_ulogic;
        holdn : in  std_ulogic;
        cpi   : in  fpc_in_type;
        cpo   : out fpc_out_type);
end;

architecture rtl of coproc is

  -- reg file
  signal rfi1, rfi2 : fp_rf_in_type;
  signal rfo1, rfo2 : fp_rf_out_type;
  
  -- execution unit
  signal eui : coproc_core_in_type;
  signal euo : coproc_core_out_type;
  signal eu_start : std_logic;
  
  -- controller states
  signal control_state : unit_status_type;
  signal load_state : load_status_type;
  signal store_state : store_status_type;
  signal dependency, ldlock : std_logic;
  
  -- signal aliases
  signal op_s : std_logic_vector(1 downto 0);
  signal op3_s : std_logic_vector(5 downto 0);
  signal rd_s, rs1_s, rs2_s, st_rd : std_logic_vector(4 downto 0);
  signal data_second_half : std_logic_vector(31 downto 0);

begin

  execution: process(clk, rst, cpi, holdn)
  
  variable ld_op : std_logic_vector(1 downto 0);
  variable ld_op3, st_op3 : std_logic_vector(5 downto 0);
  variable ld_rd, cpop_rd, cpop_rs1, cpop_rs2 : std_logic_vector(4 downto 0);
  variable data : std_logic_vector(31 downto 0);
  
  begin
    if (rst = '0') then -- reset low
      -- execution unit control
      eui.start <= '0';
      eui.load <= '0';
      eui.flush <= '0';
      eu_start <= '0';
      
      -- controller states
      control_state <= free;
      store_state <= free;
      load_state <= free;
      
      -- register file inputs
      rfi1.rd1addr <= "0000";
      rfi1.rd2addr <= "0000";
      rfi1.wraddr <= "0000";
      rfi1.wrdata <= x"00000000";
      rfi1.wren <= '0';
      rfi1.ren1 <= '1';
      rfi1.ren2 <= '1';
      
      rfi2.rd1addr <= "0000";
      rfi2.rd2addr <= "0000";
      rfi2.wraddr <= "0000";
      rfi2.wrdata <= x"00000000";
      rfi2.wren <= '0';
      rfi2.ren1 <= '1';
      rfi2.ren2 <= '1';
      
      st_rd <= "00000";
      
      -- coprocessor controller outputs
      data_second_half <= x"00000000";
      cpo.holdn <= '1'; -- doesn't matter, but for correctness
      cpo.dbg.data <= (others => '0'); -- doesn't matter
      
    elsif (rising_edge(clk)) then
      -- CPOP OPERATIONS
      case control_state is
        when free => -- wait for new instruction
          rfi1.wren <= '0';
          rfi2.wren <= '0';
          eui.opcode <= cpi.d.inst(13 downto 5);
          
          if (op_s = FMT3 and cpi.d.pv = '1') then -- if coprocessor format and program counter is valid
            case op3_s is
              when CPOP1 =>
                eu_start <= '1';
                cpop_rd := rd_s;
                cpop_rs1 := rs1_s;
                cpop_rs2 := rs2_s;
                
                case cpi.d.inst(13 downto 5) is -- set the register addresses depending on the opcode
                  when CP_SIMPLE_ADD | CP_COLOR_2_BW =>
                    -- assumes the address starts on an even register
                    rfi1.rd1addr <= rs1_s(4 downto 1);
                    rfi2.rd1addr <= rs1_s(4 downto 1);
                    rfi1.rd2addr <= rs2_s(4 downto 1);
                    rfi2.rd2addr <= rs2_s(4 downto 1);
                    
                  when CP_ANOTHER_OP =>
                    -- different setup
                    
                  when others => -- invalid opcode
                end case;
                
                if (dependency = '0') then -- only begin preparation if there are no data dependencies for LD
                  control_state <= started;
                end if;
                
              when others => -- invalid instructions
            end case;
          end if;
          
        when started => -- start execution unit
          if (eu_start = '0') then -- waited a cycle
            if (dependency = '0') then -- only begin execution if there are no data dependencies
              eu_start <= '1';
            end if;
          else
            control_state <= ready;
            eui.start <= '1';
          end if;
          
        when ready => -- get execution unit output and write
          eui.start <= '0';
          eu_start <= '0';
              
          case eui.opcode is
            when CP_SIMPLE_ADD | CP_COLOR_2_BW =>
              if (euo.busy = '0' and eu_start = '0') then -- if done executing
                -- write the result
                rfi1.wraddr <= cpop_rd(4 downto 1);
                rfi2.wraddr <= cpop_rd(4 downto 1);
                rfi1.wrdata <= euo.res(63 downto 32);
                rfi2.wrdata <= euo.res(31 downto 0);
                rfi1.wren <= '1';
                rfi2.wren <= '1';
                
                control_state <= free;
              end if;
            
            when CP_ANOTHER_OP =>
              if (euo.busy = '0' and eu_start = '0') then -- if done executing
                -- possibly write the result in a different way; might take multiple cycles
                control_state <= free;
              end if;
              
            when others => -- invalid opcode
          end case;
        when others => -- invalid state
      end case;
      
      
      -- ST OPERATIONS - DO NOT MODIFY
      case store_state is
        when free =>
          if (op_s = LDST and cpi.d.pv = '1') then -- if storing and program counter is valid
            if (op3_s = STC or op3_s = STDC) then
              st_rd <= rd_s;
              st_op3 := op3_s;
              
              store_state <= wait_a;
            end if;
          end if;
          
        when wait_a =>
          if (ldlock = '0') then -- prepare regs if not stalled
            case op3_s is 
              when STC =>
                if rd_s(0) = '0' then -- check if address is odd or even
                  rfi1.rd1addr <= st_rd(4 downto 1);
                else
                  rfi2.rd1addr <= st_rd(4 downto 1);
                end if;
              
              when STDC =>
                rfi1.rd1addr <= st_rd(4 downto 1);
                rfi2.rd1addr <= st_rd(4 downto 1);
                
              when others => -- invalid instructions
            end case;
          
            if (holdn = '1' and cpi.a.pv = '1') then -- progress if not stalled
              store_state <= wait_e;
            end if;
          end if;
        
        when wait_e =>
          if (holdn = '1' and ldlock = '0' and cpi.e.pv = '1') then -- progress if not stalled
            store_state <= first_half;
          end if;
          
        when first_half =>
          if (st_op3 = STC) then
            if (st_rd(0) = '0') then -- check if address is odd or even
              data_second_half <= rfo1.data1;
            else
              data_second_half <= rfo2.data1;
            end if;
            
          else -- STDC
            data_second_half <= rfo2.data1;
          end if;
          
          if (holdn = '1' and ldlock = '0' and cpi.m.pv = '1') then -- store if not stalled
            store_state <= second_half;
          end if;
          
        when second_half =>
          if (holdn = '1') then -- only check if another store is coming up if not stalled
            if (cpi.e.inst(31 downto 30) = LDST and cpi.e.pv = '1' and -- if store in e stage
            (cpi.e.inst(24 downto 19) = STC or cpi.e.inst(24 downto 19) = STDC)) then
              if (cpi.e.inst(24 downto 19) = STC) then
                st_rd <= cpi.e.inst(29 downto 25);
                
                if (cpi.e.inst(25) = '0') then -- check if address is odd or even
                  rfi1.rd1addr <= cpi.e.inst(29 downto 26); -- rd
                else
                  rfi2.rd1addr <= cpi.e.inst(29 downto 26);
                end if;
                
              else -- STDC
                rfi1.rd1addr <= cpi.e.inst(29 downto 26);
                rfi2.rd1addr <= cpi.e.inst(29 downto 26);
              end if;
              
              st_op3 := cpi.e.inst(24 downto 19);
              store_state <= first_half;
              
            elsif (cpi.a.inst(31 downto 30) = LDST and cpi.a.pv = '1' and -- if store in a stage
            (cpi.a.inst(24 downto 19) = STC or cpi.a.inst(24 downto 19) = STDC)) then
              if (cpi.a.inst(24 downto 19) = STC) then
                st_rd <= cpi.a.inst(29 downto 25);
                
                if (cpi.a.inst(25) = '0') then -- check if address is odd or even
                  rfi1.rd1addr <= cpi.a.inst(29 downto 26); -- rd
                else
                  rfi2.rd1addr <= cpi.a.inst(29 downto 26);
                end if;
                
              else -- STDC
                rfi1.rd1addr <= cpi.a.inst(29 downto 26);
                rfi2.rd1addr <= cpi.a.inst(29 downto 26);
              end if;
              
              st_op3 := cpi.a.inst(24 downto 19);
              store_state <= wait_e;
              
            elsif (cpi.d.inst(31 downto 30) = LDST and cpi.d.pv = '1' and -- if store in d stage
            (cpi.d.inst(24 downto 19) = STC or cpi.d.inst(24 downto 19) = STDC)) then
              if (cpi.d.inst(24 downto 19) = STC) then
                st_rd <= cpi.d.inst(29 downto 25);
                
                if (cpi.d.inst(25) = '0') then -- check if address is odd or even
                  rfi1.rd1addr <= cpi.d.inst(29 downto 26); -- rd
                else
                  rfi2.rd1addr <= cpi.d.inst(29 downto 26);
                end if;
                
              else -- STDC
                rfi1.rd1addr <= cpi.d.inst(29 downto 26);
                rfi2.rd1addr <= cpi.d.inst(29 downto 26);
              end if;
              
              st_op3 := cpi.d.inst(24 downto 19);
              store_state <= wait_a;
              
            else
              store_state <= free;
            end if;
          end if;
          
        when others => -- invalid state
      end case;
      
      
      -- LD OPERATIONS - DO NOT MODIFY
      case load_state is
        when free =>
          ld_op := cpi.x.inst(31 downto 30);
          ld_rd := cpi.x.inst(29 downto 25);
          ld_op3 := cpi.x.inst(24 downto 19);
          
          if (ld_op = LDST and cpi.x.pv = '1') then -- if loading and program counter is valid
            case ld_op3 is
              when LDC =>
                if (ld_rd(0) = '0') then -- check if address is odd or even
                  rfi1.wraddr <= ld_rd(4 downto 1);
                  rfi1.wrdata <= cpi.lddata;
                else
                  rfi2.wraddr <= ld_rd(4 downto 1);
                  rfi2.wrdata <= cpi.lddata;
                end if;
                
                if (holdn = '1') then -- data is ready to write to registers
                  if (ld_rd(0) = '0') then -- check if address is odd or even
                    rfi1.wren <= '1';
                    rfi2.wren <= '0';
                  else
                    rfi1.wren <= '0';
                    rfi2.wren <= '1';
                  end if;
                  
                  load_state <= first_half;
                else -- not ready; don't write
                  rfi1.wren <= '0';
                  rfi2.wren <= '0';
                end if;
                
              when LDDC =>
                rfi1.wraddr <= ld_rd(4 downto 1);
                rfi2.wraddr <= ld_rd(4 downto 1);
                
                rfi2.wren <= '0';
                rfi1.wrdata <= cpi.lddata;
              
                if (holdn = '1') then -- data is ready
                  load_state <= first_half;
                  rfi1.wren <= '1';
                else -- not ready; don't write
                  rfi1.wren <= '0';
                end if;
              
              when others => -- invalid instructions
            end case;
          end if;
          
        when first_half =>
          case ld_op3 is
            when LDC =>
              rfi1.wren <= '0';
              rfi1.wren <= '0';
              load_state <= free; -- done loading
            
            when LDDC =>
              rfi1.wren <= '0';
              rfi2.wrdata <= cpi.lddata;
              
              if (holdn = '1') then -- second data half is ready
                load_state <= second_half;
                rfi2.wren <= '1';
              end if;
              
            when others => -- invalid instructions
          end case;
          
        when second_half =>
          case ld_op3 is
            when LDDC =>
              rfi2.wren <= '0'; -- done writing
              load_state <= free;
              
            when others => -- invalid instructions
          end case;
        when others => -- invalid state
      end case;
      
    end if;
  end process;
  
  
  -- decode stage signal aliases
  op_s <= cpi.d.inst(31 downto 30);
  rd_s <= cpi.d.inst(29 downto 25);
  op3_s <= cpi.d.inst(24 downto 19);
  rs1_s <= cpi.d.inst(18 downto 14);
  rs2_s <= cpi.d.inst(4 downto 0);
  
  dependency <= '1' when -- DO NOT MODIFY
    ((op_s = FMT3 and op3_s = CPOP1) or (op_s = LDST and (op3_s = STC or op3_s = STDC))) and -- if performing cpop or st
    (
      (cpi.a.inst(31 downto 30) = LDST and (cpi.a.inst(24 downto 19) = LDC or cpi.a.inst(24 downto 19) = LDDC)) or -- a stage load
      (cpi.e.inst(31 downto 30) = LDST and (cpi.e.inst(24 downto 19) = LDC or cpi.e.inst(24 downto 19) = LDDC)) or -- e stage load
      (cpi.m.inst(31 downto 30) = LDST and (cpi.m.inst(24 downto 19) = LDC or cpi.m.inst(24 downto 19) = LDDC)) or -- m stage load
      (cpi.x.inst(31 downto 30) = LDST and (cpi.x.inst(24 downto 19) = LDC or cpi.x.inst(24 downto 19) = LDDC))    -- x stage load
    ) -- specific address checks are not used because some instructions may read from more registers than given in operands
    else '0';
    
  -- stall the IU pipeline if load dependency or executing cpop - DO NOT MODIFY
  ldlock <= '1' when (dependency = '1' or control_state /= free) else
            '0';
  cpo.ldlock <= ldlock;
  
  -- coproc controller output - DO NOT MODIFY
  cpo.data <= rfo1.data1 when (store_state = first_half and st_rd(0) = '0') else
              rfo2.data1 when (store_state = first_half and st_rd(0) = '1') else
              data_second_half;
  cpo.exc <= '0' when (euo.exc = "000000") else
             '1';
  cpo.cc <= euo.cc;
  cpo.ccv <= '0';
              
  -- COPROC INPUT CONTROL
  eui.op1 <= rfo1.data1 & rfo2.data1 when (eui.opcode = CP_SIMPLE_ADD) else
             rfo1.data1 & rfo2.data1 when (eui.opcode = CP_COLOR_2_BW) else
             x"ffffffffffffffff" when (eui.opcode = CP_ANOTHER_OP) else -- add more when (eui.opcode) statements as needed
             (others => '0'); -- inputs could be different (e.g. change concatenation order), but probably don't need to be
             
  eui.op2 <= rfo1.data2 & rfo2.data2 when (eui.opcode = CP_SIMPLE_ADD) else
             rfo1.data2 & rfo2.data2 when (eui.opcode = CP_COLOR_2_BW) else
             x"ffffffffffffffff" when (eui.opcode = CP_ANOTHER_OP) else -- add more when (eui.opcode) statements as needed
             (others => '0'); -- inputs could be different (e.g. change concatenation order), but probably don't need to be


  -- Register file instantiations
  rf1 : regfile_3p generic map (memtech, 4, 32, 1, 16)
    port map (clk, rfi1.wraddr, rfi1.wrdata, rfi1.wren, clk, rfi1.rd1addr, rfi1.ren1, rfo1.data1,
          rfi1.rd2addr, rfi1.ren2, rfo1.data2);

  rf2 : regfile_3p generic map (memtech, 4, 32, 1, 16)
    port map (clk, rfi2.wraddr, rfi2.wrdata, rfi2.wren, clk, rfi2.rd1addr, rfi2.ren1, rfo2.data1,
          rfi2.rd2addr, rfi2.ren2, rfo2.data2);

  
  -- Implementation of specific coprocessor functionality
  cproc0 : coproc_core port map
  (
    clk   => clk, -- clk from main processor
    rst   => rst, -- reset when main processor resets (active low)
    cpi   => eui, -- execution unit in
    cpo   => euo  -- execution unit out
  );
  
end;
