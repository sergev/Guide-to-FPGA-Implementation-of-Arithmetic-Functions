----------------------------------------------------------------------------
-- restoringDS.vhd
--
-- Digit Serial version of restoring division algorithm
-- D=2, generates 2 bits per clk cycle.
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
ENTITY restoringDS IS
  GENERIC(n: NATURAL:=8; p: NATURAL:= 6);
PORT(
  x, y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(1 TO p);
  remainder: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END restoringDS;

ARCHITECTURE circuit OF restoringDS IS
  SIGNAL r, next_r: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL long_y, two_y, three_y, four_r, dif1, dif2, dif3: STD_LOGIC_VECTOR(n+2 DOWNTO 0);
  SIGNAL signs: STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL load, update, q_even, q_odd: STD_LOGIC;
  SIGNAL q: STD_LOGIC_VECTOR(1 TO p);
  
  SUBTYPE index IS NATURAL RANGE 0 TO p/2-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN
  long_y <= "000"&y;
  two_y <= "00"&y&'0';
  three_y <= long_y + two_y;
  four_r <= '0'&r&"00";
  dif1 <= four_r - long_y;
  dif2 <= four_r - two_y;
  dif3 <= four_r - three_y;
  signs <= dif1(n+2)&dif2(n+2)&dif3(n+2);
  WITH signs SELECT next_r <= four_r(n-1 DOWNTO 0) WHEN "111", dif1(n-1 DOWNTO 0) WHEN "011", 
    dif2(n-1 DOWNTO 0) WHEN "001", dif3(n-1 DOWNTO 0) WHEN OTHERS;

--  WITH signs SELECT q_even <= '0' WHEN "111", '0' WHEN "011", '1' WHEN "001", '1' WHEN OTHERS;
--  WITH signs SELECT q_odd <= '0' WHEN "111", '1' WHEN "011", '0' WHEN "001", '1' WHEN OTHERS;

  digits: PROCESS(signs)
  BEGIN
    IF signs(2) = '1' THEN q_even <= '0'; q_odd <= '0';
    ELSIF signs(1) = '1' THEN q_even <= '0'; q_odd <= '1';
    ELSIF signs(0) = '1' THEN q_even <= '1'; q_odd <= '0';
    ELSE q_even <= '1'; q_odd <= '1';
    END IF;
  END PROCESS;
  
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
      IF load = '1' THEN 
        q <= (OTHERS => '0'); 
      ELSIF update = '1' THEN 
        q <= q(3 TO p)&q_even&q_odd; 
      END IF;  
    END IF;
  END PROCESS;
  quotient <= q;
  
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
