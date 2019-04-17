----------------------------------------------------------------------------
-- multioperand_adder.vhd
--
-- section 7.7 multioperand adder
-- sequential implementation
-- m: number of operands of n bits
-- n: size of each operand
-- x = x0 & x1 & ... & xm-1
-- Z = x0 + x1 + ... + xm-1 mod 2^n
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY multioperand_adder IS
  GENERIC(n: NATURAL:= 16; m: NATURAL:= 16);
PORT(
  x: IN STD_LOGIC_VECTOR(n*m-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END multioperand_adder;

ARCHITECTURE circuit OF multioperand_adder IS
  SIGNAL adder_in1, accumulator, adder_out : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SUBTYPE index IS NATURAL RANGE 0 TO m-1;
  SIGNAL sel: index;
  SIGNAL load, en_acc: STD_LOGIC;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
BEGIN
  adder_in1 <= x(sel*n+n-1 DOWNTO sel*n);
  adder_out <= adder_in1 + accumulator;
  z <= accumulator;
  accumulator_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN accumulator <= (OTHERS => '0');
      ELSIF en_acc = '1' THEN accumulator <= adder_out; END IF;
    END IF;
  END PROCESS;
  a_counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN sel <= 0;
      ELSIF en_acc = '1' THEN sel <= (sel+1) MOD m;
      END IF;
    END IF;
  END PROCESS;
  next_state: PROCESS(clk, reset)
  BEGIN
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
        WHEN 2 => current_state <= 3;
        WHEN 3 => IF sel = m-1 THEN current_state <= 0; END IF;
      END CASE;
    END IF;
  END PROCESS;

  output_function: PROCESS(clk, current_state)
  BEGIN
    CASE current_state IS
      WHEN 0 TO 1 => load <= '0'; en_acc <= '0'; done <= '1';
      WHEN 2 => load <= '1'; en_acc <= '0'; done <= '0';
      WHEN 3 => load <= '0'; en_acc <= '1'; done <= '0';
    END CASE;
  END PROCESS;
END circuit;