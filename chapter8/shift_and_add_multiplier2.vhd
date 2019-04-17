----------------------------------------------------------------------------
-- shift_and_add_multiplier2.vhd
--
-- section 8.3.1 shift and add sequential multiplier, second version
--
-- Computes: z = x·y + u
-- x, u: n bits
-- y: m bits
-- z: n+m bits
-- v = 0, then the same shitf-reg for y and less significant bits of z 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY shift_and_add_multiplier2 IS
  GENERIC(n: NATURAL:= 64; m: NATURAL:= 64);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n+m-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END shift_and_add_multiplier2;

ARCHITECTURE circuit OF shift_and_add_multiplier2 IS
  SIGNAL acc_1: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL acc_0: STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  SIGNAL product, carries: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SUBTYPE index IS NATURAL RANGE 0 TO m-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;

BEGIN
  carries(0) <= '0';  
  main_iteration: FOR i IN 0 TO n-1 GENERATE
    product(i) <= (x(i) AND acc_0(0)) XOR acc_1(i) XOR carries(i);
    carries(i+1) <= (x(i) AND acc_0(0) AND acc_1(i)) OR (x(i) AND acc_0(0) AND carries(i)) OR (acc_1(i) AND carries(i));
  END GENERATE;
  product(n) <= carries(n);  
  z <= acc_1 & acc_0;
  parallel_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN acc_1 <= u; 
      ELSIF update = '1' THEN acc_1 <= product(n DOWNTO 1);
      END IF;
    END IF;
  END PROCESS;

  shift_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN acc_0 <= y; 
      ELSIF update = '1' THEN acc_0 <= product(0)&acc_0(m-1 DOWNTO 1);
      END IF;
    END IF;
  END PROCESS;

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD m;
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
        WHEN 3 => IF count = m-1 THEN current_state <= 0; END IF;
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
