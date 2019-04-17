----------------------------------------------------------------------------
-- base_2k_adder_muxcy.vhd
--
-- section 7.3 radix 2^k adder
-- k: defines the 2^k group. 
-- m: the amount of k groups.
-- The number of bits of operands is: m*k
--
-- defines entities: k_bit_adder and base_2k_adder
-- 
-- The k_bit_adder uses the Xilinx dedicated MUXCY component
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- for low level component instantiations
library UNISIM; use UNISIM.VComponents.all;

ENTITY k_bit_adder_muxcy IS
  GENERIC(k: NATURAL);
PORT(
  x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);
END k_bit_adder_muxcy;

ARCHITECTURE circuit OF k_bit_adder_muxcy IS
  SIGNAL s, t: STD_LOGIC_VECTOR(k DOWNTO 0);
  SIGNAL p: STD_LOGIC;
BEGIN
  s <= '0'&x + y;
  t(1) <= s(0);
  and_gates: FOR i in 1 TO k-1 GENERATE
    t(i+1) <= t(i) AND s(i);
  END GENERATE; 
  p <= t(k);
  --WITH p SELECT c_out <= c_in WHEN '1', s(k) WHEN OTHERS; --behavioural
  cy: MUXCY port map ( DI => s(k), CI => c_in, S => p, O => c_out);
  z <= s(k-1 DOWNTO 0) + c_in;
END circuit;


----------------------------------------------------------------------------
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY base_2k_adder_muxcy IS
  GENERIC(k: NATURAL:= 32; m: NATURAL:= 32);
PORT(
  x, y: IN STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);
END base_2k_adder_muxcy;

ARCHITECTURE circuit OF base_2k_adder_muxcy IS
  COMPONENT k_bit_adder_muxcy IS
    GENERIC(k: NATURAL);
  PORT(
    x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    c_in: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    c_out: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL carries: STD_LOGIC_VECTOR(m DOWNTO 0);
BEGIN
  carries(0) <= c_in;
  iteration: FOR i IN 0 TO m-1 GENERATE
    main_component: k_bit_adder_muxcy GENERIC MAP(k => k)
    PORT MAP(x => x(k*i+k-1 DOWNTO k*i), y => y(k*i+k-1 DOWNTO k*i), c_in => carries(i),
       z => z(k*i+k-1 DOWNTO k*i), c_out => carries(i+1));
  END GENERATE;
  c_out <= carries(m);
END circuit;  
