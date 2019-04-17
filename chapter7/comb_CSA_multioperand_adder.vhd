----------------------------------------------------------------------------
-- comb_CSA_multioperand_adder.vhd
--
-- section 7.7.2 combinational multioperand adder
-- Uses CSA (carry save adders)
-- m: number of operands of n bits
-- n: size of each operand
-- x = x0 & x1 & ... & xm-1
-- Z = x0 + x1 + ... + xm-1 mod 2^n
-- 
-- defines entities: three_to_two_counter and comb_csa_multioperand_adder
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY three_to_two_counter IS
  GENERIC(n: NATURAL);
PORT(
  a, b, c: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  u, v: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END three_to_two_counter;

ARCHITECTURE circuit OF three_to_two_counter IS

BEGIN
  v(0) <= '0';
  iteration: FOR i IN 0 TO n-2 GENERATE
    u(i) <= a(i) XOR b(i) XOR c(i);
    v(i+1) <= (a(i) AND b(i)) OR (a(i) AND c(i)) OR (b(i) AND c(i));
  END GENERATE;
  u(n-1) <= a(n-1) XOR b(n-1) XOR c(n-1);
END circuit;

---------------------------------------------------------------------
-- comb_csa_multioperand_adder
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY comb_csa_multioperand_adder IS
  GENERIC(n: NATURAL:= 8; m: NATURAL:= 8);
PORT(
  x: IN STD_LOGIC_VECTOR(n*m-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END comb_csa_multioperand_adder;

ARCHITECTURE circuit OF comb_csa_multioperand_adder IS
  COMPONENT three_to_two_counter IS
    GENERIC(n: NATURAL);
  PORT(
    a, b, c: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    u, v: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL u, v: STD_LOGIC_VECTOR(n*m-2*n-1 DOWNTO 0);
BEGIN

  first_row: three_to_two_counter GENERIC MAP(n => n)
  PORT MAP(a => x(n-1 DOWNTO 0), b => x(n+n-1 DOWNTO n), c => x(2*n+n-1 DOWNTO 2*n),
    u => u(n-1 DOWNTO 0), v => v(n-1 DOWNTO 0));
  iteration: FOR i IN 1 TO m-3 GENERATE
    following_rows: three_to_two_counter GENERIC MAP(n => n)
    PORT MAP(a => x((i+2)*n+n-1 DOWNTO (i+2)*n), b => u((i-1)*n+n-1 DOWNTO (i-1)*n), c => v((i-1)*n+n-1 DOWNTO (i-1)*n),
    u => u(i*n+n-1 DOWNTO i*n), v => v(i*n+n-1 DOWNTO i*n));
  END GENERATE;
  z <= u((m-3)*n+n-1 DOWNTO (m-3)*n) + v((m-3)*n+n-1 DOWNTO (m-3)*n);    
END circuit;
