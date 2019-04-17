----------------------------------------------------------
-- Carry Propagation direct from inputs
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity carry_chain_v1 is
 	 Port (s : in  STD_LOGIC_VECTOR (4 downto 0);
			 cin: in std_logic;
          cout: out std_logic); 		 
end carry_chain_v1;

architecture Behavioral of carry_chain_v1 is
  signal g,p: std_logic; 
begin

    g <= ((s(1) or s(2)) and s(3) ) or s(4); -- if s >= 10
    p <= s(0) and s(3) and not s(1) and not s(2); -- if s = 9;
    with p select cout <= cin when '1', g when others; -- A MUXcy

end Behavioral;


architecture LowLevel of carry_chain_v1 is
  signal g,p: std_logic; 
begin

   G_P: LUT6_2 generic map (INIT => X"0000_0200_FFFF_FC00")
        port map (O6 => p, O5 => g, I0 => s(0), I1 => s(1), I2 => s(2), I3 => s(3), I4 => s(4), I5 => '1');
   cy: MUXCY port map ( DI => g, CI => cin, S => p, O => cout);
  
end LowLevel;
