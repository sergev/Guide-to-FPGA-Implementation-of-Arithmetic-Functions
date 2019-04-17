----------------------------------------------------------------------
-- BCD mult 1x2 BCD
-- defines the memory content as a XILINX DPRAM
-- Register inputs
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity bcd_mul_bram is
    Port ( a0  : in  STD_LOGIC_VECTOR (3 downto 0);
           a1  : in  STD_LOGIC_VECTOR (3 downto 0);
           b   : in  STD_LOGIC_VECTOR (3 downto 0);
           CLK : in	STD_LOGIC;
           c0, c1  : out	STD_LOGIC_VECTOR (3 downto 0);
           d0, d1  : out	STD_LOGIC_VECTOR (3 downto 0));
end bcd_mul_bram;

architecture ROM_based of bcd_mul_bram is

type mult_tables_T is array(0 to 153) of std_logic_vector(7 downto 0);	-- Tablas BCD del 0 al 9

signal mult_tables : mult_tables_T := 
	-- Tabla del 0
	("00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
	 "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
	-- Tabla del 1
	 "00000000", "00000001", "00000010", "00000011", "00000100", "00000101", "00000110", "00000111", 
	 "00001000", "00001001", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
	-- Tabla del 2
	 "00000000", "00000010", "00000100", "00000110", "00001000", "00010000", "00010010", "00010100", 
	 "00010110", "00011000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
	-- Tabla del 3
	 "00000000", "00000011", "00000110", "00001001", "00010010", "00010101", "00011000", "00100001", 
	 "00100100", "00100111", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
	-- Tabla del 4
	 "00000000", "00000100", "00001000", "00010010", "00010110", "00100000", "00100100", "00101000", 
	 "00110010", "00110110", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 	
	-- Tabla del 5
	 "00000000", "00000101", "00010000", "00010101", "00100000", "00100101", "00110000", "00110101", 
   "01000000", "01000101", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 	
	-- Tabla del 6
	 "00000000", "00000110", "00010010", "00011000", "00100100", "00110000", "00110110", "01000010", 
	 "01001000", "01010100", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
	-- Tabla del 7
	 "00000000", "00000111", "00010100", "00100001", "00101000", "00110101", "01000010", "01001001", 
	 "01010110", "01100011", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
  -- Tabla del 8
	 "00000000", "00001000", "00010110", "00100100", "00110010", "01000000", "01001000", "01010110", 
	 "01100100", "01110010", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", 
	-- Tabla del 9
	 "00000000", "00001001", "00011000", "00100111", "00110110", "01000101", "01010100", "01100011", 
	 "01110010", "10000001"  );

  signal A0_int, A1_int, B_int  : STD_LOGIC_VECTOR (7 downto 0);
  signal X0, X1: STD_LOGIC_VECTOR (7 downto 0);

  attribute rom_style: string;
  attribute rom_style of mult_tables: signal is "block";

begin

  --registering inputs
  process (clk)
  begin
    if (rising_edge(CLK)) then
      A0_int <= A0 & B;
      A1_int <= A1 & B;
      --B_int  <= B;
    end if;
  end process;

  X0 <= mult_tables(conv_integer(unsigned(A0_int)));
  X1 <= mult_tables(conv_integer(unsigned(A1_int))); 
  c0 <= X0(3 downto 0); d0 <= X0(7 downto 4);
  c1 <= X1(3 downto 0); d1 <= X1(7 downto 4);

  --registering outputs
  --process (clk)
  --begin
  --	A0_int <= A0 & B;
  --	A1_int <= A1 & B;
  --	if (rising_edge(CLK)) then
  --      X0 <= mult_tables(conv_integer(unsigned(A0_int)));
  --      X1 <= mult_tables(conv_integer(unsigned(A1_int))); 
  --	end if;
  --end process;
  --
  --c0 <= X0(3 downto 0); d0 <= X0(7 downto 4);
  --c1 <= X1(3 downto 0); d1 <= X1(7 downto 4);

end ROM_based;



-----------------------------------------------------------------------------------------

