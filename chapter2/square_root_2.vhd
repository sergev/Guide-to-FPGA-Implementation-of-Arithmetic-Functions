------------------------------------------------------------------
-- square_root_2.vhd
-- Introductoy example 2.1, algorithm 2.2. Square root, version 2
--
-------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY square_root_2 IS
  GENERIC(n: NATURAL := 8);
PORT (
  x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  r: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END square_root_2;

ARCHITECTURE behavior OF square_root_2 IS
  SIGNAL operand_1, operand_2, s, shifted_r, complemented_x: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL result: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL greater: STD_LOGIC;
  SIGNAL ce_r, ce_s, ce_greater, load: STD_LOGIC;
  SIGNAL operation: STD_LOGIC_VECTOR(1 DOWNTO 0);
  TYPE states IS RANGE 0 TO 4;
  SIGNAL current_state: states;
  CONSTANT zero: STD_LOGIC_VECTOR(n-1 DOWNTO 0) := (OTHERS => '0');
BEGIN

  shifted_r <= r(n-2 DOWNTO 0)&'0';
  complemented_x <= NOT(x);
  WITH operation SELECT operand_1 <= r WHEN "00", s WHEN OTHERS;
  WITH operation SELECT operand_2 <= zero WHEN "00", shifted_r WHEN "01", complemented_x WHEN OTHERS;
  result <= '0'&operand_1 + operand_2 + NOT(operation(1));
  
  register_r: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN 
      IF LOAD = '1' THEN r <= (OTHERS => '0');
      ELSIF ce_r = '1' THEN r <= result(n-1 DOWNTO 0); 
      END IF;
    END IF;
  END PROCESS;

  register_s: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN 
      IF LOAD = '1' THEN s <= CONV_STD_LOGIC_VECTOR(1,8);
      ELSIF ce_s = '1' THEN s <= result(n-1 DOWNTO 0); 
      END IF;
    END IF;
  END PROCESS;

  ff_greater: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN 
      IF LOAD = '1' THEN greater <= '0';
      ELSIF ce_greater = '1' THEN greater <= result(n); 
      END IF;
    END IF;
  END PROCESS;

  control_unit_output: PROCESS(current_state, start, greater)
  BEGIN
    CASE current_state IS
      WHEN 0 => ce_r <= '0'; ce_s <= '0'; ce_greater <= '0'; load <= '0'; operation <= "00"; done <= '1';
      WHEN 1 => ce_r <= '0'; ce_s <= '0'; ce_greater <= '0'; operation <= "00"; 
                IF start = '1' THEN load <= '1'; done <= '0'; ELSE load <= '0'; done <= '1'; END IF;
      WHEN 2 => IF greater = '0' THEN ce_r <= '1'; ELSE ce_r <= '0'; END IF;
                ce_s <= '0'; ce_greater <= '0'; load <= '0'; operation <= "00"; done <= '0';
      WHEN 3 => ce_r <= '0'; ce_s <= '1'; ce_greater <= '0'; load <= '0'; operation <= "01"; done <= '0';
      WHEN 4 => ce_r <= '0'; ce_s <= '0'; ce_greater <= '1'; load <= '0'; operation <= "10"; done <= '0';
    END CASE;
  END PROCESS;

  control_unit_next_state: PROCESS(clk, reset)
  BEGIN
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'event AND clk= '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
        WHEN 2 => IF greater = '1' THEN current_state <= 0; ELSE current_state <= 3; END IF;
        WHEN 3 => current_state <= 4;
        WHEN 4 => current_state <= 2;
      END CASE;
    END IF;
  END PROCESS;

END behavior;
