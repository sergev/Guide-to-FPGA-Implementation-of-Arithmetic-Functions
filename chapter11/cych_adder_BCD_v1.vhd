------------------------------------------------------------------
-- Carry-chain BCD adder
-- Behavioral version. 
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- for low level components
--library UNISIM; use UNISIM.VComponents.all;

entity cych_adder_BCD_v1 is
   Generic (NDigit : integer:=4);
   Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end cych_adder_BCD_v1;

architecture Behavioral of cych_adder_BCD_v1 is

  type partialAdds is array (NDigit-1 downto 0) of STD_LOGIC_VECTOR (4 downto 0);
  signal sum: partialAdds;
  signal cyin: std_logic_vector(NDigit downto 0);
  signal g, p: std_logic_vector(NDigit-1 downto 0);

begin

   cyin(0) <= cin; 	
      
   GenAdd: for i in 0 to NDigit-1 generate
       sum(i) <= ('0' & a((i+1)*4-1 downto i*4)) + b((i+1)*4-1 downto i*4);
   end generate;	
   
  GenCch: for i in 0 to NDigit-1 generate
    g(i) <= ((sum(i)(1) or sum(i)(2)) and sum(i)(3) ) or sum(i)(4); -- if sum(i) >= 10
    p(i) <= sum(i)(0) and sum(i)(3) and not sum(i)(1) and not sum(i)(2); -- if sum(i) = 9;
    with p(i) select cyin(i+1) <= cyin(i) when '1', g(i) when others; -- A MUXcy
  end generate;	
   
   GenAddRes: for i in 0 to NDigit-1 generate
       s((i+1)*4-1 downto i*4) <= sum(i)(3 downto 0) + (cyin(i+1) & cyin(i+1) & cyin(i));
   end generate;
   
  cout <= cyin(NDigit); 
   
end Behavioral;