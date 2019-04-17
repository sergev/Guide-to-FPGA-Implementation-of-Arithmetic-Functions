----------------------------------------------------------------------------
-- multiply_by_five.vhd
--
-- section 9.3 radix B division, B=10.
--
-- multiply_by_five uses digit_by_five and lut4b components
-- z = 5*x in BCD representation
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY digit_by_five IS
PORT(
  a: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  b: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END digit_by_five;

ARCHITECTURE circuit OF digit_by_five IS
  COMPONENT lut4b IS
      GENERIC(truth_vector: STD_LOGIC_VECTOR(0 to 15));
  PORT (
    a: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    b: OUT STD_LOGIC 
  );
  END COMPONENT;
BEGIN
   lut_b3: lut4b GENERIC MAP(truth_vector => "0000000101000000")
     PORT MAP(a => a, b => b(3));
   lut_b2: lut4b GENERIC MAP(truth_vector => "0101010010000000")
     PORT MAP(a => a, b => b(2));
   lut_b1: lut4b GENERIC MAP(truth_vector => "0001111000000000")
     PORT MAP(a => a, b => b(1));
   lut_b0: lut4b GENERIC MAP(truth_vector => "0110011001000000")
     PORT MAP(a => a, b => b(0));
END circuit;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY multiply_by_five IS
  GENERIC(n: NATURAL);
PORT(
  x: IN STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(4*n+3 DOWNTO 0)
);
END multiply_by_five;

ARCHITECTURE circuit OF multiply_by_five IS
  COMPONENT digit_by_five IS
  PORT(
    a: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    b: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL y: STD_LOGIC_VECTOR(4*n-1 DOWNTO 4);
BEGIN
  iteration: FOR i IN 1 TO n-1 GENERATE
    y(4*i+3 DOWNTO 4*i+1) <= x(4*(i-1)+3 DOWNTO 4*(i-1)+1);
    y(4*i) <= x(4*i);
    main_component: digit_by_five
    PORT MAP(a => y(4*i+3 DOWNTO 4*i), b => z(4*i+3 DOWNTO 4*i));
    z(3 DOWNTO 0) <= '0'&x(0)&'0'&x(0);
    z(4*n+3) <= '0';
    z(4*n+2 DOWNTO 4*n) <= x(4*n-1 DOWNTO 4*n-3);
   END GENERATE;
END circuit;
