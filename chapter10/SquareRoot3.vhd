----------------------------------------------------------------------------
-- SquareRoot3.vhd
--
-- section 10.3 Square Rooters. Non-restoring Algorithm (10.3.2)
--
-- x = x2n-1 x2n-2 ... x0: natural (2.n bits)
-- root = qn-1 qn-2 ... q0: natural (n bits)
-- remainder = rn rn-1 ... r0: natural (n bits)
-- x = q^2 + r, r <= 2q if r is positive
--
-- In this case the remainder is correct if it is non-negative. 
-- In fact, the remainder is equal to (r(n-i)•4^i)•2^n
-- where rn-i is the lastnon-negative remainder
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY SquareRoot3 IS
  GENERIC(n: NATURAL:= 8);
PORT(
  x: IN STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  root: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
  done: OUT STD_LOGIC
);
END SquareRoot3;

ARCHITECTURE circuit OF SquareRoot3 IS
  SIGNAL r, next_r: STD_LOGIC_VECTOR(3*n+1 DOWNTO 0);
  SIGNAL q: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL sumdif: STD_LOGIC_VECTOR(n+1 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  
  SUBTYPE index IS NATURAL RANGE 0 TO n-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
  SIGNAL left_operand, right_operand: STD_LOGIC_VECTOR(n+1 DOWNTO 0);
  
BEGIN

  left_operand <= r(3*n-1 DOWNTO 2*n-2);
  right_operand <= q&r(3*n+1)&'1';

  WITH r(3*n+1) SELECT sumdif <= left_operand - right_operand WHEN '0', left_operand + right_operand WHEN OTHERS;
  next_r <= sumdif&r(2*n-3 DOWNTO 0) &"00";

  remainder_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r(2*n-1 DOWNTO 0) <= x; r(3*n+1 DOWNTO 2*n) <= (OTHERS => '0');
      ELSIF update = '1' THEN r <= next_r;
      END IF;  
    END IF;
  END PROCESS;
  remainder <= r(3*n DOWNTO 2*n);

  quotient_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= (OTHERS => '0');
      ELSIF update = '1' THEN q <= q(n-2 DOWNTO 0)&NOT(sumdif(n+1));
      END IF;  
    END IF;
  END PROCESS;
  root <= q;

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD n;
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
        WHEN 3 => IF count = n-1 THEN current_state <= 0; END IF;
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

