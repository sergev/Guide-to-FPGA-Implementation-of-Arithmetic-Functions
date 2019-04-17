----------------------------------------------------------------------------
-- Logarithm.vhd
--
-- section 10.4 Logarithm
--
-- x = 1.x-1 x-2 ... x-n: fractional (n bits, hidden '1')
-- y = 0.y-1 y-2 ... y-p: fractional (p bits, hidden '0')
-- 2^y = x
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Logarithm IS
  GENERIC(n: NATURAL:= 32; p: NATURAL:= 36);
PORT(
  x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  log: OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END Logarithm;

ARCHITECTURE circuit OF Logarithm IS
  SIGNAL z, next_z: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL square: STD_LOGIC_VECTOR(2*n+1 DOWNTO 0);
  SIGNAL y: STD_LOGIC_VECTOR(p-1 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  
  SUBTYPE index IS NATURAL RANGE 0 TO p-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN

  square <= z*z;
  WITH square(2*n+1) SELECT next_z <= square(2*n+1 DOWNTO n+1) WHEN '1', square(2*n DOWNTO n) WHEN OTHERS;
  
  register_z: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN z <= '1' & x;
      ELSIF update = '1' THEN z <= next_z; 
      END IF;  
    END IF;
  END PROCESS;

  shift_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN y <= (OTHERS => '0');
      ELSIF update = '1' THEN y <= y(p-2 DOWNTO 0)&square(2*n+1); 
      END IF;  
    END IF;
  END PROCESS;
  
  log <= y;
  
  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD p;
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
        WHEN 3 => IF count = p-1 THEN current_state <= 0; END IF;
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