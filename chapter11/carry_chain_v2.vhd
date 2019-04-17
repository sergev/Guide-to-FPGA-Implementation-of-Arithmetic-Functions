----------------------------------------------------------
-- Carry Propagation direct from inputs
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity carry_chain_v2 is
 	 Port ( x, y : in  STD_LOGIC_VECTOR (3 downto 0);
			 sub, cin: in std_logic;
          cout: out std_logic); 		 
end carry_chain_v2;

architecture Behavioral of carry_chain_v2 is
  signal gga, ggs, ppa, pps: std_logic;
  signal gg,pp,g,p: std_logic; 
  signal k1, k2, k3, p1, p2, p3, g1, g2, g3: std_logic; 
  signal z0, z1, z2, z3, kk1, kk2, kk3, pp1, pp2, pp3, gg1, gg2, gg3: std_logic; 

begin
   k1 <= not(x(1) or y(1));  p1 <= x(1) xor y(1); g1 <= x(1) and y(1);
   k2 <= not(x(2) or y(2));  p2 <= x(2) xor y(2); g2 <= x(2) and y(2);
   k3 <= not(x(3) or y(3));  p3 <= x(3) xor y(3); g3 <= x(3) and y(3);
   z3 <= not (y(3) or y(2) or y(1)); z2 <= y(2) xor y(1); z1 <= y(1); z0 <= not y(0);
   kk1 <= not(x(1) or z1);  pp1 <= x(1) xor z1; gg1 <= x(1) and z1;
   kk2 <= not(x(2) or z2);  pp2 <= x(2) xor z2; gg2 <= x(2) and z2;
   kk3 <= not(x(3) or z3);  pp3 <= x(3) xor z3; gg3 <= x(3) and z3;

-- Gen pp
  ppa <= (k1 and p3 and k2) or (k3 and k1 and g2) or (p2 and g1 and k3);
  pps <= (kk1 and pp3 and kk2) or (kk3 and kk1 and gg2) or (pp2 and gg1 and kk3);
  
  with sub select pp <= pps when '1', ppa when others; --MUXF7    

-- Gen gg
  gga <= g3 or (p3 and p2) or (p3 and p1) or (g2 and p1) or (g2 and g1);
  ggs <= gg3 or (pp3 and (pp2 or pp1)) or (gg2 and pp1) or (gg2 and gg1);
  with sub select gg <= ggs when '1', gga when others; --MUXF7 	

  p <= pp and (x(0) xor y(0) xor sub);
  g <= gg or (pp and x(0) and (y(0) xor sub));
  
  with p select cout <= cin when '1', g when others; --MUXcy    

end Behavioral;

architecture mediumLevel of carry_chain_v2 is
  signal gga, ggs, ppa, pps: std_logic;
  signal gg,pp,g,p: std_logic; 
  signal k1, k2, k3, p1, p2, p3, g1, g2, g3: std_logic; 
  signal z0, z1, z2, z3, kk1, kk2, kk3, pp1, pp2, pp3, gg1, gg2, gg3: std_logic; 

begin

   k1 <= not(x(1) or y(1));  p1 <= x(1) xor y(1); g1 <= x(1) and y(1);
   k2 <= not(x(2) or y(2));  p2 <= x(2) xor y(2); g2 <= x(2) and y(2);
   k3 <= not(x(3) or y(3));  p3 <= x(3) xor y(3); g3 <= x(3) and y(3);
   z3 <= not (y(3) or y(2) or y(1)); z2 <= y(2) xor y(1); z1 <= y(1); z0 <= not y(0);
   kk1 <= not(x(1) or z1);  pp1 <= x(1) xor z1; gg1 <= x(1) and z1;
   kk2 <= not(x(2) or z2);  pp2 <= x(2) xor z2; gg2 <= x(2) and z2;
   kk3 <= not(x(3) or z3);  pp3 <= x(3) xor z3; gg3 <= x(3) and z3;

-- Gen pp
  ppa <= (k1 and p3 and k2) or (k3 and k1 and g2) or (p2 and g1 and k3);
  pps <= (kk1 and pp3 and kk2) or (kk3 and kk1 and gg2) or (pp2 and gg1 and kk3);
  MUX7_pp : MUXF7  port map ( O => pp, I0 => ppa,  I1 => pps, S => sub );


-- Gen gg
  gga <= g3 or (p3 and p2) or (p3 and p1) or (g2 and p1) or (g2 and g1);
  ggs <= gg3 or (pp3 and (pp2 or pp1)) or (gg2 and pp1) or (gg2 and gg1);
  MUX7_gg : MUXF7   port map ( O => gg,  I0 => gga,  I1 => ggs, S => sub  );

  p <= pp and (x(0) xor y(0) xor sub);
  g <= gg or (pp and x(0) and (y(0) xor sub));
  Mxcy_1: MUXCY port map (DI => g, CI => cin, S => p, O => cout);

end mediumLevel;


architecture LowLevel of carry_chain_v2 is
  signal gga, ggs, ppa, pps: std_logic;
  signal gg,pp,g,p: std_logic; 
begin

-- Gen pp
	LUT6_PP_a : LUT6  generic map (INIT => X"0000000102040810") -- (k1 and p3 and k2) or (k3 and k1 and g2) or (p2 and g1 and k3)
      port map ( O => ppa, I0 => y(1), I1 => y(2), I2 => y(3), I3 => x(1),I4 => x(2), I5 => x(3));
	LUT6_PP_s : LUT6  generic map ( INIT => X"0804021008040201")  -- (k1 and p3 and k2) or (k3 and k1 and g2) or (p2 and g1 and k)
      port map ( O => pps, I0 => x(1),I1 => x(2),I2 => x(3), I3 => y(1), I4 => y(2), I5 => y(3));	
	MUX7_pp : MUXF7  port map ( O => pp, I0 => ppa,  I1 => pps, S => sub );


-- Gen gg
	LUT6_GG_a : LUT6 generic map ( INIT => X"FFFFFFFEFCF8F0E0") -- g3 or (p3 and p2) or (p3 and p1) ( p1 and g2) or (g2 and g1)
      port map ( O => gga,I0 => y(1), I1 => y(2),I2 => y(3),I3 => x(1), I4 => x(2), I5 => x(3));	
	LUT6_G0_s : LUT6 generic map ( INIT => X"D0B8FCE0D0B8FCFE")  -- g3 or (p3 and p2) or (p3 and p1) ( p1 and g2) or (g2 and g1)
      port map ( O => ggs,I0 => x(1), I1 => x(2), I2 => x(3), I3 => y(1), I4 => y(2), I5 => y(3));
	MUX7_gg : MUXF7   port map ( O => gg,  I0 => gga,  I1 => ggs, S => sub  );

  -- p = pp.(x xor y xor sub) (96009600) - g = gg + pp.x.(y xor sub)  (FFFF6000)
  GP1_LUT6 : LUT6_2 generic map ( INIT => X"96009600FFFF6000") 
        port map ( O6 => p, O5 => g, I0 => sub, I1 => y(0), I2 => x(0), I3 => pp, I4 => gg, I5 => '1');
  Mxcy_1: MUXCY port map (DI => g, CI => cin,S => p, O => cout);

end LowLevel;
