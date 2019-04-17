--------------------------------------------------------------
-- BCD simple arithmetic reducer.
-- Reduce 4 input BCD in 2 output BCD. D*10 + C
-- using the JPD arith reducer idea
-- It's a carry-save like adder.
-- addsub = 0 => D*10 + C = x0+x1+x2+x3 
-- addsub = 1 => D*10 + C = x0+x1+ complem(x2+x3) 
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity bcd_csa_addsub_4to2 is port (
  x0,x1,x2,x3: in std_logic_vector (3 downto 0);
  addsub: in std_logic;
  c, d: out std_logic_vector (3 downto 0)
);
end bcd_csa_addsub_4to2;

architecture rtl1 of bcd_csa_addsub_4to2 is
  signal s0, s1: std_logic_vector(4 downto 0);
  signal s: std_logic_vector(5 downto 0);
  signal m_x2, m_x3, xx2, xx3: std_logic_vector(3 downto 0);

  signal cc: std_logic_vector(4 downto 0);
  signal dd: std_logic_vector(3 downto 0);
  signal p: std_logic_vector(7 downto 0);
  signal cy1, cy0: std_logic;
begin

  --m_x2 <= "1001" - x2;  m_x3 <= "1001" - x3;
  m_x2(3) <= not (x2(3) or x2(2) or x2(1)); m_x2(2) <= x2(2) xor x2(1); m_x2(1) <= x2(1); m_x2(0) <= not x2(0);
  m_x3(3) <= not (x3(3) or x3(2) or x3(1)); m_x3(2) <= x3(2) xor x3(1); m_x3(1) <= x3(1); m_x3(0) <= not x3(0);
  with addsub select xx2 <= x2 when '0', m_x2 when others;
  with addsub select xx3 <= x3 when '0', m_x3 when others;

  s0 <= ('0' & x0) + x1;
  s1 <= ('0' & xx2) + xx3;
  s <= ('0' & s0) + s1;
  p <= "00" & s; -- this number is =< 36d (4x9) 36d = 24h = 10_0100b. => p(7:6) = "00"
  --more over since x1 is in {0..3} p < 31 => p(5) = '0'

  cc(4 downto 1) <= ('0' & p(3 downto 1)) + ("00"&p(4)&p(4));
  cc(0) <= p(0);
  dd <= "000" & p(4); --
--  cc(4 downto 1) <= ('0' & p(3 downto 1)) + ("00"&p(4)&p(4)) + ("000" & p(5));
--  cc(0) <= p(0);
--  dd(1 downto 0) <= p(5 downto 4) + p(5); --10 + 1 or 01+0
--  dd(3 downto 2) <= "00";
  cy1 <= cc(4) and (cc(3) or cc(2));
  cy0 <= (cc(4) or (cc(3) and (cc(2) or cc(1)))) and not(cy1);
  c(3 downto 1) <= cc(3 downto 1) + (cy1 & (cy1 or cy0) & cy0);
  c(0) <= cc(0);
  d(1 downto 0) <= dd(1 downto 0) + (cy1 & cy0);
  d(3 downto 2) <= "00";
end rtl1;




