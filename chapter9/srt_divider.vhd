----------------------------------------------------------------------------
-- srt_divider.vhd
--
-- section 9.2.3 SRT division
--
-- x = xn xn-1 ... x0: integer in 2's complement form
-- y = 1 yn-2 ... y0: normalized natural
-- condition: -y <= x < y
-- quotient q =  q0. q1 ... qp: fractional in 2's complement form
-- remainder r = rn rn-1 ... r0: integer in 2's complement form
-- x = (q0.q1 q2 ... qp)·y + (r/y)·2-p with -y <= r < y
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY srt_divider IS
  GENERIC(n: NATURAL:= 24; p: NATURAL:= 27);
PORT(
  x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(0 TO p);
  remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
  done: OUT STD_LOGIC
);
END srt_divider;

ARCHITECTURE circuit OF srt_divider IS
  SIGNAL r, next_r, long_y, two_r: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL plus1, minus1, load, update: STD_LOGIC;
  SIGNAL operation: STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL q, qm: STD_LOGIC_VECTOR(0 TO p);
  
  SUBTYPE index IS NATURAL RANGE 0 TO p-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN
  long_y <= '0'&y;
  two_r <= r(n-1 DOWNTO 0)&'0';
  plus1 <= NOT(r(n)) AND (r(n-1) OR r(n-2));
  minus1 <= r(n) AND (NOT(r(n-1)) OR NOT(r(n-2)));
  operation <= plus1 & minus1;
  WITH operation SELECT next_r <= two_r - long_y WHEN "10", two_r + long_y WHEN "01", two_r WHEN OTHERS;

  remainder_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r <= x;
      ELSIF update = '1' THEN r <= next_r;
      END IF;  
    END IF;
  END PROCESS;
  remainder <= r;

  q_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= (OTHERS => '0');
      ELSIF update = '1' THEN 
      
        IF plus1 = '1' THEN q(0 TO p-1) <= q(1 TO p); q(p) <= '1';
        ELSIF minus1 = '1' THEN q(0 TO p-1) <= qm(1 TO p); q(p) <= '1';
        ELSE q(0 TO p-1) <= q(1 TO p); q(p) <= '0'; 
        END IF;
         
      END IF;  
    END IF;
  END PROCESS;

  qm_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN qm(0 TO p-1) <= (OTHERS => '0'); qm(p) <= '1';
      ELSIF update = '1' THEN 
      
        IF plus1 = '1' THEN qm(0 TO p-1) <= q(1 TO p); qm(p) <= '0';
        ELSIF minus1 = '1' THEN qm(0 TO p-1) <= qm(1 TO p); qm(p) <= '0';
        ELSE qm(0 TO p-1) <= qm(1 TO p); qm(p) <= '1'; 
        END IF;
            
      END IF;  
    END IF;
  END PROCESS;

  quotient <= q;

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
