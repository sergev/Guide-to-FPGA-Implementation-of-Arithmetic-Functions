----------------------------------------------------------------------
-- A decimal shift register
-- 
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity bcd_shift_register is
   Generic (NDigit : integer:=4);
   Port ( serial_in : in  STD_LOGIC_VECTOR (3 downto 0);
        clk, shift : in  STD_LOGIC;
        parallel_out : inout  STD_LOGIC_VECTOR (NDigit*4-1 downto 0)
        );
end bcd_shift_register;

architecture behavior of bcd_shift_register is
begin
process(clk)
begin
  if clk'event and clk = '1' then
    if shift = '1' then 
      parallel_out <= parallel_out(NDigit*4-5 downto 0) & serial_in; 
    end if;
  end if;
end process;

end behavior;
