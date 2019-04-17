----------------------------------------------------------------------------
-- example4_1.vhd
--
-- Computes z= (x^2 + y^2)^.5
-- Section 4.2 hierarchical control unit.
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY example4_1 IS
  GENERIC(n: NATURAL := 4);
PORT (
  x, y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
  done: OUT STD_LOGIC
);
END example4_1;

ARCHITECTURE behavior OF example4_1 IS
  SIGNAL squaring_in: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL square, r, next_r : STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
  SIGNAL s, next_s, c, not_c, adder_in2, sum, two_r: STD_LOGIC_VECTOR(2*n DOWNTO 0);
  SIGNAL long_sum, adder_in1: STD_LOGIC_VECTOR(2*n+1 DOWNTO 0);  
  SIGNAL load, en_r, en_s, en_c, en_signb, sel_sq, sel_r, sel_s, sel_a1, cy_in, cy_out, signb, start_root, root_done: STD_LOGIC;
  SIGNAL sel_a2: STD_LOGIC_VECTOR(1 DOWNTO 0);
  TYPE states1 IS RANGE 0 TO 5;
  TYPE states2 IS RANGE 0 TO 4;
  SIGNAL current_state1: states1;
  SIGNAL current_state2: states2;
  CONSTANT zero: STD_LOGIC_VECTOR(2*n DOWNTO 0) := (OTHERS => '0');
  SIGNAL command, command1, command2: STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN

  WITH sel_sq SELECT squaring_in <= x WHEN '0', y WHEN OTHERS;
  square <= squaring_in * squaring_in;
  WITH sel_a1 SELECT adder_in1 <= "00"&r WHEN '0', '0'&s WHEN OTHERS;
  two_r <= r(2*n-1 DOWNTO 0)&'0';
  not_c <= NOT(c);
  WITH sel_a2 SELECT adder_in2 <= zero WHEN "00", two_r WHEN "01", not_c WHEN "10", s WHEN OTHERS;
  long_sum <= adder_in1 + adder_in2 + cy_in;
  sum <= long_sum(2*n DOWNTO 0);
  cy_out <= long_sum(2*n+1); 
  WITH sel_r SELECT next_r <= square WHEN '0', sum(2*n-1 DOWNTO 0) WHEN OTHERS;
  WITH sel_s SELECT next_s <= '0'&square WHEN '0', sum WHEN OTHERS;
  
  register_r: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN 
      IF LOAD = '1' THEN r <= (OTHERS => '0');
      ELSIF en_r = '1' THEN r <= next_r; 
      END IF;
    END IF;
  END PROCESS;
  z <= r(n DOWNTO 0);
  
  register_s: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN 
      IF LOAD = '1' THEN s <= CONV_STD_LOGIC_VECTOR(1,2*n+1);
      ELSIF en_s = '1' THEN s <= next_s; 
      END IF;
    END IF;
  END PROCESS;

  register_c: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN 
      IF en_c = '1' THEN c <= sum; 
      END IF;
    END IF;
  END PROCESS;

  flip_flop: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN 
      IF en_signb = '1' THEN signb <= cy_out; 
      END IF;
    END IF;
  END PROCESS;
  
  command_decoder: PROCESS(command)
  BEGIN
    CASE command IS
      WHEN "000" => sel_sq <= '0'; sel_a1 <= '0'; sel_a2 <= "00"; cy_in <= '0'; sel_r <= '0'; sel_s <= '0'; 
                  load <= '0'; en_r <= '0'; en_s <= '0'; en_c <= '0'; en_signb <= '0';
      WHEN "001" => sel_sq <= '0'; sel_a1 <= '0'; sel_a2 <= "00"; cy_in <= '0'; sel_r <= '0'; sel_s <= '0'; 
                  load <= '0'; en_r <= '1'; en_s <= '0'; en_c <= '0'; en_signb <= '0';
      WHEN "010" => sel_sq <= '1'; sel_a1 <= '0'; sel_a2 <= "00"; cy_in <= '0'; sel_r <= '0'; sel_s <= '0'; 
                  load <= '0'; en_r <= '0'; en_s <= '1'; en_c <= '0'; en_signb <= '0';
      WHEN "011" => sel_sq <= '0'; sel_a1 <= '0'; sel_a2 <= "11"; cy_in <= '0'; sel_r <= '0'; sel_s <= '0'; 
                  load <= '0'; en_r <= '0'; en_s <= '0'; en_c <= '1'; en_signb <= '0';
      WHEN "100" => sel_sq <= '0'; sel_a1 <= '0'; sel_a2 <= "00"; cy_in <= '0'; sel_r <= '0'; sel_s <= '0'; 
                  load <= '1'; en_r <= '0'; en_s <= '0'; en_c <= '0'; en_signb <= '0';
      WHEN "101" => sel_sq <= '0'; sel_a1 <= '0'; sel_a2 <= "00"; cy_in <= '1'; sel_r <= '1'; sel_s <= '0'; 
                  load <= '0'; en_r <= '1'; en_s <= '0'; en_c <= '0'; en_signb <= '0';
      WHEN "110" => sel_sq <= '0'; sel_a1 <= '1'; sel_a2 <= "01"; cy_in <= '1'; sel_r <= '0'; sel_s <= '1'; 
                  load <= '0'; en_r <= '0'; en_s <= '1'; en_c <= '0'; en_signb <= '0';
      WHEN OTHERS => sel_sq <= '0'; sel_a1 <= '1'; sel_a2 <= "10"; cy_in <= '1'; sel_r <= '0'; sel_s <= '0'; 
                  load <= '0'; en_r <= '0'; en_s <= '0'; en_c <= '0'; en_signb <= '1';
    END CASE;
  END PROCESS;

  control_unit1: PROCESS(clk, reset, current_state1, start, root_done)
  BEGIN
    CASE current_state1 IS
      WHEN 0 => command1 <= "000"; start_root <= '0'; done <= '1';
      WHEN 1 => IF start = '0' THEN command1 <= "000"; ELSE command1 <= "001"; END IF; start_root <= '0'; done <= '1';
      WHEN 2 => command1 <= "010";  start_root <= '0'; done <= '0';
      WHEN 3 => command1 <= "011";  start_root <= '0'; done <= '0';
      WHEN 4 => command1 <= "000"; start_root <= '1'; done <= '0';
      WHEN 5 => command1 <= "000"; start_root <= '0'; done <= '0';
    END CASE;
    IF reset = '1' THEN current_state1 <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state1 IS
        WHEN 0 => IF start = '0' THEN current_state1 <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state1 <= 2; END IF;      
        WHEN 2 => current_state1 <= 3;
        WHEN 3 => current_state1 <= 4;
        WHEN 4 => current_state1 <= 5;
        WHEN 5 => IF root_done = '1' THEN current_state1 <= 0; END IF;
      END CASE;
    END IF;
  END PROCESS;
    
  control_unit2: PROCESS(clk, reset, current_state2, start_root, signb)
  BEGIN
    CASE current_state2 IS
      WHEN 0 => IF start_root = '0' THEN command2 <= "000"; ELSE command2 <= "100"; END IF; root_done <= '0';
      WHEN 1 => command2 <= "101"; root_done <= '0';
      WHEN 2 => command2 <= "110"; root_done <= '0';
      WHEN 3 => command2 <= "111"; root_done <= '0'; 
      WHEN 4 => IF signb = '0' THEN  command2 <= "101"; root_done <= '0'; ELSE command2 <= "000"; root_done <= '1'; END IF;
    END CASE;
    IF reset = '1' THEN current_state2 <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state2 IS
        WHEN 0 => IF start_root = '1' THEN current_state2 <= 1; END IF;
        WHEN 1 => current_state2 <= 2;      
        WHEN 2 => current_state2 <= 3;
        WHEN 3 => current_state2 <= 4;
        WHEN 4 => IF signb = '0' THEN current_state2 <= 2; ELSE current_state2 <= 0; END IF;
      END CASE;
    END IF;
  END PROCESS;

  command <= command1 OR command2;

END behavior;