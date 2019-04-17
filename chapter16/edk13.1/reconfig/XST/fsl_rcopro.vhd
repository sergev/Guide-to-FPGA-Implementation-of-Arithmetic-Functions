library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity fsl_rcopro is
	generic
	(
		C_CONFIG_IDX: integer:=0	--fsl_rcopro_dummy.ngc
		--C_CONFIG_IDX: integer:=1	--fsl_rcopro_adder.ngc
		--C_CONFIG_IDX: integer:=2	--fsl_rcopro_multiplier.ngc
		--C_CONFIG_IDX: integer:=3	--fsl_rcopro_scalar_multiplier.ngc
		--C_CONFIG_IDX: integer:=4	--fsl_rcopro_determinant.ngc
	);
	port 
	(
		FSL_Clk			: in	std_logic;
		FSL_Rst			: in	std_logic;
		FSL_S_Clk		: in	std_logic;
		FSL_S_Read		: out	std_logic;
		FSL_S_Data		: in	std_logic_vector(0 to 31);
		FSL_S_Control	: in	std_logic;
		FSL_S_Exists	: in	std_logic;
		FSL_M_Clk		: in	std_logic;
		FSL_M_Write		: out	std_logic;
		FSL_M_Data		: out	std_logic_vector(0 to 31);
		FSL_M_Control	: out	std_logic;
		FSL_M_Full		: in	std_logic
	);
end entity;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

architecture beh of fsl_rcopro is

begin
	g0: if C_CONFIG_IDX=0 generate
		inst: entity work.fsl_rcopro_dummy 
			port map(FSL_Clk,FSL_Rst,FSL_S_Clk,FSL_S_Read,FSL_S_Data,FSL_S_Control,FSL_S_Exists,FSL_M_Clk,FSL_M_Write,FSL_M_Data,FSL_M_Control,FSL_M_Full);
	end generate;
	
	g1: if C_CONFIG_IDX=1 generate
		inst: entity work.fsl_rcopro_adder 
			port map(FSL_Clk,FSL_Rst,FSL_S_Clk,FSL_S_Read,FSL_S_Data,FSL_S_Control,FSL_S_Exists,FSL_M_Clk,FSL_M_Write,FSL_M_Data,FSL_M_Control,FSL_M_Full);
	end generate;
	
	g2: if C_CONFIG_IDX=2 generate
		inst: entity work.fsl_rcopro_multiplier 
			port map(FSL_Clk,FSL_Rst,FSL_S_Clk,FSL_S_Read,FSL_S_Data,FSL_S_Control,FSL_S_Exists,FSL_M_Clk,FSL_M_Write,FSL_M_Data,FSL_M_Control,FSL_M_Full);
	end generate;
	
	g3: if C_CONFIG_IDX=3 generate
		inst: entity work.fsl_rcopro_scalar_multiplier 
			port map(FSL_Clk,FSL_Rst,FSL_S_Clk,FSL_S_Read,FSL_S_Data,FSL_S_Control,FSL_S_Exists,FSL_M_Clk,FSL_M_Write,FSL_M_Data,FSL_M_Control,FSL_M_Full);
	end generate;

	g4: if C_CONFIG_IDX=4 generate
		inst: entity work.fsl_rcopro_determinant 
			port map(FSL_Clk,FSL_Rst,FSL_S_Clk,FSL_S_Read,FSL_S_Data,FSL_S_Control,FSL_S_Exists,FSL_M_Clk,FSL_M_Write,FSL_M_Data,FSL_M_Control,FSL_M_Full);
	end generate;
end architecture;	
			

