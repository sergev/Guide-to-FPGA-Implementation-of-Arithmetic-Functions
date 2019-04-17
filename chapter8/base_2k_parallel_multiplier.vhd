----------------------------------------------------------------------------
-- base_2k_parallel_multiplier.vhd
--
-- section 8.2.4 base 2^k parallel multiplier
--
-- Computes: z = x·y + u + v
-- x, u: n bits
-- y, v: m bits
-- z: n+m bits
-- 
--
-- uses k_by_k_parallel_multiplier (computes a·b + c + d = zH·2^k + zL)
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY base_2k_parallel_multiplier IS
  GENERIC(n: NATURAL:= 4; m: NATURAL:= 4; k: NATURAL:= 8);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n*k-1 DOWNTO 0);
  y, v: IN STD_LOGIC_VECTOR(m*k-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n*k+m*k-1 DOWNTO 0)
);
END base_2k_parallel_multiplier;

ARCHITECTURE circuit OF base_2k_parallel_multiplier IS
  COMPONENT k_by_k_parallel_multiplier IS
    GENERIC(k: NATURAL);
  PORT(
    a, c: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    b, d: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
   zL, zH: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0)
  );
  END COMPONENT;
  TYPE matrix IS ARRAY (0 TO m-1, 0 TO n-1) OF STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  SIGNAL c, d, e, f: matrix;
BEGIN
  main_iteration: FOR i IN 0 TO m-1 GENERATE
    internal_iteration: FOR j IN 0 TO n-1 GENERATE
      a_multiplier: k_by_k_parallel_multiplier GENERIC MAP(k => k)
      PORT MAP(a => x(j*k+k-1 DOWNTO j*k), b => y(i*k+k-1 DOWNTO i*k), c => c(i,j),
      d => d(i,j), zH => e(i,j), zL => f(i,j));
    END GENERATE;
  END GENERATE;
  connections1: FOR j IN 0 TO n-1 GENERATE c(0,j) <= u(j*k+k-1 DOWNTO j*k); END GENERATE;
  connections2: FOR i IN 1 TO m-1 GENERATE
    connections3: FOR j IN 0 TO n-2 GENERATE c(i,j) <= f(i-1,j+1); END GENERATE;
    c(i,n-1) <= e(i-1,n-1);
  END GENERATE;
  connections4: FOR i IN 0 TO m-1 GENERATE 
    d(i,0) <= v(i*k+k-1 DOWNTO i*k); 
    connections5: FOR j IN 1 TO n-1 GENERATE d(i,j) <= e(i,j-1); END GENERATE;
  END GENERATE;
  outputs1: FOR j IN 0 TO m-1 GENERATE z(j*k+k-1 DOWNTO j*k ) <= f(j,0); END GENERATE;
  outputs2: FOR j IN m TO m+n-2 GENERATE z(j*k+k-1 DOWNTO j*k ) <= f(m-1,j-m+1); END GENERATE;
  z(m*k+n*k-1 DOWNTO m*k+n*k-k) <= e(m-1,n-1);
END circuit;
