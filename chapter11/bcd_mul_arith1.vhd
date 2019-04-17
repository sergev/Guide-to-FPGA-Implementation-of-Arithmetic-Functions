----------------------------------------------------------------------
-- BCD mult 1x1 BCD
-- using binary multiplier and reduction
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bcd_mul_arith1 is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           c : out  STD_LOGIC_VECTOR (3 downto 0);
           d : out  STD_LOGIC_VECTOR (3 downto 0));
end bcd_mul_arith1;

architecture Behavioral of bcd_mul_arith1 is
  signal p, dc, dcp: STD_LOGIC_VECTOR (7 downto 0);
  signal cp: STD_LOGIC_VECTOR (4 downto 0);
  signal adj1,adj2: STD_LOGIC;
  signal cc: STD_LOGIC_VECTOR (4 downto 1);
begin
  p <= a*b;
  
  adj1 <= p(3) and (p(2) or p(1));
--  adj2 <= dcp(3) and (dcp(2) or dcp(1));
  adj2 <= (dcp(3) and (dcp(2) or dcp(1))) or (p(5) and p(4) and p(3));

  dcp <= ('0' & p(6 downto 0)) + ( p(6 downto 5) & '0' & p(4) & p(4) & '0') + ( p(6 downto 5) & '0') +( adj1 & adj1 & '0');
  dc <= dcp +( adj2 & adj2 & '0');
  d <= dc(7 downto 4);
  c <= dc(3 downto 0);

end Behavioral;