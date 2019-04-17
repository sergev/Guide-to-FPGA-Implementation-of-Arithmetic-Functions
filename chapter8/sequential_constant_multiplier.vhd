----------------------------------------------------------------------------
-- sequential_constant_multiplier.vhd
--
-- section 8.5 sequential_constant_multiplier
--
-- Computes: z = c·y + u
-- x: n bits
-- y: m bits
-- c: constant number up to 2^n-1 (n bits value)
-- z: n+m bits
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY lut6b IS
   GENERIC(truth_vector: STD_LOGIC_VECTOR(0 to 63));
PORT (
  a: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
  b: OUT STD_LOGIC 
);
END lut6b;
 
ARCHITECTURE behavior OF lut6b IS
BEGIN
  PROCESS(a)
    VARIABLE c: NATURAL; 
  BEGIN
    c := CONV_INTEGER(a);
    b <= truth_vector(c);
  END PROCESS; 
END behavior;

----------------------------------------------------------------------------
-- digit_by_constant_multiplier
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY digit_by_constant_multiplier IS
  GENERIC(n, c: NATURAL);
PORT(
  b: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
  u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+5 DOWNTO 0)
);
END digit_by_constant_multiplier;

ARCHITECTURE circuit OF digit_by_constant_multiplier IS
  COMPONENT lut6b IS
      GENERIC(truth_vector: STD_LOGIC_VECTOR(0 to 63));
  PORT (
    a: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    b: OUT STD_LOGIC 
  );
  END COMPONENT;
  TYPE vectors IS ARRAY (0 TO n+5) OF STD_LOGIC_VECTOR(0 TO 63);

  FUNCTION LUT_definition(c: NATURAL) RETURN vectors IS 
    VARIABLE zz: NATURAL;
    VARIABLE zzz: STD_LOGIC_VECTOR(n+5 DOWNTO 0);
    VARIABLE truth_vector: vectors;
  BEGIN
    FOR i IN 0 to 63 LOOP
      zz := c*i;
      zzz := CONV_STD_LOGIC_VECTOR(zz, n+6);
        FOR j IN 0 TO n+5 LOOP
          truth_vector(j)(i) := zzz(j);
        END LOOP;
      END LOOP;
    RETURN truth_vector;
  END LUT_definition;
  SIGNAL w: STD_LOGIC_VECTOR(n+5 DOWNTO 0);
BEGIN
  main_iteration: FOR i IN 0 TO n+5 GENERATE
    LUT_instantiation: lut6b GENERIC MAP (truth_vector => LUT_definition(c)(i)) 
    PORT MAP(a => b, b => w(i)); 
  END GENERATE;
  z <= w + u;
END circuit;

----------------------------------------------------------------------------
-- sequential_constant_multiplier
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY sequential_constant_multiplier IS
  GENERIC(n: NATURAL:=8; m: NATURAL:=8; c: NATURAL:=197);
PORT(
  y: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n+m-1 DOWNTO 0);
  done: OUT STD_LOGIC
);  
END sequential_constant_multiplier;

ARCHITECTURE circuit OF sequential_constant_multiplier IS

  COMPONENT digit_by_constant_multiplier IS
    GENERIC(n, c: NATURAL);
  PORT(
    b: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(n+5 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL acc_1: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL acc_0: STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  SIGNAL product: STD_LOGIC_VECTOR(n+5 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SUBTYPE index IS NATURAL RANGE 0 TO m/6-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;

BEGIN

  main_component: digit_by_constant_multiplier GENERIC MAP(n => n, c => c)
  PORT MAP(b => acc_0(5 DOWNTO 0), u => acc_1, z => product);

  z <= acc_1 & acc_0;
  
  parallel_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN acc_1 <= u; 
      ELSIF update = '1' THEN acc_1 <= product(n+5 DOWNTO 6);
      END IF;
    END IF;
  END PROCESS;

  shift_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN acc_0 <= y; 
      ELSIF update = '1' THEN acc_0 <= product(5 DOWNTO 0)& acc_0(m-1 DOWNTO 6);
      END IF;
    END IF;
  END PROCESS;

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD (m/6);
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
        WHEN 3 => IF count = m/6-1 THEN current_state <= 0; END IF;
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

