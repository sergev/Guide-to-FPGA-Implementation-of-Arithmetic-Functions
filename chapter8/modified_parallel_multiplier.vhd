----------------------------------------------------------------------------
-- integer_csa_multiplier.vhd
--
-- section 8.4.2 modified shift and add multiplier for integer numbers
--
-- Computes: z = x·y + u + v
-- x, u: n+1 bits
-- y: m+1 bits
-- v: m bits
-- z: n+m+1 bits
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY modified_parallel_multiplier IS
  GENERIC(n: NATURAL:= 8; m: NATURAL:= 16);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(m DOWNTO 0);
  v: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+m+1 DOWNTO 0)
);
END modified_parallel_multiplier;

ARCHITECTURE circuit OF modified_parallel_multiplier IS
  TYPE matrix IS ARRAY (0 TO m) OF STD_LOGIC_VECTOR(n+1 DOWNTO 0);
  SIGNAL c, d, e, f: matrix;
BEGIN
  main_iteration: FOR i IN 0 TO m-1 GENERATE
    internal_iteration: FOR j IN 0 TO n GENERATE
      f(i)(j) <= (x(j) AND y(i)) XOR c(i)(j) XOR d(i)(j);
      e(i)(j) <= (x(j) AND y(i) AND c(i)(j)) OR (x(j) AND y(i) AND d(i)(j)) OR (c(i)(j) AND d(i)(j));
    END GENERATE;
    f(i)(n+1) <= (x(n) AND y(i)) XOR c(i)(n+1) XOR d(i)(n+1);
    e(i)(n+1) <= (x(n) AND y(i) AND c(i)(n+1)) OR (x(n) AND y(i) AND d(i)(n+1)) OR (c(i)(n+1) AND d(i)(n+1));
  END GENERATE;

  last_row: FOR j IN 0 TO n GENERATE
    f(m)(j) <= (NOT(x(j)) AND y(m)) XOR c(m)(j) XOR d(m)(j);
    e(m)(j) <= (NOT(x(j)) AND y(m) AND c(m)(j)) OR (NOT(x(j)) AND y(m) AND d(m)(j)) OR (c(m)(j) AND d(m)(j));
  END GENERATE;
  f(m)(n+1) <= (NOT(x(n)) AND y(m)) XOR c(m)(n+1) XOR d(m)(n+1);
  e(m)(n+1) <= (NOT(x(n)) AND y(m) AND c(m)(n+1)) OR (NOT(x(n)) AND y(m) AND d(m)(n+1)) OR (c(m)(n+1) AND d(m)(n+1));

  connections1: FOR j IN 0 TO n GENERATE c(0)(j) <= u(j); END GENERATE;
  c(0)(n+1) <= u(n);
  
  connections2: FOR i IN 1 TO m GENERATE
    connections3: FOR j IN 0 TO n GENERATE c(i)(j) <= f(i-1)(j+1); END GENERATE;
    c(i)(n+1) <= f(i-1)(n+1);
  END GENERATE;

  connections4: FOR i IN 0 TO m-1 GENERATE 
    d(i)(0) <= v(i); 
    connections5: FOR j IN 1 TO n+1 GENERATE d(i)(j) <= e(i)(j-1); END GENERATE;
  END GENERATE;
  d(m)(0) <= y(m); 
  connections6: FOR j IN 1 TO n+1 GENERATE d(m)(j) <= e(m)(j-1); END GENERATE;

  outputs: FOR j IN 0 TO m GENERATE z(j) <= f(j)(0); END GENERATE;
  z(m+n+1 DOWNTO m+1) <= f(m)(n+1 DOWNTO 1);
END circuit;
