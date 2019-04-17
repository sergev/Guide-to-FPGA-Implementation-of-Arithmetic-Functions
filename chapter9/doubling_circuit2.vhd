----------------------------------------------------------------------------
-- doubling_circuit2.vhd
--
-- section 9.3 radix B division, B=10.
--
-- doubling_circuits2 uses digit_doubling2 and lut4b components
-- z = 2*x + c_in in BCD representation
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY digit_doubling2 IS
PORT(
  a: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  u: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  d: OUT STD_LOGIC
);
END digit_doubling2;

ARCHITECTURE circuit OF digit_doubling2 IS
  COMPONENT lut4b IS
      GENERIC(truth_vector: STD_LOGIC_VECTOR(0 to 15));
  PORT (
    a: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    b: OUT STD_LOGIC 
  );
  END COMPONENT;
BEGIN
lut_d: lut4b GENERIC MAP(truth_vector => "0000011111000000")
  PORT MAP(a => a, b => d);
lut_u3: lut4b GENERIC MAP(truth_vector => "0000100001000000")
  PORT MAP(a => a, b => u(3));
lut_u2: lut4b GENERIC MAP(truth_vector => "0011000110000000")
  PORT MAP(a => a, b => u(2));
lut_u1: lut4b GENERIC MAP(truth_vector => "0101001010000000")
  PORT MAP(a => a, b => u(1));
u(0) <= '0';
END circuit;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY doubling_circuit2 IS
  GENERIC(n: NATURAL);
PORT(
  x: IN STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(4*n DOWNTO 0)
);
END doubling_circuit2;

ARCHITECTURE circuit OF doubling_circuit2 IS
  COMPONENT digit_doubling2 IS
  PORT(
    a: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    u: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    d: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL y0: STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
  SIGNAL y1: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN
  first_iteration: FOR i IN 0 TO n-1 GENERATE
    first_component: digit_doubling2
    PORT MAP(a => x(4*i+3 DOWNTO 4*i), u => y0(4*i+3 DOWNTO 4*i), d => y1(i));
  END GENERATE;

  z(3 DOWNTO 0) <= y0(3 DOWNTO 1) & c_in;
  second_iteration: FOR i IN 1 TO n-1 GENERATE
    z(4*i+3 DOWNTO 4*i) <= y0(4*i+3 DOWNTO 4*i+1) & y1(i-1);  
  END GENERATE;
  z(4*n) <= y1(n-1);  
END circuit;
   
  
