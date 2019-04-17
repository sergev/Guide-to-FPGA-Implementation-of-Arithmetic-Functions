----------------------------------------------------------------------------
-- restoring3.vhd
--
-- section 10.3.4 Restoring div for Newton-Raphson square root Algorithm
--
-- x = x2n-1 x2n-2 ... x0: natural
-- y = yn+p yn+p-1 ... yp.yp-1 ... y0: natural
-- condition: x < y·2^n
-- quotient Q =  qn+p-1 qn+p-2 ... qp.qp-1 ... q0: fractional
-- remainder R = rn+p rn+p-2 ... r2p.r2p-1 r2p-2 ... r0 : fractional
-- x = Q·y + R with R < y·2^-p
--
-- Used in SquareRootNR4
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY restoring3 IS
  GENERIC(n, p: NATURAL);
PORT(
  x: IN STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(n+p DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(n+p-1 DOWNTO 0);
  remainder: OUT STD_LOGIC_VECTOR(n+p DOWNTO 0);
  done: OUT STD_LOGIC
);
END restoring3;

ARCHITECTURE circuit OF restoring3 IS
  SIGNAL r, next_r: STD_LOGIC_VECTOR(2*n DOWNTO 0);
  SIGNAL long_y: STD_LOGIC_VECTOR(n+p+1 DOWNTO 0);
  SIGNAL two_r, dif: STD_LOGIC_VECTOR(2*n+1 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SIGNAL q: STD_LOGIC_VECTOR(n+p-1 DOWNTO 0);
  
  SUBTYPE index IS NATURAL RANGE 0 TO n+p-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN
  long_y <= '0'&y;
  two_r <= r&'0';
  dif(2*n+1 DOWNTO n-p) <= two_r(2*n+1 DOWNTO n-p) - long_y;
  dif(n-p-1 DOWNTO 0) <= two_r(n-p-1 DOWNTO 0);
  WITH dif(2*n+1) SELECT next_r <= dif(2*n DOWNTO 0) WHEN '0', two_r(2*n DOWNTO 0) WHEN OTHERS;

  remainder_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r <= '0'&x;
      ELSIF update = '1' THEN r <= next_r;
      END IF;  
    END IF;
  END PROCESS;
  remainder <= r(2*n DOWNTO n-p);

  quotient_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= (OTHERS => '0');
      ELSIF update = '1' THEN q <= q(n+p-2 DOWNTO 0)&NOT(dif(2*n+1));
      END IF;  
    END IF;
  END PROCESS;
  quotient <= q;

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD (n+p);
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
        WHEN 3 => IF count = n+p-1 THEN current_state <= 0; END IF;
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
