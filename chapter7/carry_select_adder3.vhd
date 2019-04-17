----------------------------------------------------------------------------
-- carry_select_adder3.vhd
--
-- section 7.5 Logarithmic Adder
-- n1, n2 and n3 defindes
--
-- defines entities: carry_select_step3 and carry_select_adder3 and uses carry_select_adder2
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY carry_select_step3 IS
  GENERIC(n1, n2: NATURAL);
PORT(
  x, y: IN STD_LOGIC_VECTOR(n1*n2 - 1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n1*n2 - 1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);
END carry_select_step3;

ARCHITECTURE circuit OF carry_select_step3 IS
  COMPONENT carry_select_adder2 IS
    GENERIC(k, m: NATURAL);
  PORT(
    x, y: IN STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
    c_in: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
    c_out: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL z0, z1: STD_LOGIC_VECTOR(n1*n2 - 1 DOWNTO 0);
  SIGNAL c0, c1: STD_LOGIC;
BEGIN
  first_adder: carry_select_adder2 GENERIC MAP(k => n1, m => n2)
  PORT MAP(x => x, y => y, c_in => '0', z => z0, c_out => c0);
  second_adder: carry_select_adder2 GENERIC MAP(k => n1, m => n2)
  PORT MAP(x => x, y => y, c_in => '1', z => z1, c_out => c1);
  WITH c_in SELECT c_out <= c0 WHEN '0', c1 WHEN OTHERS; 
  WITH c_in SELECT z <= z0 WHEN '0', z1 WHEN OTHERS;
END circuit;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY carry_select_adder3 IS
  GENERIC(n1: NATURAL:= 8; n2: NATURAL:= 8; n3: NATURAL:= 8 );
PORT(
  x, y: IN STD_LOGIC_VECTOR(n1*n2*n3 - 1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n1*n2*n3 - 1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);END carry_select_adder3;

ARCHITECTURE circuit OF carry_select_adder3 IS
  COMPONENT carry_select_step3 IS
    GENERIC(n1, n2: NATURAL);
  PORT(
    x, y: IN STD_LOGIC_VECTOR(n1*n2 - 1 DOWNTO 0);
    c_in: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(n1*n2 - 1 DOWNTO 0);
    c_out: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL carries: STD_LOGIC_VECTOR(n3 DOWNTO 0);
BEGIN
  carries(0) <= c_in;
  iteration: FOR i IN 0 TO n3-1 GENERATE
    main_component:carry_select_step3 GENERIC MAP(n1 => n1, n2 => n2)
    PORT MAP(x => x(n1*n2*i + n1*n2 - 1 DOWNTO n1*n2*i), y => y(n1*n2*i + n1*n2 - 1 DOWNTO n1*n2*i), c_in => carries(i),
       z => z(n1*n2*i + n1*n2 - 1 DOWNTO n1*n2*i), c_out => carries(i+1));
  END GENERATE;
  c_out <= carries(n3);
END circuit;  
