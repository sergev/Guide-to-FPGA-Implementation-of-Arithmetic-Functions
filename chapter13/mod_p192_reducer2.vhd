----------------------------------------------------------------------------
-- mod p192 reducer (mod_p192_reducer.vhd)
--
-- section 13.1.2 multiplication mod m
--
-- reduce a 384 bits number modulo m = (2**192-2**64-1)
--
----------------------------------------------------------------------------
LIBRARY IEEE; USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY mod_p192_reducer2 IS
PORT(
  x: IN STD_LOGIC_VECTOR(383 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(191 DOWNTO 0)
);
END mod_p192_reducer2;

ARCHITECTURE circuit OF mod_p192_reducer2 IS

  SIGNAL x1: STD_LOGIC_VECTOR(191 DOWNTO 0);
  SIGNAL x2: STD_LOGIC_VECTOR(191 DOWNTO 0);
  SIGNAL x3: STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL x4: STD_LOGIC_VECTOR(191 DOWNTO 0);
  SIGNAL s1: STD_LOGIC_VECTOR(192 DOWNTO 0);
  SIGNAL s2: STD_LOGIC_VECTOR(192 DOWNTO 0);
  SIGNAL s: STD_LOGIC_VECTOR(193 DOWNTO 0);
  CONSTANT minus_m: STD_LOGIC_VECTOR(192 DOWNTO 0):= 
    (0 => '1', 64 => '1', 192 => '1', OTHERS => '0');
  CONSTANT minus_2m: STD_LOGIC_VECTOR(193 DOWNTO 0):= 
    (1 => '1', 65 => '1', 193 => '1',OTHERS => '0');
  CONSTANT minus_3m: STD_LOGIC_VECTOR(192 DOWNTO 0):= 
    (0 => '1', 1 => '1', 64 => '1', 65 => '1', 192 => '1',OTHERS => '0');
  CONSTANT zero: STD_LOGIC_VECTOR(63 DOWNTO 0):= (OTHERS => '0');
  SIGNAL z1: STD_LOGIC_VECTOR(194 DOWNTO 0);
  SIGNAL z2: STD_LOGIC_VECTOR(193 DOWNTO 0);
  SIGNAL z3: STD_LOGIC_VECTOR(192 DOWNTO 0);

BEGIN

  x1 <= x(383 DOWNTO 320) & x(383 DOWNTO 320) & x(383 DOWNTO 320);
  x2 <= x(319 DOWNTO 256) & x(319 DOWNTO 256) & zero;
  x3 <= x(255 DOWNTO 192) & x(255 DOWNTO 192);
  x4 <= x(191 DOWNTO 0);

  s1 <= ('0'&x1) + x4;
  s2(192 DOWNTO 64)  <= ('0'&x2(191 DOWNTO 64)) + x3(127 DOWNTO 64);
  s2(63 DOWNTO 0) <= x3(63 DOWNTO 0);
  
  s <= ('0'&s1) + s2;
  
  z1 <= ('0'&s) + ("11"&minus_m);
  z2 <= s + minus_2m;  
  z3 <= s(192 DOWNTO 0) + minus_3m;

  PROCESS(z1, z2, z3, s)
  BEGIN
    IF z1(194) = '1' THEN z <= s(191 DOWNTO 0);
    ELSIF z2(193) = '1' THEN z <= z1(191 DOWNTO 0); 
    ELSIF z3(192) = '1' THEN z <= z2(191 DOWNTO 0); 
    ELSE z <= z3(191 DOWNTO 0); 
    END IF;
  END PROCESS;
END circuit;
