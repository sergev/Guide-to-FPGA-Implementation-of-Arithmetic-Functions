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

entity fsl_rcopro_determinant is
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

architecture beh1 of fsl_rcopro_determinant is
constant NUM_DATA_INPUTS: integer:= 9;
constant NUM_DATA_OUTPUTS: integer:= 1;
constant NUM_CLK_CALC: integer:=7;

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
	signal op0a,op0b: signed(63 downto 0);
	signal reg_op0a,reg_op0b,op1: signed(31 downto 0);
	signal res1: std_logic_vector(31 downto 0);
	signal mux: std_logic;
	begin
		resdata<=reg_res(0);
		
		with mux select
			op0a<=	signed(reg_data(4))*signed(reg_data(8)) when '0',
					signed(reg_data(0))*reg_op0a when others;
		with mux select
			op0b<=	signed(reg_data(5))*signed(reg_data(7)) when '0',
					signed(reg_data(0))*reg_op0b when others;
		op1<=signed(reg_res(0))+(reg_op0a-reg_op0b);
		res1<=std_logic_vector(op1);

		p_control: process
		variable cnt_step: integer range 0 to NUM_CLK_CALC;
		begin
			wait until rising_edge(FSL_Clk);
			if FSL_Rst='1' then
				ready<='1';
				valid<='0';
			elsif ready='1' then
				if wr_data='1' then
					reg_data(conv_integer(idx_data))<=data;
				end if;
				if start='1' then
					ready<='0';
					valid<='0';
					mux<='0';
					cnt_step:=0;
				end if;
			else
				reg_op0a<=op0a(31 downto 0); 
				reg_op0b<=op0b(31 downto 0);

				if mux='0' then
					if cnt_step=0 then
						reg_res(0)<=(others=>'0');
					else
						reg_res(0)<=res1;
					end if;
				else
					reg_data(0 to 2)<=reg_data(1 to 2)&reg_data(0);
					reg_data(3 to 5)<=reg_data(4 to 5)&reg_data(3);
					reg_data(6 to 8)<=reg_data(7 to 8)&reg_data(6);
				end if;
				
				mux<=not mux;

				cnt_step:=cnt_step+1;
				if cnt_step=NUM_CLK_CALC then
					ready<='1';
					valid<='1';
				end if;
			end if;
		end process;
	
	end block;

end architecture;	
			
