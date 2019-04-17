----------------------------------------------------------------------------
-- Booth2_sequential_multiplier.vhd
--
-- section 8.4.4  Booth sequential multiplier for integer numbers
--
-- Computes: z = x·y + u
-- x: n+1 bits
-- y: m+1 bits (m odd)
-- z: n+m+1 bits
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Booth2_sequential_multiplier IS
  GENERIC(n: NATURAL:= 64; m: NATURAL:= 65);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(m DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n+m+1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END Booth2_sequential_multiplier;

ARCHITECTURE circuit OF Booth2_sequential_multiplier IS
  CONSTANT k: NATURAL := (m-1)/2;
  SIGNAL acc1: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL acc0: STD_LOGIC_VECTOR(m+1 DOWNTO 0);
  SIGNAL second_operand, long_x, minus_x, two_x, minus_two_x, zero, product: STD_LOGIC_VECTOR(n+2 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SUBTYPE index IS NATURAL RANGE 0 TO k;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  SIGNAL yyy: STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
  long_x <= x(n)&(x(n)&x);
  minus_x <= NOT(long_x)+1;
  two_x <= x(n)&(x&'0');
  minus_two_x <= NOT(two_x)+1;
  zero <= (OTHERS => '0');  
  yyy <= acc0(2 DOWNTO 0);
  WITH yyy SELECT second_operand <= zero WHEN "000"|"111", long_x WHEN "001"|"010", two_x WHEN "011", 
    minus_two_x WHEN "100", minus_x WHEN OTHERS;  
  product <= acc1(n)&(acc1(n)&acc1) + second_operand;
  z <= acc1 & acc0(m+1 DOWNTO 1);

  parallel_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN acc1 <= u; 
      ELSIF update = '1' THEN acc1 <= product(n+2 DOWNTO 2);
      END IF;
    END IF;
  END PROCESS;

  shift_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN acc0 <= y&'0'; 
      ELSIF update = '1' THEN acc0 <= product(1 DOWNTO 0)&acc0(m+1 DOWNTO 2);
      END IF;
    END IF;
  END PROCESS;

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD (k+1);
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
        WHEN 3 => IF count = k THEN current_state <= 0; END IF;
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
