----------------------------------------------------------------------------
-- six_to_three_counter.vhd
--
-- section 7.7 six_to_three_counter_cell 
-- n: size of each operand
-- Z = (x0 + x1 + x2 + x3 + x4 + x5) mod 2^n = (u + v + w) mod 2^n
--
-- Includes 3 entities:
-- lut6b (behavioural description of a 6-LUT)
-- six_to_three_counter_cell 
-- six_to_three_counter 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY lut6b IS
    GENERIC(truth_vector: STD_LOGIC_VECTOR(0 to 63));
PORT (
  a: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
  b: OUT STD_LOGIC 
);
END lut6b;
 
ARCHITECTURE behavior OF lut6b IS
BEGIN
  PROCESS(a)
    VARIABLE c: NATURAL; 
  BEGIN
    c := CONV_INTEGER(a);
    b <= truth_vector(c);
  END PROCESS; 
END behavior;

-----------------------------------------------------------
-- six_to_three_counter_cell
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY six_to_three_counter_cell IS
PORT (
  x: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
);
END six_to_three_counter_cell;

ARCHITECTURE circuit OF six_to_three_counter_cell IS 
  COMPONENT lut6b IS
    GENERIC(truth_vector: STD_LOGIC_VECTOR(0 to 63));
  PORT (
    a: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    b: OUT STD_LOGIC 
  );
  END COMPONENT;
BEGIN
  first_lut: lut6b
  GENERIC MAP(truth_vector => "0000000000000001000000010001011100000001000101110001011101111111")
  PORT MAP(a => x, b => z(2));
  second_lut: lut6b
  GENERIC MAP(truth_vector => "0001011101111110011111101110100001111110111010001110100010000001")
  PORT MAP(a => x, b => z(1));
  third_lut: lut6b
  GENERIC MAP(truth_vector => "0110100110010110100101100110100110010110011010010110100110010110")
  PORT MAP(a => x, b => z(0));
END circuit;

-----------------------------------------------------------
-- six_to_three_counter
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY six_to_three_counter IS
  GENERIC(n: NATURAL:= 8);
PORT(
  x0, x1, x2, x3, x4, x5: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  u, v, w: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);  
END six_to_three_counter;

ARCHITECTURE circuit OF six_to_three_counter IS
  COMPONENT six_to_three_counter_cell IS
  PORT (
    x: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
  END COMPONENT;
  TYPE outputs IS ARRAY (0 TO n-1) OF STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL z: outputs;
  TYPE inputs IS ARRAY (0 TO n-1) OF STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL x: inputs;
BEGIN
  iteration1: FOR i IN 0 TO n-1 GENERATE
    x(i) <= x0(i)&x1(i)&x2(i)&x3(i)&x4(i)&x5(i);
  END GENERATE;
  iteration2: FOR i IN 0 TO n-1 GENERATE
    cells: six_to_three_counter_cell
    PORT MAP(x => x(i), z => z(i));
    u(i) <= z(i)(0);
  END GENERATE;
  v(0) <= '0';
  iteration3: FOR i IN 1 TO n-1 GENERATE
    v(i) <= z(i-1)(1);
  END GENERATE;
  w(0) <= '0';
  w(1) <= '0';
  iteration4: FOR i IN 2 TO n-1 GENERATE
    w(i) <= z(i-2)(2);
  END GENERATE;
END circuit;
