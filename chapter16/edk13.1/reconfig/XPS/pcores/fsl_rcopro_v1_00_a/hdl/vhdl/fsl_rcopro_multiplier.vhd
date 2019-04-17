library ieee;
use ieee.std_logic_1164.all;
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

entity fsl_rcopro_multiplier is
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

end entity;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

architecture beh1 of fsl_rcopro_multiplier is
constant NUM_DATA_INPUTS: integer:= 18;
constant NUM_DATA_OUTPUTS: integer:= 9;
constant NUM_CLK_CALC: integer:=28;

signal wr_data,rd_resdata: std_logic;
signal idx_data,idx_resdata: unsigned(4 downto 0);
signal data,resdata: std_logic_vector(31 downto 0);
signal start,ready,valid: std_logic;

begin

	p_read_sfsl: process(FSL_S_Exists,FSL_Clk,FSL_Rst,FSL_S_Control,FSL_S_Data,wr_data,ready,start)
	variable cnt_data: integer range 0 to NUM_DATA_INPUTS;
	begin
		if rising_edge(FSL_Clk) then
			if FSL_Rst='1' or start='1' then
				cnt_data:=0;
			elsif wr_data='1' then
				cnt_data:=cnt_data+1;
			end if;
		end if;

		if FSL_S_Exists='1' and FSL_S_Control='0' and not(cnt_data=NUM_DATA_INPUTS) then wr_data<=ready;  else wr_data<='0';  end if;
		FSL_S_Read<=wr_data;
		data<=FSL_S_Data;
		idx_data<=conv_unsigned(cnt_data,idx_data'length);
		if (cnt_data+1=NUM_DATA_INPUTS and wr_data='1') then start<='1'; else start<='0'; end if;
	end process;
	
	p_write_mfsl: process(FSL_M_Full,FSL_Clk,FSL_Rst,rd_resdata,resdata,valid,start)
	variable cnt_data: integer range 0 to NUM_DATA_OUTPUTS;
	begin
		if rising_edge(FSL_Clk) then
			if FSL_Rst='1' or start='1' then
				cnt_data:=0;
			elsif rd_resdata='1' then
				cnt_data:=cnt_data+1;
			end if;
		end if;

		if FSL_M_Full='0' and not(cnt_data=NUM_DATA_OUTPUTS) then rd_resdata<=valid; else rd_resdata<='0'; end if;
		FSL_M_Write<=rd_resdata;
		FSL_M_Control<='0';
		FSL_M_Data<=resdata;
		idx_resdata<=conv_unsigned(cnt_data,idx_resdata'length);
	end process;
	
	b_calc: block
	type T_VECTOR_DATA is array(0 to NUM_DATA_INPUTS-1) of std_logic_vector(31 downto 0);
	type T_VECTOR_RESDATA is array(0 to NUM_DATA_OUTPUTS-1) of std_logic_vector(31 downto 0);
	signal reg_data: T_VECTOR_DATA;
	signal reg_res: T_VECTOR_RESDATA; 
	signal op0: signed(63 downto 0);
	signal reg_op0,reg_op1,op1: signed(31 downto 0);
	signal res: std_logic_vector(31 downto 0);
	begin
		resdata<=reg_res(0);
		
		op0<=signed(reg_data(0))*signed(reg_data(9));		--1st stage: multiplication
		op1<=reg_op1+reg_op0;								--2nd stage: addition
		res<=std_logic_vector(op1);

		p_control: process
		variable cnt_step: integer range 0 to NUM_CLK_CALC;
		variable cnt3: integer range 0 to 2;
		variable cnt9: integer range 0 to 8;
		begin
			wait until rising_edge(FSL_Clk);
			if FSL_Rst='1' then
				ready<='1';
				valid<='0';
			elsif ready='1' then
				if wr_data='1' then
					reg_data(conv_integer(idx_data))<=data;
				end if;
				if rd_resdata='1' then
					reg_res<=reg_res(1 to 8)&reg_res(0);
				end if;
				if start='1' then
					ready<='0';
					valid<='0';
					cnt3:=0; cnt9:=0;
					cnt_step:=0;
				end if;
			else
				reg_op0<=op0(31 downto 0); 	--register data between 1st and 2nd stages
				reg_op1<=op1; 
	
				if cnt3=0 then
					reg_op1<=(others=>'0');
					reg_res<=reg_res(1 to 8)&res;
				end if;

				reg_data(0 to 2)<=reg_data(1 to 2)&reg_data(0);										--left-shift the 1st row of the first matrix
				reg_data(9)<=reg_data(12); reg_data(12)<=reg_data(15); reg_data(15)<=reg_data(9); 	--up-shift the 1st column of the second matrix
	
				if cnt3=2 then
					reg_data( 9 to 11)<=reg_data(10 to 11)&reg_data(12);	--left-shift columns and up-shift the last column 
					reg_data(12 to 14)<=reg_data(13 to 14)&reg_data(15);
					reg_data(15 to 17)<=reg_data(16 to 17)&reg_data( 9);
				end if;
			
				if cnt9=8 then
					reg_data(0 to 8)<=reg_data(3 to 8)&reg_data(1 to 2)&reg_data(0);	--up-shift rows and left-shift the last row of the first matrix
				end if;
	
				if cnt3=2 then
					cnt3:=0;
				else
					cnt3:=cnt3+1;
				end if;

				if cnt9=8 then
					cnt9:=0;
				else 
					cnt9:=cnt9+1;
				end if;
				
				cnt_step:=cnt_step+1;
				if cnt_step=NUM_CLK_CALC then
					ready<='1';
					valid<='1';
				end if;
			end if;
		end process;
	
	end block;

end architecture;	
			
