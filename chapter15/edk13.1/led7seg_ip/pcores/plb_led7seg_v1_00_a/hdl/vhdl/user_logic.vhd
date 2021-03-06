------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
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
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:               (by Create and Import Peripheral Wizard)
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

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;	--Added due to the or_reduce() function

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here
use ieee.std_logic_misc.all;	--Added due to the or_reduce() function
library plb_led7seg_v1_00_a;	--Open peripheral's library
------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    C_REFRESH_COUNTS: integer := 1000;
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    Segments: out std_logic_vector(6 downto 0);
    Anodes: out std_logic_vector(3 downto 0);
    Switch_Zeros: in std_logic;
    Switch_Off: in std_logic;
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(0 to C_SLV_DWIDTH-1);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute SIGIS : string;
  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic
  signal reg_control: std_logic_vector(1 downto 0);
  signal reg_data: std_logic_vector(15 downto 0);
  signal refresh: std_logic;
  signal sw1,sw2: std_logic_vector(1 downto 0);

  signal ip_data: std_logic_vector(C_SLV_DWIDTH-1 downto 0);	--Data-bus, generated by the IP
  signal bus_data: std_logic_vector(C_SLV_DWIDTH-1 downto 0);	--Data-bus, recieved from the bus 

begin

	bus_data <= Bus2IP_Data;

	IP2Bus_Data  <= ip_data;
	IP2Bus_WrAck <= or_reduce(Bus2IP_WrCE);
	IP2Bus_RdAck <= or_reduce(Bus2IP_RdCE);
	IP2Bus_Error <= '0';
	
	READ_REG: process( Bus2IP_RdCE, reg_data, reg_control ) 
	begin
		ip_data<=(others=>'0');
		case Bus2IP_RdCE(0 to 1) is
			when "10"=> 	ip_data(15 downto 0)<=reg_data;
			when "01"=> 	ip_data( 1 downto 0)<=reg_control;	
			when others=> 	null; 			
		end case;
	end process;
	
	WRITE_REG: process( Bus2IP_Reset, Bus2IP_Clk)
	begin
		if Bus2IP_Reset='1' then
			reg_data<=(others=>'0');
			reg_control<=(others=>'0');
		elsif rising_edge(Bus2IP_Clk) then
			if Bus2IP_WrCE(0)='1' then
				reg_data<=bus_data(15 downto 0);
			end if;
			if Bus2IP_WrCE(1)='1' then
				reg_control<=bus_data(1 downto 0);
			elsif refresh='1' then	
				reg_control<=reg_control xor (sw1 xor sw2);
			end if;
		end if;
	end process;
	
	SWITCHES: process( Bus2IP_Reset, Bus2IP_Clk, Switch_Off, Switch_Zeros )
	begin
		sw2<=Switch_Off & Switch_Zeros;
		if Bus2IP_Reset='1' then
			sw1<=sw2;
		elsif rising_edge(Bus2IP_Clk) and refresh='1' then
			sw1<=sw2;
		end if;
	end process;
	
	COUNTER: process( Bus2IP_Clk, Bus2IP_Reset )
		subtype T_COUNTER is integer range 0 to C_REFRESH_COUNTS-1;
		--subtype T_COUNTER is integer range 0 to 10-1;
		variable counter: T_COUNTER;
		begin
			if Bus2IP_Reset='1' then
				counter:=T_COUNTER'high;
				refresh<='0';
			elsif rising_edge(Bus2IP_Clk) then
				if counter=0 then
					counter:=T_COUNTER'high;
					refresh<='1';
				else
					counter:=counter-1;
					refresh<='0';
				end if;
			end if;
		end process;
		
	core: entity plb_led7seg_v1_00_a.led7seg(BEH1) 
		port map(
			Rst=> Bus2IP_Reset,
			Clk=> Bus2IP_Clk,
			Refresh=> refresh,
			
			Segments=> Segments,
			Anodes=> Anodes,
				
			Data=> reg_data,
			Zeros=> reg_control(0),
			Off=> reg_control(1) );		

end IMP;
