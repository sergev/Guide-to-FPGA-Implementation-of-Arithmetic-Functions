----------------------------------------------------------------------------
-- long_operand_adder.vhd
--
-- section 7.6 long operand adder
-- s: digits groups size.
-- k: amount of s-digit groups
-- The number of bits of operands is: s*k
--
-- defines entities: k_bit_adder and base_2k_adder
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY long_operand_adder IS
  GENERIC(s: NATURAL:= 16; k: NATURAL:= 16);
PORT(
  x, y: IN STD_LOGIC_VECTOR(s*k-1 DOWNTO 0);
  c_in, clk, reset, start: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(s*k-1 DOWNTO 0);
  c_out, done: OUT STD_LOGIC
);
END long_operand_adder;

ARCHITECTURE circuit OF long_operand_adder IS
  SIGNAL adder_in1, adder_in2, adder_out : STD_LOGIC_VECTOR(s-1 DOWNTO 0);
  SIGNAL sum: STD_LOGIC_VECTOR(s DOWNTO 0);
  SIGNAL q, next_q, update, load: STD_LOGIC;
  SUBTYPE index IS NATURAL RANGE 0 TO k-1;
  SIGNAL sel: index;
--  SIGNAL enable: STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
BEGIN
  adder_in1 <= x(sel*s+s-1 DOWNTO sel*s);
  adder_in2 <= y(sel*s+s-1 DOWNTO sel*s);
  sum <= '0'&adder_in1 + adder_in2 + q;
  adder_out <= sum(s-1 DOWNTO 0);
  next_q <= sum(s);
--  a_decoder: FOR i IN 0 TO k-1 GENERATE
--    enable(i) <= '1' WHEN sel = i ELSE '0';
--  END GENERATE;
  registers: FOR i IN 0 TO k-1 GENERATE
    PROCESS(clk)
    BEGIN
      IF clk'EVENT AND clk = '1' THEN
        IF (update = '1') AND (sel = i) THEN 
          z(i*s+s-1 DOWNTO i*s) <= adder_out; 
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;
  flip_flop: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= c_in;
      ELSIF update = '1' THEN 
        q <= next_q; 
      END IF;
    END IF;
  END PROCESS;
  c_out <= q;
  a_counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN sel <= 0;
      ELSIF update = '1' THEN 
        sel <= (sel+1) MOD k;
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
        WHEN 3 => IF sel = k-1 THEN current_state <= 0; END IF;
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