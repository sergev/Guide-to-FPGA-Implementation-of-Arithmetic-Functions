----------------------------------------------------------------------------
-- non_restoring.vhd
--
-- section 9.2.1 non-restoring division
--
-- x = xn xn-1 ... x0: integer in 2's complement form
-- y = yn-1 yn-2 ... y0: natural
-- condition: -y <= x < y
-- quotient q =  q0. q1 ... qp: fractional in 2's complement form
-- remainder r = rn rn-1 ... r0: integer in 2's complement form
-- x = (q0.q1 q2 ... qp)·y + (r/y)·2-p with -y <= r < yq
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY non_restoring IS
  GENERIC(n: NATURAL:= 16; p: NATURAL:= 16);
PORT(
  x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(0 TO p);
  remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
  done: OUT STD_LOGIC
);
END non_restoring;

ARCHITECTURE circuit OF non_restoring IS
  SIGNAL r, next_r, long_y, two_r: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SIGNAL q: STD_LOGIC_VECTOR(0 TO p-1);
  
  SUBTYPE index IS NATURAL RANGE 0 TO p-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN
  long_y <= '0'&y;
  two_r <= r(n-1 DOWNTO 0)&'0';
  WITH r(n) SELECT next_r <= two_r + long_y WHEN '1', two_r - long_y WHEN OTHERS;

  remainder_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r <= x;
      ELSIF update = '1' THEN r <= next_r;
      END IF;  
    END IF;
  END PROCESS;

  remainder <= r;

  quotient_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= (others => '0');
      ELSIF update = '1' THEN q <= q(1 TO p-1)&NOT(r(n));
      END IF;  
    END IF;
  END PROCESS;

  quotient <= NOT(q(0)) & q(1 TO p-1)&'1';

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
