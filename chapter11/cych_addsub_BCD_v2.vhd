------------------------------------------------------------------
-- Carry-chain BCD adder-subtractor
-- Low Level component instantiations in Xilinx devices
----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity cych_addsub_BCD_v2 is
   Generic (NDigit : integer:=4);
   Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           addsub : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end cych_addsub_BCD_v2;

architecture LowLevel of cych_addsub_BCD_v2 is

  type partialAdds is array (NDigit-1 downto 0) of STD_LOGIC_VECTOR (4 downto 0);
  signal sum: partialAdds;
  signal cyin: std_logic_vector(NDigit downto 0);
  signal g, p: std_logic_vector(NDigit-1 downto 0);

begin

   cyin(0) <= cin; 	
      
   GenAdd: for i in 0 to NDigit-1 generate
   --instanciar los addsub
       sum(i) <= ('0' & a((i+1)*4-1 downto i*4)) + b((i+1)*4-1 downto i*4);
   end generate;	
   
  GenCch: for i in 0 to NDigit-1 generate
    g(i) <= ((sum(i)(1) or sum(i)(2)) and sum(i)(3) ) or sum(i)(4); -- if sum(i) >= 10
    p(i) <= sum(i)(0) and sum(i)(3) and not sum(i)(1) and not sum(i)(2); -- if sum(i) = 9;   
    cy: MUXCY port map ( DI => g(i), CI => cyin(i), S => p(i), O => cyin(i+1));
  end generate;	
   
   GenAddRes: for i in 0 to NDigit-1 generate
       s((i+1)*4-1 downto i*4) <= sum(i)(3 downto 0) + (cyin(i+1) & cyin(i+1) & cyin(i));
   end generate;
   
  cout <= cyin(NDigit); 
   
end LowLevel;