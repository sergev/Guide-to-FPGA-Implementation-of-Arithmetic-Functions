----------------------------------------------------------------------------
-- parallel_csa_multiplier.vhd
--
-- section 8.2.2 parallel carry save adder(CSA) multiplier
--
-- Computes: z = x·y + u + v
-- x, u: n bits
-- y, v: m bits
-- z: n+m bits
-- for n greater than or equal to m
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY parallel_csa_multiplier IS
  GENERIC(n: NATURAL:= 8; m: NATURAL:= 8);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  y, v: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+m-1 DOWNTO 0)
);
END parallel_csa_multiplier;

ARCHITECTURE circuit OF parallel_csa_multiplier IS
  TYPE matrix IS ARRAY (0 TO m-1) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL c, d, e, f: matrix;
  SIGNAL first_operand: STD_LOGIC_VECTOR(n-2 DOWNTO 0);
  SIGNAL second_operand: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN
  main_iteration: FOR i IN 0 TO m-1 GENERATE
    internal_iteration: FOR j IN 0 TO n-1 GENERATE
      f(i)(j) <= (x(j) AND y(i)) XOR c(i)(j) XOR d(i)(j);
      e(i)(j) <= (x(j) AND y(i) AND c(i)(j)) OR (x(j) AND y(i) AND d(i)(j)) OR (c(i)(j) AND d(i)(j));
    END GENERATE;
  END GENERATE;

  connections1: FOR j IN 0 TO n-1 GENERATE 
    c(0)(j) <= u(j); 
  END GENERATE;
  connections2: FOR i IN 1 TO m-1 GENERATE
    connections3: FOR j IN 0 TO n-2 GENERATE 
      c(i)(j) <= f(i-1)(j+1); 
    END GENERATE;
    c(i)(n-1) <= '0';
  END GENERATE;
  
  connections4: FOR j IN 0 TO m-1 GENERATE 
    d(0)(j) <= v(j); 
  END GENERATE;
  connections5: FOR j IN m TO n-1 GENERATE 
    d(0)(j) <= '0'; 
  END GENERATE;
  connections6: FOR i IN 1 TO m-1 GENERATE
    connections7: FOR j IN 0 TO n-1 GENERATE 
      d(i)(j) <= e(i-1)(j); 
    END GENERATE;
  END GENERATE;

  outputs: FOR j IN 0 TO m-1 GENERATE 
    z(j) <= f(j)(0); 
  END GENERATE;
  first_operand<= f(m-1)(n-1 DOWNTO 1);
  second_operand <= e(m-1);
  z(n+m-1 DOWNTO m) <= first_operand + second_operand;
  
END circuit;
