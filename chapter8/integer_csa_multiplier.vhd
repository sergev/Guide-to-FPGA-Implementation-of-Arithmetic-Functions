----------------------------------------------------------------------------
-- integer_csa_multiplier.vhd
--
-- section 8.4.1 parallel carry save adder(CSA) multiplier for integer numbers
--
-- Computes: z = x·y + u + v
-- x, u: n+1 bits
-- y, v: m+1 bits
-- z: n+m+1 bits
-- for n greater than or equal to m
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY integer_csa_multiplier IS
  GENERIC(n: NATURAL:= 32; m: NATURAL:= 32);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y, v: IN STD_LOGIC_VECTOR(m DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+m+1 DOWNTO 0)
);
END integer_csa_multiplier;

ARCHITECTURE circuit OF integer_csa_multiplier IS
  COMPONENT parallel_csa_multiplier IS
    GENERIC(n, m: NATURAL);
  PORT(
    x, u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    y, v: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(n+m-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL long_x, long_y, long_u, long_v: STD_LOGIC_VECTOR(n+m+1 DOWNTO 0);
  SIGNAL long_z: STD_LOGIC_VECTOR(2*n+2*m+3 DOWNTO 0);
BEGIN

  long_x(n+m+1 DOWNTO n+1) <= (OTHERS => x(n)); long_x(n DOWNTO 0) <= x;
  long_u(n+m+1 DOWNTO n+1) <= (OTHERS => u(n)); long_u(n DOWNTO 0) <= u;
  long_y(n+m+1 DOWNTO m+1) <= (OTHERS => y(m)); long_y(m DOWNTO 0) <= y;
  long_v(n+m+1 DOWNTO m+1) <= (OTHERS => v(m)); long_v(m DOWNTO 0) <= v;

  main_component: parallel_csa_multiplier GENERIC MAP(n => n+m+2, m => n+m+2)
  PORT MAP(x => long_x, u => long_u, y => long_y, v => long_v, z => long_z);
  
  z <= long_z(n+m+1 DOWNTO 0);
  
END circuit;
