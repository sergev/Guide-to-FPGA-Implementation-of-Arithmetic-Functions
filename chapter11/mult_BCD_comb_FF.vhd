------------------------------------------------------------------
-- BCD multiplier X by Y (n by m digits)
-- FF in input and output
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use work.my_package.all;
--library UNISIM;
--use UNISIM.VComponents.all;

entity mult_BCD_FF is
	 Generic (NDigit : integer:=4; MDigit : integer:=4);
   Port (  clk, reset: in  STD_LOGIC;
           a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (MDigit*4-1 downto 0);
           p : out  STD_LOGIC_VECTOR ((NDigit+MDigit)*4-1 downto 0));
end mult_BCD_FF;

architecture Behavioral of mult_BCD_FF is

  component mult_BCD_comb is
	Generic (NDigit : integer:=4; MDigit : integer:=4);
   Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (MDigit*4-1 downto 0);
           p : out  STD_LOGIC_VECTOR ((NDigit+MDigit)*4-1 downto 0));
  end component;

  signal ia : STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
  signal ib : STD_LOGIC_VECTOR (MDigit*4-1 downto 0);
  signal op : STD_LOGIC_VECTOR ((NDigit+MDigit)*4-1 downto 0);
  
begin 
 
  FFs: process(clk, reset)
  begin
    if reset = '1' then
      ia <= (others => '0'); 
      ib <= (others => '0');
      p <= (others => '0');
    elsif rising_edge(clk) then
      ia <= a;
      ib <= b;
      p <= op;
    end if;
  end process;

	mult: mult_BCD_comb generic map (NDIGIT => NDigit, MDIGIT => MDigit) 
              PORT MAP( a => ia, b => ib, p => op); 
              
end Behavioral;

