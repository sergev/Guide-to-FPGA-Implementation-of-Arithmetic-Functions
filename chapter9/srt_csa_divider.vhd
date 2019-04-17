----------------------------------------------------------------------------
-- srt_csa_divider.vhd
--
-- section 9.2.4 SRT divider with Carry Save Adders
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
ENTITY srt_csa_divider IS
  GENERIC(n: NATURAL:= 24; p: NATURAL:= 27);
PORT(
  x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(0 TO p);
  remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
  done: OUT STD_LOGIC
);
END srt_csa_divider;

ARCHITECTURE circuit OF srt_csa_divider IS
  SIGNAL c, next_c, s, next_s, long_y, minus_y, two_c, two_s, third_operand: STD_LOGIC_VECTOR(n+1 DOWNTO 0);
  CONSTANT zero: STD_LOGIC_VECTOR(n+1 DOWNTO 0) := (OTHERS => '0'); 
  SIGNAL plus1, minus1, load, update: STD_LOGIC;
  SIGNAL v: STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL operation: STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL q, qm: STD_LOGIC_VECTOR(0 TO p);
  
  SUBTYPE index IS NATURAL RANGE 0 TO p-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN
  long_y <= "00"&y;
  minus_y <= zero - long_y;
  two_c <= c(n DOWNTO 0)&'0';
  two_s <= s(n DOWNTO 0)&'0';
  v <= c(n+1 DOWNTO n-2) + s(n+1 DOWNTO n-2);
  plus1 <= NOT(v(3));
  minus1 <= v(3) AND (NOT(v(2)) OR NOT(v(1)) OR NOT(v(0)));
  operation <= plus1 & minus1;
  WITH operation SELECT third_operand <= minus_y WHEN "10", long_y WHEN "01", zero WHEN OTHERS;
  
  next_c(0) <= '0';
  carry_save_adder: FOR i IN 0 TO n GENERATE
    next_s(i) <= two_c(i) XOR two_s(i) XOR third_operand(i);
    next_c(i+1) <= (two_c(i) AND two_s(i)) OR (two_c(i) AND third_operand(i)) OR (two_s(i) AND third_operand(i));
  END GENERATE;
  next_s(n+1) <= two_c(n+1) XOR two_s(n+1) XOR third_operand(n+1);
   
  s_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN s <= x(n) & x;
      ELSIF update = '1' THEN s <= next_s;
      END IF;  
    END IF;
  END PROCESS;

  c_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN c <= (OTHERS => '0');
      ELSIF update = '1' THEN c <= next_c;
      END IF;  
    END IF;
  END PROCESS;

  remainder <= c(n DOWNTO 0) + s(n DOWNTO 0);

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
