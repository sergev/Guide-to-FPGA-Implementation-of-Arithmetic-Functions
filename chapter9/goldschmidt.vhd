----------------------------------------------------------------------------
-- goldschmidt.vhd
--
-- section 9.4 convergence algorithm
--
-- x = xn.xn-1 ··· x0: 1 <= x < 2
-- y = yn.yn-1 ··· y0: 1 <= y < 2
-- q = x/y
-- m steps
-- internally: p bits
-- p > n
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY goldschmidt IS
  GENERIC(n: NATURAL:= 8; p: NATURAL:= 10; m: NATURAL:= 4);
PORT(
  x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(0 TO p);
  done: OUT STD_LOGIC
);
END goldschmidt;

ARCHITECTURE circuit OF goldschmidt IS

  SIGNAL a, not_a, next_a: STD_LOGIC_VECTOR(p-1 DOWNTO 0);
  SIGNAL b, c, next_b: STD_LOGIC_VECTOR(p DOWNTO 0);
  SIGNAL ac: STD_LOGIC_VECTOR(2*p DOWNTO 0);
  SIGNAL bc: STD_LOGIC_VECTOR(2*p+1 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SIGNAL count: NATURAL RANGE 0 TO m-1;
  TYPE states IS RANGE 0 TO 3;
  SIGNAL current_state: states;
 
BEGIN
  not_a <= NOT(a);
  c(p-1 DOWNTO 0) <= not_a + 1;
  c(p) <= '1';
  ac <= a*c;
  bc <= b*c;
  next_a <= ac(2*p-1 DOWNTO p);
  next_b <= bc(2*p DOWNTO p);
  
  register_a: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN 
        a(p-1 DOWNTO p-n-1) <= y; 
        a(p-n-2 DOWNTO 0) <= (OTHERS => '0');
      ELSIF update = '1' THEN 
        a <= next_a;
      END IF;
    END IF;  
  END PROCESS;

  register_b: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN 
        b(p) <= '0'; 
        b(p-1 DOWNTO p-n-1) <= x; 
        b(p-n-2 DOWNTO 0) <= (OTHERS => '0');
      ELSIF update = '1' THEN b <= next_b;
      END IF;
    END IF;  
  END PROCESS;
  quotient <= b;
  
  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD m;
      END IF;
    END IF;
  END PROCESS;

  next_state: PROCESS(clk, reset)
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

  output_function: PROCESS(current_state)
  BEGIN
    CASE current_state IS
      WHEN 0 TO 1 => load <= '0'; update <= '0'; done <= '1';
      WHEN 2 => load <= '1'; update <= '0'; done <= '0';
      WHEN 3 => load <= '0'; update <= '1'; done <= '0';
    END CASE;
  END PROCESS;
  
END circuit;

--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--ENTITY test_goldschmidt IS
--END test_goldschmidt;
--
--ARCHITECTURE test OF test_goldschmidt IS
--  COMPONENT goldschmidt IS
--    GENERIC(n, p, m: NATURAL);
--  PORT(
--    x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
--    y: IN STD_LOGIC_VECTOR(n DOWNTO 0);
--    clk, reset, start:IN STD_LOGIC;
--    quotient: OUT STD_LOGIC_VECTOR(0 TO p);
--    done: OUT STD_LOGIC
--  );
--  END COMPONENT;
--  SIGNAL x, y: STD_LOGIC_VECTOR(8 DOWNTO 0);
--  SIGNAL clk: STD_LOGIC := '0';
--  SIGNAL reset, start, done: STD_LOGIC;
--  SIGNAL quotient: STD_LOGIC_VECTOR(16 DOWNTO 0);
--  
--BEGIN
--  dut: goldschmidt GENERIC MAP(n => 8, p => 16, m => 8)
--    PORT MAP(x => x, y => y, clk => clk, reset => reset, start => start, done => done, quotient => quotient);
--  
--  clk <= NOT(clk) AFTER 50 NS;
--  reset <= '1', '0' AFTER 100 NS;
--  start <= '1', '0' AFTER 200 NS, '1' AFTER 300 NS, '0' AFTER 400 NS, '1' AFTER 20100 NS;
--  x <= "111001001", "111111111" AFTER 20000 NS;
--  y <= "101100110", "100000000" AFTER 20000 NS;
--    
--END test;