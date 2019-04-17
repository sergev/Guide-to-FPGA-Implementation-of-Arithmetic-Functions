----------------------------------------------------------------------------
-- Exponential2.vhd
--
-- section 10.5 Exponential
--
-- x = 0.x-1 x-2 ... x-n: fractional
-- y = 1.y-1 y-2 ... y-p: fractional
-- y = 2^x
-- m: internal operation accuracy
-- power = 2^(2^-n) with k fractional bits
--
-- m >= p+log2(n)+2
-- k >= n+p+log2(n)+2
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Exponential2 IS
  GENERIC(n: NATURAL:= 8; p: NATURAL:= 8; 
          m: NATURAL:= 13; k: NATURAL:= 21;
          power: STD_LOGIC_VECTOR := "1000000001011000110101");
PORT(
  x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  y: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
  done: OUT STD_LOGIC
);
END Exponential2;

ARCHITECTURE circuit OF Exponential2 IS
  SIGNAL a, next_a: STD_LOGIC_VECTOR(k DOWNTO 0); 
  SIGNAL square_a: STD_LOGIC_VECTOR(2*k+1 DOWNTO 0);
  SIGNAL b: STD_LOGIC_VECTOR(m DOWNTO 0);
  SIGNAL z, next_z: STD_LOGIC_VECTOR(m DOWNTO 0);
  SIGNAL int_x: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL product: STD_LOGIC_VECTOR(2*m+1 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  
  SUBTYPE index IS NATURAL RANGE 0 TO n-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN

  square_a <= a*a;
  next_a <= square_a(2*k DOWNTO k);
  b <= a(k DOWNTO k-m);
  product <= b * z;
  WITH int_x(0) SELECT next_z <= product(2*m DOWNTO m) WHEN '1', z WHEN OTHERS;
       
  register_z: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN z(m) <= '1'; z(m-1 DOWNTO 0) <= (OTHERS => '0');
      ELSIF update = '1' THEN z <= next_z; 
      END IF;  
    END IF;
  END PROCESS;
  y <= z(m DOWNTO m-p);

  register_a: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN a <= power;
      ELSIF update = '1' THEN a <= next_a; 
      END IF;  
    END IF;
  END PROCESS;

  shift_register_x: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN int_x <= x;
      ELSIF update = '1' THEN int_x <= '0'&int_x(n-1 DOWNTO 1); 
      END IF;  
    END IF;
  END PROCESS;

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