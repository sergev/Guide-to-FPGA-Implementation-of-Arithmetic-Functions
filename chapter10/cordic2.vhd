----------------------------------------------------------------------------
-- cordic2.vhd
--
-- section 10.6 Trigonometric function (Cordic)
--
-- z = x0.x-1 x-2 ... x-n: radians, 2'complement
-- sin z, cos z: 2's complement, with p fractional bits
-- m: internal operation accuracy
-- n: number of iterations
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE package_cordic IS
  TYPE table IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
  CONSTANT angles: table := 
  (x"c90fdaa2", x"76b19c15", x"3eb6ebf2", x"1fd5ba9a",
   x"0ffaaddb", x"07ff556e", x"03ffeaab", x"01fffd55",
   x"00ffffaa", x"007ffff5", x"003ffffe", x"001fffff",
   x"000fffff", x"0007ffff", x"0003ffff", x"0001ffff" );
  CONSTANT x_0: STD_LOGIC_VECTOR(31 DOWNTO 0) := x"9b74eda8";
END package_cordic;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY comb_shifter IS
  GENERIC(m, logm: NATURAL);
PORT(
  a: IN STD_LOGIC_VECTOR(m DOWNTO 0);
  shift: IN NATURAL;
  b: OUT STD_LOGIC_VECTOR(m DOWNTO 0)
 );
END comb_shifter;

ARCHITECTURE circuit OF comb_shifter IS
  TYPE vectors IS ARRAY (0 TO logm-1) OF STD_LOGIC_VECTOR(m DOWNTO 0);
  SIGNAL c, d: vectors;
  SIGNAL k: STD_LOGIC_VECTOR(logm-1 DOWNTO 0);
BEGIN
  k <= CONV_STD_LOGIC_VECTOR(shift, logm);
  WITH k(0) SELECT d(0) <= a WHEN '0', a(m)&a(m DOWNTO 1) WHEN OTHERS;
  main_iteration: FOR j IN 1 TO logm-1 GENERATE
    c(j-1)(m DOWNTO m - 2**j + 1) <= (OTHERS => d(j-1)(m)); c(j-1)(m - 2**j DOWNTO 0) <= d(j-1)(m DOWNTO 2**j);
    WITH k(j) SELECT d(j) <= d(j-1) WHEN '0', c(j-1) WHEN OTHERS;
  END GENERATE;
  b <= d(logm-1);
END circuit; 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.package_cordic.ALL;
ENTITY cordic2 IS
  GENERIC(p: NATURAL:=8; m: NATURAL:=16; n: NATURAL:=16; logn: NATURAL:=4);
PORT(
  z: IN STD_LOGIC_VECTOR(p DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  sin, cos: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
  done: OUT STD_LOGIC
);
END cordic2;

ARCHITECTURE circuit OF cordic2 IS
  COMPONENT comb_shifter IS
    GENERIC(m, logm: NATURAL);
  PORT(
    a: IN STD_LOGIC_VECTOR(m DOWNTO 0);
    shift: IN NATURAL;
    b: OUT STD_LOGIC_VECTOR(m DOWNTO 0)
   );
   END COMPONENT;
  SIGNAL x, y, next_x, next_y, d, next_d: STD_LOGIC_VECTOR(m DOWNTO 0);
  SIGNAL a: STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  SIGNAL shifted_x, shifted_y: STD_LOGIC_VECTOR(m DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  
  SUBTYPE index IS NATURAL RANGE 0 TO n-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN

  a <= angles(count)(31 DOWNTO 32 - m);
  WITH d(m) SELECT next_d <= d + ('0'&a) WHEN '1', d - ('0'&a) WHEN OTHERS;
  
  shifter_x: comb_shifter GENERIC MAP(m => m, logm => logn)
  PORT MAP(a => x, shift => count, b => shifted_x);
  shifter_y: comb_shifter GENERIC MAP(m => m, logm => logn)
  PORT MAP(a => y, shift => count, b => shifted_y);

  WITH d(m) SELECT next_x <= x + shifted_y WHEN '1', x - shifted_y WHEN OTHERS;
  WITH d(m) SELECT next_y <= y - shifted_x WHEN '1', y + shifted_x WHEN OTHERS;

      
  register_d: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN d(m DOWNTO m-p) <= z; d(m-p-1 DOWNTO 0) <= (OTHERS => '0');
      ELSIF update = '1' THEN d <= next_d; 
      END IF;  
    END IF;
  END PROCESS;

  register_x: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN x(m) <= '0'; x(m-1 DOWNTO 0) <= x_0(31 DOWNTO 32-m);
      ELSIF update = '1' THEN x <= next_x; 
      END IF;  
    END IF;
  END PROCESS;
  cos <= x(m DOWNTO m-p);
   
  register_y: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN y <= (OTHERS => '0');
      ELSIF update = '1' THEN y <= next_y; 
      END IF;  
    END IF;
  END PROCESS;
  sin <= y(m DOWNTO m-p);

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD n;
      END IF;
    END IF;
  END PROCESS;

  next_state: PROCESS(clk)
  BEGIN
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
        WHEN 2 => current_state <= 3;
        WHEN 3 => IF count = n-1 THEN current_state <= 0; END IF;
      END CASE;
    END IF;
  END PROCESS;

  output_function: PROCESS(clk, current_state)
  BEGIN
    CASE current_state IS
      WHEN 0 TO 1 => load <= '0'; update <= '0'; done <= '1';
      WHEN 2 => load <= '1'; update <= '0'; done <= '0';
      WHEN 3 => load <= '0'; update <= '1'; done <= '0';
    END CASE;
  END PROCESS;
   
END circuit;
