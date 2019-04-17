----------------------------------------------------------------------------
-- Exponential.vhd
--
-- section 10.5 Exponential
--
-- x = 0.x-1 x-2 ... x-n: fractional
-- y = 1.y-1 y-2 ... y-p: fractional
-- y = 2^x
-- m: internal operation accuracy
-- m >= p+log2(n)+2
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE package_exponential IS
  TYPE table IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
  CONSTANT powers: table := 
  (x"6a09e6", x"306fed", x"172b83", x"0b5586",
   x"059b0d", x"02c9a3", x"0163da", x"00b1af" );
END package_exponential;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.package_exponential.ALL;
ENTITY Exponential IS
  GENERIC(n: NATURAL:= 8; p: NATURAL:= 8; m: NATURAL:= 13);
PORT(
  x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  y: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
  done: OUT STD_LOGIC
);
END Exponential;

ARCHITECTURE circuit OF Exponential IS
  SIGNAL z, next_z: STD_LOGIC_VECTOR(m DOWNTO 0);
  SIGNAL int_x: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL product: STD_LOGIC_VECTOR(2*m+1 DOWNTO 0);
  SIGNAL a: STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  
  SUBTYPE index IS NATURAL RANGE 0 TO n-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN

  a <= powers(count)(23 DOWNTO 24 - m);
  product <= ('1'&a) * z;
  WITH int_x(n-1) SELECT next_z <= product(2*m DOWNTO m) WHEN '1', z WHEN OTHERS;
       
  register_z: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN z(m) <= '1'; z(m-1 DOWNTO 0) <= (OTHERS => '0');
      ELSIF update = '1' THEN z <= next_z; 
      END IF;  
    END IF;
  END PROCESS;
  y <= z(m DOWNTO m-p);

  shift_register_x: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN int_x <= x;
      ELSIF update = '1' THEN int_x <= int_x(n-2 DOWNTO 0)&'0'; 
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