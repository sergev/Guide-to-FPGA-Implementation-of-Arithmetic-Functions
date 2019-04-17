------------------------------------------------------------------
-- Carry-chain BCD adder
-- Low Level component instantiations for the carry chain in Xilinx devices
----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity cych_adder_BCD_v2 is
   Generic (NDigit : integer:=16);
   Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end cych_adder_BCD_v2;

architecture LowLevel of cych_adder_BCD_v2 is

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
--  For four input LUTs devices (Virtex, Virtex II, Spartan 3)
--    G_LUT : LUT4  generic map (INIT => X"FFE0") -- 
--         port map ( O => g(i), I0 => sum(i)(1), I1 => sum(i)(2), I2 => sum(i)(3), I3 => sum(i)(4));
--    P_LUT : LUT3  generic map (INIT => X"08") -- 
--         port map ( O => p(i), I0 => sum(i)(0), I1 => sum(i)(3), I2 => g(i));
-- for six input devices (V5, V6, 7-series) use LUT6_2 component or use the  the equivalent behavioral description. 
--    g(i) <= ((sum(i)(1) or sum(i)(2)) and sum(i)(3) ) or sum(i)(4); -- if sum(i) >= 10
--    p(i) <= sum(i)(0) and sum(i)(3) and not sum(i)(1) and not sum(i)(2); -- if sum(i) = 9;
   G_P: LUT6_2 generic map (INIT => X"0000_0200_FFFF_FC00")
   port map (O6 => p(i), O5 => g(i),  
      I0 => sum(i)(0), I1 => sum(i)(1), I2 => sum(i)(2), 
      I3 => sum(i)(3), I4 => sum(i)(4), I5 => '1');

    cy: MUXCY port map ( DI => g(i), CI => cyin(i), S => p(i), O => cyin(i+1));
  end generate;	
   
   GenAddRes: for i in 0 to NDigit-1 generate
      s((i+1)*4-1 downto i*4) <= sum(i)(3 downto 0) + (cyin(i+1) & cyin(i+1) & cyin(i));
   end generate;
   
  cout <= cyin(NDigit); 
   
end LowLevel;