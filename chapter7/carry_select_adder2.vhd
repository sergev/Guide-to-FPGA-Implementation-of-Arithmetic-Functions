----------------------------------------------------------------------------
-- carry_select_adder2.vhd
--
-- section 7.4 carry select adder
-- k: defines the 2^k group. 
-- m: the amount of k groups.
-- The number of bits of operands is: m*k
--
-- defines entities: carry_select_step2 and carry_select_adder2
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY carry_select_step2 IS
  GENERIC(k: NATURAL);
PORT(
  x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);
END carry_select_step2;

ARCHITECTURE circuit OF carry_select_step2 IS
  SIGNAL t0, t1: STD_LOGIC_VECTOR(k DOWNTO 0);
  SIGNAL z0, z1: STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  SIGNAL c0, c1: STD_LOGIC;
BEGIN
  t0 <= '0'&x + y;
  t1 <= '0'&x + y + '1';
  c0 <= t0(k);
  c1 <= t1(k);
  z0 <= t0(k-1 DOWNTO 0);
  z1 <= t1(k-1 DOWNTO 0);
  WITH c_in SELECT c_out <= c0 WHEN '0', c1 WHEN OTHERS; 
  WITH c_in SELECT z <= z0 WHEN '0', z1 WHEN OTHERS;
END circuit;

--------------------------------------------------------------------------
-- Carry Select Adder 2
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY carry_select_adder2 IS
  GENERIC(k: NATURAL:= 8; m: NATURAL:= 8);
PORT(
  x, y: IN STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);
END carry_select_adder2;

ARCHITECTURE circuit OF carry_select_adder2 IS
  COMPONENT carry_select_step2 IS
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
    main_component:carry_select_step2 GENERIC MAP(k => k)
    PORT MAP(x => x(k*i+k-1 DOWNTO k*i), y => y(k*i+k-1 DOWNTO k*i), c_in => carries(i),
       z => z(k*i+k-1 DOWNTO k*i), c_out => carries(i+1));
  END GENERATE;
  c_out <= carries(m);
END circuit;  
