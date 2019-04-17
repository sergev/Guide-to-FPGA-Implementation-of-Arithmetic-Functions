--------------------------------------------------------
-- adder-subtractor (a_s_cell.vhd)
-- The basic cell for non-restoring division 
-- used in FP divider of section 12.5.3
--------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity a_s is
    generic( NBITS : integer := 6 );
    port (
        op_a: in STD_LOGIC_VECTOR (NBITS downto 0);
        op_m: in STD_LOGIC_VECTOR (NBITS downto 0);
        as: in STD_LOGIC;
        outp: out STD_LOGIC_VECTOR (NBITS downto 0) );
end a_s;

architecture a_s_cel_arch of a_s is

begin

   adder_subt: process (as,op_a,op_m)
   begin
      if as = '1' then
         outp <= op_a + op_m;
      else
         outp <= op_a - op_m;
      end if; 
   end process;

end a_s_cel_arch;


