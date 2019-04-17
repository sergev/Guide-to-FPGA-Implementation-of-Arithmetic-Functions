--------------------------------------------------------------
-- BCD mult 1x1 BCD
-- using binary multiplier and reduction, second version
-- 
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity bcd_mul_arith2 is port (
   x, y: in std_logic_vector (3 downto 0);
   c, d: out std_logic_vector (3 downto 0)
);
end bcd_mul_arith2;

architecture rtl of bcd_mul_arith2 is
  signal cc: std_logic_vector(4 downto 0);
  signal dd: std_logic_vector(3 downto 0);
  signal p: std_logic_vector(7 downto 0);
  signal cy1, cy0: std_logic;
begin
  p <= x * y;

  cc <= ('0'&p(3 downto 0)) + ("00"&p(4)&p(4)&'0') + ("00"&p(6 downto 5)&'0');
  dd <= ('0'&p(6 downto 4)) + ('0'&p(6 downto 5));
  cy1 <= cc(4) and (cc(3) or cc(2));
  cy0 <= (cc(4) or (cc(3) and (cc(2) or cc(1)))) and not(cy1);
  c <= cc(3 downto 0) + (cy1&(cy1 or cy0)&cy0&'0');
  d <= dd + ("00" & cy1 & cy0);
  
end rtl;
