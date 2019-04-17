------------------------------------------------------------------
-- Special 5digits adder for divider
-- based on cych_adder_BCD_v1
-- b operand is 0..3 (only two bits)
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity special_5digit_adder is
   Port (  a, b : in  STD_LOGIC_VECTOR (19 downto 0);
           s : out  STD_LOGIC_VECTOR (19 downto 0));
end special_5digit_adder;

architecture arq of special_5digit_adder is
  constant NDigit : natural  := 5;
  type partialAdds is array (NDigit-1 downto 0) of STD_LOGIC_VECTOR (3 downto 0);
  signal sum: partialAdds;
  signal cyin: std_logic_vector(NDigit downto 0);
  signal g, p: std_logic_vector(NDigit-1 downto 0);

begin

	--cyin(0) <= cin; 	
	cyin(0) <= '0'; 	
		
	GenAdd: for i in 0 to NDigit-1 generate
       sum(i) <= (a((i+1)*4-1 downto i*4)) + b(i*4+1 downto i*4); --only two bits of b
	end generate;	
	
  GenCch: for i in 0 to NDigit-1 generate
    g(i) <= ((sum(i)(1) or sum(i)(2)) and sum(i)(3)) ; -- if sum(i) >= 10
    p(i) <= sum(i)(0) and sum(i)(3) and not sum(i)(1) and not sum(i)(2); -- if sum(i) = 9;
    --with p(i) select cyin(i+1) <= cyin(i) when '1', g(i) when others; --MUXcy
    cy: MUXCY port map ( DI => g(i),	CI => cyin(i), S => p(i), O => cyin(i+1));
  end generate;	
	
	GenAddRes: for i in 0 to NDigit-1 generate
       s((i+1)*4-1 downto i*4) <= sum(i)(3 downto 0) + (cyin(i+1) & cyin(i+1) & cyin(i));
	end generate;
	
  --cout <= cyin(NDigit); 
	
end arq;
