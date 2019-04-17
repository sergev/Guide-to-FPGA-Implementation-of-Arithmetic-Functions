------------------------------------------------------------------------------
-- fsl_mixcolumns - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2010 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          fsl_mixcolumns
-- Version:           1.00.a
-- Description:       Example FSL core (VHDL).
-- Date:             (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- FSL_Clk             : Synchronous clock
-- FSL_Rst           : System reset, should always come from FSL bus
-- FSL_S_Clk       : Slave asynchronous clock
-- FSL_S_Read      : Read signal, requiring next available input to be read
-- FSL_S_Data      : Input data
-- FSL_S_CONTROL   : Control Bit, indicating the input data are control word
-- FSL_S_Exists    : Data Exist Bit, indicating data exist in the input FSL bus
-- FSL_M_Clk       : Master asynchronous clock
-- FSL_M_Write     : Write signal, enabling writing to output FSL bus
-- FSL_M_Data      : Output data
-- FSL_M_Control   : Control Bit, indicating the output data are contol word
-- FSL_M_Full      : Full Bit, indicating output FSL bus is full
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity fsl_mixcolumns is
	port 
	(
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete. 
		FSL_Clk	: in	std_logic;
		FSL_Rst	: in	std_logic;
		FSL_S_Clk	: in	std_logic;
		FSL_S_Read	: out	std_logic;
		FSL_S_Data	: in	std_logic_vector(0 to 31);
		FSL_S_Control	: in	std_logic;
		FSL_S_Exists	: in	std_logic;
		FSL_M_Clk	: in	std_logic;
		FSL_M_Write	: out	std_logic;
		FSL_M_Data	: out	std_logic_vector(0 to 31);
		FSL_M_Control	: out	std_logic;
		FSL_M_Full	: in	std_logic
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	);

attribute SIGIS : string; 
attribute SIGIS of FSL_Clk : signal is "Clk"; 
attribute SIGIS of FSL_S_Clk : signal is "Clk"; 
attribute SIGIS of FSL_M_Clk : signal is "Clk"; 

end fsl_mixcolumns;
------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

architecture beh1 of fsl_mixcolumns is

	subtype T_BYTE is std_logic_vector(7 downto 0);
	subtype T_IDX is integer range 0 to 3;
	type T_STATE is array(0 to 3,0 to 3) of T_BYTE;
	type T_ROW is array(0 to 3) of T_BYTE;
	type T_COL is array(0 to 3) of T_BYTE;

	function F_GET_COL(i: T_STATE; col_idx: T_IDX) return T_COL is
	variable o: T_COL;
	begin
		for row_idx in T_IDX'low to T_IDX'high loop
			o(row_idx):=i(row_idx,col_idx);
		end loop;
		return o;
	end function;

	function F_GET_ROW(i: T_STATE; row_idx: T_IDX) return T_ROW is
	variable o: T_ROW;
	begin
		for col_idx in T_IDX'low to T_IDX'high loop
			o(col_idx):=i(row_idx,col_idx);
		end loop;
		return o;
	end function;

	function F_SET_COL(i: T_STATE; col_idx: T_IDX; col: T_COL) return T_STATE is
	variable o: T_STATE;
	begin
		o:=i;
		for row_idx in T_IDX'low to T_IDX'high loop
			o(row_idx,col_idx):=col(row_idx);
		end loop;
		return o;
	end function;
	
	function F_SET_ROW(i: T_STATE; row_idx: T_IDX; row: T_ROW) return T_STATE is
	variable o: T_STATE;
	begin
		o:=i;
		for col_idx in T_IDX'low to T_IDX'high  loop
			o(row_idx,col_idx):=row(col_idx);
		end loop;
		return o;
	end function;
	
	function F_LSHIFT_COL(i: T_STATE) return T_STATE is
	variable o: T_STATE;
	variable tmp: T_BYTE;
	begin
		for row_idx in T_IDX'low to T_IDX'high loop
			tmp:=i(row_idx,T_IDX'low);
			for col_idx in T_IDX'low to T_IDX'high-1 loop
				o(row_idx,col_idx):=i(row_idx,col_idx+1);
			end loop;
			o(row_idx,T_IDX'high):=tmp;
		end loop;
		return o;
	end function;
	
	function F_X(i: T_BYTE) return T_BYTE is
	constant C_0x1B: T_BYTE:=X"1B";
	variable o: T_BYTE;
	begin
		if i(7)='1' then o:=(i(6 downto 0)&'0') xor C_0x1B; else o:=i(6 downto 0)&'0'; end if;	
		return o;
	end function;

	function F_MIX_COL(i: T_COL) return T_COL is
	variable o: T_COL;
	variable t,sb,x: T_BYTE;

	begin
		t:=i(0) xor i(1) xor i(2) xor i(3);
		for row_idx in T_IDX'low to T_IDX'high loop
			if row_idx=T_IDX'high then sb:=i(0); else sb:=i(row_idx+1); end if;
			x:=i(row_idx) xor sb;
			o(row_idx):=i(row_idx) xor t xor F_X(x);
		end loop;
		return o;
	end function;
	
	function F_MULTIPLY(x: T_BYTE; y: T_BYTE) return T_BYTE is
	variable x1,m: T_BYTE;
	begin
		x1:=x;
		m:=(others=>'0');
		for j in 0 to 3 loop
			if y(j)='1' then m:=m xor x1; end if;
			x1:=F_X(x1);
		end loop;
		return m;
	end function;
	
	function F_INVMIX_COL(i: T_COL) return T_COL is
	variable o: T_COL;
	variable k: integer range 0 to 6;
	type T_M is array(0 to 6) of T_BYTE;
	constant M: T_M:=(X"0B",X"0D",X"09",X"0E",X"0B",X"0D",X"09");
	begin
		for row_idx in T_IDX'low to T_IDX'high loop
			k:=3-row_idx;
			o(row_idx):=F_MULTIPLY(i(0),M(k)) xor F_MULTIPLY(i(1),M(k+1)) xor F_MULTIPLY(i(2),M(k+2)) xor F_MULTIPLY(i(3),M(k+3));
		end loop;
		return o;
	end function;
	
	signal mode,wr_mode: std_logic;
	signal row,resrow: T_ROW;
	signal wr_row,rd_resrow: std_logic;
	signal idx_row,idx_resrow: unsigned(1 downto 0);
	signal start,ready,valid: std_logic;

begin

	--Process to enable the write signal of the State and Mode registers from the data read on the Slave-FSL 
	p_read_sfsl: process(FSL_S_Exists,FSL_Clk,FSL_Rst,FSL_S_Control,FSL_S_Data,wr_row,wr_mode,ready,start)
	variable cnt_mode: integer range 0 to 1;
	variable cnt_row: integer range 0 to 4;
	begin
		if rising_edge(FSL_Clk) then	--Counts the number of write accesses to registers
			if FSL_Rst='1' or start='1' then
				cnt_row:=0;	
				cnt_mode:=0;
			else
				if wr_mode='1' then
					cnt_mode:=cnt_mode+1;
				end if;
				if wr_row='1' then
					cnt_row:=cnt_row+1;
				end if;
			end if;
		end if;

		if FSL_S_Exists='1' and FSL_S_Control='0' and not(cnt_row=4)  then wr_row<=ready;  else wr_row<='0';  end if;  	--enables write to State register
		if FSL_S_Exists='1' and FSL_S_Control='1' and not(cnt_mode=1) then wr_mode<=ready; else wr_mode<='0'; end if;	--enables write to Mode register
		FSL_S_Read<=wr_mode or wr_row;	--FSL read acknowledge
		mode<=FSL_S_Data(FSL_S_DATA'right);												
		row<=(FSL_S_Data(0 to 7), FSL_S_Data(8 to 15), FSL_S_Data(16 to 23), FSL_S_Data(24 to 31));
		idx_row<=conv_unsigned(cnt_row,idx_row'length);	--Row index to write result
		if(cnt_mode=1 and cnt_row+1=4 and wr_row='1') then start<='1'; else start<='0'; end if;	--Starts the computation
	end process;
	
	--Process to write Master-FSL from the State register
	p_write_mfsl: process(FSL_M_Full,FSL_Clk,FSL_Rst,rd_resrow,resrow,valid,start)
	variable cnt_row: integer range 0 to 4;
	begin
		if rising_edge(FSL_Clk) then	--Counts the number of read accesses to registers
			if FSL_Rst='1' or start='1' then
				cnt_row:=0;
			elsif rd_resrow='1' then
				cnt_row:=cnt_row+1;
			end if;
		end if;

		if FSL_M_Full='0' and not(cnt_row=4) then rd_resrow<=valid; else rd_resrow<='0'; end if;	--enables the read to the State register if computation is completed 
		FSL_M_Write<=rd_resrow;	--FSL write request
		FSL_M_Control<='0';
		FSL_M_Data<=resrow(0) & resrow(1) & resrow(2) & resrow(3);
		idx_resrow<=conv_unsigned(cnt_row,idx_resrow'length);	--Row index to read
	end process;
	
	b_mixcols: block
	signal reg_mode: std_logic;
	signal reg_state,state: T_STATE;
	signal col0,ncol0: T_COL;
	begin
		resrow<=F_GET_ROW(reg_state,conv_integer(idx_resrow));
		
		col0<=F_GET_COL(reg_state,0);
		ncol0<=F_MIX_COL(col0) when reg_mode='0' else F_INVMIX_COL(col0);
		state<=F_SET_COL(reg_state,0,ncol0);
	
		--Process to write the State and Mode registers, and to control the columns computation
		p_state: process
		variable cnt_col: integer range 0 to 4;
		variable ncol: T_COL;
		begin
			wait until rising_edge(FSL_Clk);
			if FSL_Rst='1' then
				ready<='1';
				valid<='0';
			elsif ready='1' then
				if wr_mode='1' then
					reg_mode<=mode;
				end if;
				if wr_row='1' then
					reg_state<=F_SET_ROW(reg_state,conv_integer(idx_row),row);
				end if;
				if start='1' then
					ready<='0';
					valid<='0';
					cnt_col:=0;
				end if;
			else
				reg_state<=F_LSHIFT_COL(state);
				cnt_col:=cnt_col+1;
				if cnt_col=4 then
					ready<='1';
					valid<='1';
				end if;
			end if;
		end process;
		
	end block;

end architecture;	
			
