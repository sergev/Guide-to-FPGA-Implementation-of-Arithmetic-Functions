----------------------------------------------------------------------------
-- unrolled_divider.vhd
--
-- Partially unrolled restoring divider 
-- S=2, produces two bits per clk cycle.
-- section 3.2 Loop-unrolling and digit-serial processing
--
-- n = 2m, p = 2t
-- x = xn-1 xn-2 ... x0: natural
-- y = yn-1 yn-2 ... y0: natural
-- condition: x < y
-- quotient q =  0.q1 ... qp: non-negative fractional
-- remainder r = rn-1 rn-2 ... r0: natural
-- x = (0.q1 q2 ... qp)·y + (r/y)·2-p with r < y
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY unrolled_divider IS
  GENERIC(n: NATURAL:=8; p: NATURAL:= 6);
PORT(
  x, y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(1 TO p);
  remainder: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END unrolled_divider;

ARCHITECTURE circuit OF unrolled_divider IS
  SIGNAL r_even, r_odd, next_r: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL long_y, two_r_even, two_r_odd, dif_even, dif_odd: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SIGNAL q_even, q_odd: STD_LOGIC_VECTOR(1 TO p/2);
  
  SUBTYPE index IS NATURAL RANGE 0 TO p/2-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN
  long_y <= '0'&y;
  two_r_even <= r_even&'0';
  dif_even <= two_r_even - long_y;
  WITH dif_even(n) SELECT r_odd <= dif_even(n-1 DOWNTO 0) WHEN '0', two_r_even(n-1 DOWNTO 0) WHEN OTHERS;
  two_r_odd <= r_odd&'0';
  dif_odd <= two_r_odd - long_y;
  WITH dif_odd(n) SELECT next_r <= dif_odd(n-1 DOWNTO 0) WHEN '0', two_r_odd(n-1 DOWNTO 0) WHEN OTHERS;
  
  remainder_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r_even <= x;
      ELSIF update = '1' THEN r_even <= next_r;
      END IF;  
    END IF;
  END PROCESS;
  remainder <= r_even;

  quotient_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN 
        q_even <= (OTHERS => '0'); 
        q_odd <= (OTHERS => '0');
      ELSIF update = '1' THEN 
        q_even <= q_even(2 TO p/2)&NOT(dif_even(n)); 
        q_odd <= q_odd(2 TO p/2)&NOT(dif_odd(n));
      END IF;  
    END IF;
  END PROCESS;

  outputs: FOR i IN 1 TO p/2 GENERATE 
    quotient(2*i-1) <= q_even(i);
    quotient(2*i) <= q_odd(i);
  END GENERATE;

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD (p/2);
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
        WHEN 3 => IF count = p/2-1 THEN current_state <= 0; END IF;
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
