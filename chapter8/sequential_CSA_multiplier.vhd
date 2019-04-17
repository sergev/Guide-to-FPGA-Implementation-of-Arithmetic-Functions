----------------------------------------------------------------------------
-- sequential_CSA_multiplier.vhd
--
-- section 8.3.2 shift and add sequential multiplier with CSA
--
-- Computes: z = x·y + u + v
-- x, u: n bits
-- y, v: m bits
-- z: n+m bits
-- for n greater than or equal to m
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY csa IS
  GENERIC(n: NATURAL);
PORT (
  y1, y2, y3: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  s, c: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END csa;

ARCHITECTURE behavior OF csa IS
BEGIN
  c(0) <= '0';
  iteration: FOR i IN 0 TO n-2 GENERATE
    s(i) <= y1(i) XOR y2(i) XOR y3(i);
    c(i+1) <= (y1(i) AND y2(i)) OR (y1(i) AND y3(i)) OR (y2(i) AND y3(i));
  END GENERATE;
  s(n-1) <= y1(n-1) XOR y2(n-1) XOR y3(n-1);
END behavior;

----------------------------------------------------------------------------
-- sequential_CSA_multiplier
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY sequential_CSA_multiplier IS
  GENERIC(n: NATURAL:= 64; m: NATURAL:= 64);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  y, v: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n+m-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END sequential_CSA_multiplier;

ARCHITECTURE circuit OF sequential_CSA_multiplier IS
  COMPONENT csa IS
    GENERIC(n: NATURAL);
  PORT (
  y1, y2, y3: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  s, c: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;

  SIGNAL y_i: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL s, c, next_s, next_c, xy: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL int_y: STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  
  SIGNAL load, update: STD_LOGIC;
  SUBTYPE index IS NATURAL RANGE 0 TO m-1;
  SIGNAL count: index;

  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;

BEGIN

  xy <= '0'&(x AND y_i);
  main_component: csa GENERIC MAP(n => n+1)
  PORT MAP(y1 => xy, y2 => s , y3 => c, s => next_s, c => next_c);

  register_s: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN s <= '0'&u; 
      ELSIF update = '1' THEN s <= '0'&(next_s(n DOWNTO 1));
      END IF;
    END IF;
  END PROCESS;

  register_c: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN 
         c(m-1 DOWNTO 0) <= v; 
         c(n DOWNTO m) <= (OTHERS => '0');
      ELSIF update = '1' THEN 
         c <= '0'&(next_c(n DOWNTO 1));
      END IF;
    END IF;
  END PROCESS;

  shift_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN 
         int_y <= y; 
      ELSIF update = '1' THEN 
         int_y <= next_s(0)& int_y(m-1 DOWNTO 1);
      END IF;
    END IF;
  END PROCESS;
  y_i <= (OTHERS => int_y(0));
  
  z(m-1 DOWNTO 0) <= int_y(m-1 DOWNTO 0);
  z(m+n-1 DOWNTO m) <= s(n-1 DOWNTO 0) + c(n-1 DOWNTO 0);
  
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


