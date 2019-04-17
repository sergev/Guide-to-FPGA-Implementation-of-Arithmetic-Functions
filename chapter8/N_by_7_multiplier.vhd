----------------------------------------------------------------------------
-- N_by_7_multiplier.vhd
--
-- section 8.2.3 N * 7 bits parallel multiplier using counters
--
-- Computes: z = x·y + u + v
-- x, u: n bits
-- y, v: 7 bits
-- z: n+7 bits
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY N_by_7_multiplier IS
  GENERIC(n: NATURAL:= 8);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  y, v: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+6 DOWNTO 0)
);
END N_by_7_multiplier;

ARCHITECTURE circuit OF N_by_7_multiplier IS
  COMPONENT csa IS
    GENERIC(n: NATURAL);
  PORT (
    x1, x2, x3: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    y1, y2: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  COMPONENT seven_to_three IS
    GENERIC(n: NATURAL);
  PORT (
    x1, x2, x3, x4, x5, x6, x7: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    y1, y2, y3: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL yy0, yy1, yy2, yy3, yy4, yy5, yy6: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL w0, w1, w2, w3, w4, w5, w6: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL z0, z1, z2, z3, z4, z5, z6: STD_LOGIC_VECTOR(n+6 DOWNTO 0);
  SIGNAL x1, x2, x3: STD_LOGIC_VECTOR(n+6 DOWNTO 0);
  SIGNAL y1, y2: STD_LOGIC_VECTOR(n+6 DOWNTO 0);
  CONSTANT zero: STD_LOGIC_VECTOR(n DOWNTO 0) := (OTHERS => '0');
BEGIN
  
  yy0 <= (OTHERS => y(0));
  yy1 <= (OTHERS => y(1));
  yy2 <= (OTHERS => y(2));
  yy3 <= (OTHERS => y(3));
  yy4 <= (OTHERS => y(4));
  yy5 <= (OTHERS => y(5));
  yy6 <= (OTHERS => y(6));

  w0 <= (x AND yy0) + ('0'&u) + v(0);
  w1 <= (x AND yy1) + zero + v(1);
  w2 <= (x AND yy2) + zero + v(2);
  w3 <= (x AND yy3) + zero + v(3);
  w4 <= (x AND yy4) + zero + v(4);
  w5 <= (x AND yy5) + zero + v(5);
  w6 <= (x AND yy6) + zero + v(6);
  
  z0 <= "000000"&w0;
  z1 <= "00000"&w1&'0';
  z2 <= "0000"&w2&"00";
  z3 <= "000"&w3&"000";
  z4 <= "00"&w4&"0000";
  z5 <= "0"&w5&"00000";
  z6 <= w6&"000000";
  
  first_component: seven_to_three GENERIC MAP(n => n+7)
  PORT MAP(x1 => z0, x2 => z1, x3 => z2, x4 => z3, x5 => z4, x6 => z5, x7 => z6, y1 => x1, y2 => x2, y3 => x3);
  
  second_component: csa GENERIC MAP(n => n+7)
  PORT MAP(x1 => x1, x2 => x2, x3 => x3, y1 => y1, y2 => y2);
  
  z <= y1 + y2;

END circuit;
