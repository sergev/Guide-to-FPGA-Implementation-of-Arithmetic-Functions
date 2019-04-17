----------------------------------------------------------------------------
-- MR_parallel_multiplier.vhd
--
-- section 8.2.4 a mixed radix multiplier
--
-- Computes: z = x·y + u + v
-- x, u: n·k1 bits
-- y, v: m·k2 bits
-- z: (m+n-1)·k1 + k2 bits
-- k2 < k1
-- 
-- uses: 
-- k1_by_k2_parallel_multiplier (computes a·b + c + d = zH·2^k + zL)
-- MR_multiplier_row (a row of n k1_by_k2_parallel_multiplier)
--
----------------------------------------------------------------------------
--a·b + c + d = zH·2^k + zL
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY k1_by_k2_parallel_multiplier IS
  GENERIC(k1, k2: NATURAL);
PORT(
  a, c: IN STD_LOGIC_VECTOR(k1-1 DOWNTO 0);
  b, d: IN STD_LOGIC_VECTOR(k2-1 DOWNTO 0);
  zL: OUT STD_LOGIC_VECTOR(k1-1 DOWNTO 0);
  zH: OUT STD_LOGIC_VECTOR(k2-1 DOWNTO 0)
);
END k1_by_k2_parallel_multiplier;

ARCHITECTURE behavior OF k1_by_k2_parallel_multiplier IS
  SIGNAL z: STD_LOGIC_VECTOR(k1+k2-1 DOWNTO 0);
BEGIN
  z <= a*b + c + d;
  zH <= z(k1+k2-1 DOWNTO k1);
  zL <= z(k1-1 DOWNTO 0);
END behavior;

----------------------------------------------------------------------------
-- MR_multiplier_row
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY MR_multiplier_row IS
  GENERIC(n, k1, k2: NATURAL);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n*k1-1 DOWNTO 0);
  b, d: IN STD_LOGIC_VECTOR(k2-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n*k1+k2 -1 DOWNTO 0)
);
END MR_multiplier_row;
 
ARCHITECTURE circuit OF MR_multiplier_row IS
  COMPONENT k1_by_k2_parallel_multiplier IS
    GENERIC(k1, k2: NATURAL);
  PORT(
    a, c: IN STD_LOGIC_VECTOR(k1-1 DOWNTO 0);
    b, d: IN STD_LOGIC_VECTOR(k2-1 DOWNTO 0);
    zL: OUT STD_LOGIC_VECTOR(k1-1 DOWNTO 0);
    zH: OUT STD_LOGIC_VECTOR(k2-1 DOWNTO 0)
  );
  END COMPONENT;
  TYPE matrix_e IS ARRAY(0 TO n-1) OF STD_LOGIC_VECTOR(k2-1 DOWNTO 0);
  SIGNAL e: matrix_e;
BEGIN
  first_cell: k1_by_k2_parallel_multiplier GENERIC MAP(k1 => k1, k2 => k2)
  PORT MAP(a => x(k1-1 DOWNTO 0), b => b, c => u(k1-1 DOWNTO 0), d => d,
  zL => z(k1-1 DOWNTO 0), zH => e(0));
  iteration: FOR i IN 1 TO n-1 GENERATE
  other_cells: k1_by_k2_parallel_multiplier GENERIC MAP(k1 => k1, k2 => k2)
  PORT MAP(a => x(i*k1+k1-1 DOWNTO i*k1), b => b, c => u(i*k1+k1-1 DOWNTO i*k1), d => e(i-1),
  zL => z(i*k1+k1-1 DOWNTO i*k1), zH => e(i));
  END GENERATE;
  z(n*k1+k2-1 DOWNTO n*k1) <= e(n-1);
END circuit;

----------------------------------------------------------------------------
-- MR_parallel_multiplier
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY MR_parallel_multiplier IS
  GENERIC(n, m, k1, k2: NATURAL);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n*k1-1 DOWNTO 0);
  y, v: IN STD_LOGIC_VECTOR(m*k2-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n*k1+m*k2 -1 DOWNTO 0)
);
END MR_parallel_multiplier;

ARCHITECTURE circuit OF MR_parallel_multiplier IS
  COMPONENT MR_multiplier_row IS
    GENERIC(n, k1, k2: NATURAL);
  PORT(
    x, u: IN STD_LOGIC_VECTOR(n*k1-1 DOWNTO 0);
    b, d: IN STD_LOGIC_VECTOR(k2-1 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(n*k1+k2 -1 DOWNTO 0)
  );
  END COMPONENT;
  TYPE matrix_z IS ARRAY(0 TO m-1) OF STD_LOGIC_VECTOR(n*k1+k2 -1 DOWNTO 0);
  SIGNAL zzz: matrix_z;

BEGIN
  first_row: MR_multiplier_row GENERIC MAP(n => n, k1 => k1, k2 => k2)
  PORT MAP(x => x, u => u, b => y(k2-1 DOWNTO 0), d => v(k2-1 DOWNTO 0), z => zzz(0));
  z(k2-1 DOWNTO 0) <= zzz(0)(k2-1 DOWNTO 0);
  next_rows: FOR i IN 1 TO m-1 GENERATE
    another_row: MR_multiplier_row GENERIC MAP(n => n, k1 => k1, k2 => k2)
    PORT MAP(x => x, u => zzz(i-1)(n*k1+k2-1 DOWNTO k2), b => y(i*k2+k2-1 DOWNTO i*k2), 
      d => v(i*k2+k2-1 DOWNTO i*k2), z => zzz(i)); 
    z(i*k2+k2-1 DOWNTO i*k2) <= zzz(i)(k2-1 DOWNTO 0);
  END GENERATE;
  z(n*k1+m*k2 -1 DOWNTO m*k2) <= zzz(m-1)(n*k1+k2-1 DOWNTO k2);
END circuit;
