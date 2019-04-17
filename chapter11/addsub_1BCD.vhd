-------------------------------------------------------------------------------
-- A base 10 one digit adder-subtractor
-- a+b if sub=0; a + 9´s_comp(b) if sum=1
-- Has two architectures. A behavioral and a LowLevel that instantiates components.
-- "cout" sometimes is not used
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity addsub_1BCD is Port ( 
          a : in std_logic_vector(3 downto 0);
          b : in std_logic_vector(3 downto 0);
          sub : in std_logic;
          c : out std_logic_vector(3 downto 0);
          cout : out std_logic);
end addsub_1BCD;

architecture Behavioral of addsub_1BCD is

  signal op_b, z: std_logic_vector(3 downto 0);
  signal s: std_logic_vector(4 downto 0);

begin
   z(3) <= not (b(3) or b(2) or b(1)); z(2) <= b(2) xor b(1); z(1) <= b(1); z(0) <= not b(0);
   with sub select op_b <= z when '1', b when others;  
   s <= ('0' & a) + op_b;
   c <= s(3 downto 0);
   cout <= s(4);
end Behavioral;

--------------------------------------------------
architecture LowLevel of addsub_1BCD is

  signal o: std_logic_vector(3 downto 0);
  signal omx: std_logic_vector(3 downto 1);
  signal cin: std_logic := '0';

begin

  cin <= '0';
  
  P1_LUT3 : LUT3 generic map (INIT => x"96") -- (sub'.(a(0) xor b(0))) or (sub.(a(0) xor b(0)'))
    port map ( O => o(0), I0 => a(0), I1 => b(0), I2 => sub );

  P2_LUT2 : LUT2 generic map (INIT => "0110") -- a(1) xor b(1)
    port map ( O => o(1), I0 => a(1), I1 => b(1) );

  P3_LUT4 : LUT4 generic map ( INIT => x"9666") -- (sub'.(a(2) xor b(2))) or (sub. (a(2) xor (b(2) xor b(1))) )
    port map ( O => o(2), I0 => a(2), I1 => b(2), I2 => b(1), I3 => sub);

  P4_LUT5 : LUT5 generic map ( INIT => x"AAA96666") -- sub'.(a(3) xor b(3)) or ( sub.(a(3) xor (b(1)'.b(2)'.b(3)') ) )
    port map ( O => o(3), I0 => a(3), I1 => b(3), I2 => b(2), I3 => b(1),I4 => sub );

  Mxcy_1: MUXCY port map ( DI => a(0), CI => cin, S => o(0), O => omx(1));
  Mxcy_2: MUXCY port map ( DI => a(1), CI => omx(1), S => o(1), O => omx(2));
  Mxcy_3: MUXCY port map ( DI => a(2), CI => omx(2), S => o(2), O => omx(3));
  Mxcy_4: MUXCY port map ( DI => a(3), CI => omx(3), S => o(3), O => cout);

  XORCY_1 : XORCY port map ( O => c(0), CI => cin, LI => o(0) );
  XORCY_2 : XORCY port map ( O => c(1), CI => omx(1), LI => o(1) );
  XORCY_3 : XORCY port map ( O => c(2), CI => omx(2), LI => o(2) );
  XORCY_4 : XORCY port map ( O => c(3), CI => omx(3), LI => o(3) );

end LowLevel;