------------------------------------------------------------------
-- Simple BCD adder cell  for Ripple-Carry adder
-- 
------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity bcd_rp_cell is port (
  x, y: in std_logic_vector (3 downto 0);
  c_in: in std_logic;
  z: out std_logic_vector (3 downto 0);
  c_out: inout std_logic
);
end bcd_rp_cell;

architecture rtl of bcd_rp_cell is
signal t: std_logic_vector(4 downto 0);
begin

  t <= ('0' & x) + ('0' & y) + c_in;
  c_out <= t(4) or (t(3) and (t(2) or t(1)));
  --z <= t(3 downto 0) + ('0'& c_out & c_out & '0');
  z(3 downto 1) <= t(3 downto 1) + ('0'& c_out & c_out );
  z(0) <= t(0);

end rtl;

