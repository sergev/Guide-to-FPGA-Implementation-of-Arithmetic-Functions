----------------------------------------------------
-- decimal carry-save adder-subtractor:
-- 4 inputs 2 outputs
-- addsub = 0: s + c = s_s+s_c + m_s+m_c
-- addsub = 1: s + c = s_s+s_c - (m_s+m_c)  
-- s_s = xxx0d; s_c xxxx0d;
-- m_s = xxxxx; m_c=xxxx0d;
-- s(0) = m_s(0) or compl m_s(0);
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity decimal_CSAS_4to2 is 
    generic (NDigit: natural:= 4);
    Port ( 
        s_s, s_c : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        m_s, m_c : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        addsub : in  STD_LOGIC;
        s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        c : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0) );
end decimal_CSAS_4to2;

architecture circuit of decimal_CSAS_4to2 is

   component bcd_csa_addsub_4to2 is port (
     x0,x1,x2,x3: in std_logic_vector (3 downto 0);
     addsub: in std_logic;
     c, d: out std_logic_vector (3 downto 0));
   end component;

   signal ms0: STD_LOGIC_VECTOR(3 downto 0);
   signal cc : STD_LOGIC_VECTOR (NDigit*4+3 downto 0);

begin

  --ms0 <= "1001" - m_s(3 downto 0);
  ms0(3) <= not (m_s(3) or m_s(2) or m_s(1)); ms0(2) <= m_s(2) xor m_s(1); ms0(1) <= m_s(1); ms0(0) <= not m_s(0);

  with addsub select s(3 downto 0) <= m_s(3 downto 0) when '0', ms0 when others;

  c(3 downto 0) <= "000" & addsub; -- m_s complement + 1
  c(7 downto 4) <= "000" & addsub; --due to the complement of m_c!

  forg: for i in 1 to NDigit-1 generate
    mcomp: bcd_csa_addsub_4to2 port map(
        x0 => s_s(i*4+3 downto i*4), x1 => s_c((i)*4+3 downto (i)*4), 
        x2 => m_s(i*4+3 downto i*4), x3 => m_c((i)*4+3 downto (i)*4), 
        addsub => addsub, c =>  s(i*4+3 downto i*4), d=>  cc((i+1)*4+3 downto (i+1)*4));
  end generate;

  c(NDigit*4-1 downto 8) <= cc(NDigit*4-1 downto 8);

end circuit;

