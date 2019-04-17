----------------------------------------------------------------------------
-- postcorrection_multiplier.vhd
--
-- section 8.4.3  postcorrection multiplier for integer numbers
--
-- Computes: z = x·y
-- x: n+1 bits
-- y: m+1 bits
-- z: n+m+1 bits
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY postcorrection_multiplier IS
  GENERIC(n: NATURAL:= 8; m: NATURAL:= 8);
PORT(
  x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(m DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+m+1 DOWNTO 0)
);
END postcorrection_multiplier;

ARCHITECTURE circuit OF postcorrection_multiplier IS
  TYPE matrix IS ARRAY (0 TO m) OF STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL c, d, e, f: matrix;
BEGIN
  main_iteration: FOR i IN 0 TO m-1 GENERATE
    internal_iteration: FOR j IN 0 TO n-1 GENERATE
      f(i)(j) <= (x(j) AND y(i)) XOR c(i)(j) XOR d(i)(j);
      e(i)(j) <= (x(j) AND y(i) AND c(i)(j)) OR (x(j) AND y(i) AND d(i)(j)) OR (c(i)(j) AND d(i)(j));
    END GENERATE;
  END GENERATE;
  
  first_column: FOR i IN 0 TO m-1 GENERATE
    f(i)(n) <= (x(n) NAND y(i)) XOR c(i)(n) XOR d(i)(n);
    e(i)(n) <= ((x(n) NAND y(i)) AND c(i)(n)) OR ((x(n) NAND y(i)) AND d(i)(n)) OR (c(i)(n) AND d(i)(n));
  END GENERATE;

  last_row: FOR j IN 0 TO n-1 GENERATE
    f(m)(j) <= (x(j) NAND y(m)) XOR c(m)(j) XOR d(m)(j);
    e(m)(j) <= ((x(j) NAND y(m)) AND c(m)(j)) OR ((x(j) NAND y(m)) AND d(m)(j)) OR (c(m)(j) AND d(m)(j));
  END GENERATE;

  f(m)(n) <= (x(n) AND y(m)) XOR c(m)(n) XOR d(m)(n);
  e(m)(n) <= (x(n) AND y(m) AND c(m)(n)) OR (x(n) AND y(m) AND d(m)(n)) OR (c(m)(n) AND d(m)(n));
  
  connections1: FOR j IN 0 TO n-1 GENERATE c(0)(j) <= '0'; END GENERATE;
  c(0)(n) <= '1';

  connections2: FOR i IN 1 TO m GENERATE
    connections3: FOR j IN 0 TO n-1 GENERATE c(i)(j) <= f(i-1)(j+1); END GENERATE;
    c(i)(n) <= e(i-1)(n);
  END GENERATE;
  
  connections4: FOR i IN 0 TO m GENERATE 
    connections5: FOR j IN 1 TO n GENERATE d(i)(j) <= e(i)(j-1); END GENERATE;
  END GENERATE;

  connections6: FOR i IN 0 TO m-1 GENERATE d(i)(0) <= '0'; END GENERATE;
  d(m)(0) <= '1';

  outputs: FOR j IN 0 TO m GENERATE z(j) <= f(j)(0); END GENERATE;
  z(m+n DOWNTO m+1) <= f(m)(n DOWNTO 1);
  z(m+n+1) <= NOT(e(m)(n));
    
END circuit;
