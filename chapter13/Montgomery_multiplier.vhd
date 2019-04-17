----------------------------------------------------------------------------
-- Montgomery_multiplier.vhd
--
-- section 13.1.2.3 Modular Montgomery multiplier
--
-- x, y, z: k bits naturals
-- z = (x * y * 2^-k) mod m 
--
----------------------------------------------------------------------------
LIBRARY IEEE; USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE mod_m IS
--  CONSTANT k: NATURAL := 192;
--  CONSTANT m: STD_LOGIC_VECTOR(191 DOWNTO 0):= (64 => '0', others => '1');
--  CONSTANT minus_m: STD_LOGIC_VECTOR(192 DOWNTO 0):= 
--    (0 => '1', 64 => '1', 192 => '1', OTHERS => '0');

  CONSTANT k: NATURAL := 8;
  CONSTANT m: STD_LOGIC_VECTOR(7 DOWNTO 0) := "11101111";
  CONSTANT minus_m: STD_LOGIC_VECTOR(8 DOWNTO 0):= "100010001";

END mod_m;

LIBRARY IEEE; USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.mod_m.ALL;
ENTITY Montgomery_multiplier IS
PORT(
  x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  clk, reset, start: STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END Montgomery_multiplier;

ARCHITECTURE circuit OF Montgomery_multiplier IS

  SIGNAL p, next_p, p_minus_m: STD_LOGIC_VECTOR(k DOWNTO 0);
  SIGNAL two_p: STD_LOGIC_VECTOR(k+1 DOWNTO 0);
  SIGNAL vector_xi, vector_q, int_x: STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  SIGNAL xi, q: STD_LOGIC;

  SIGNAL load, update: STD_LOGIC;
  SUBTYPE index IS NATURAL RANGE 0 TO k-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 4;
  SIGNAL current_state: state;



BEGIN

  q <= p(0) XOR (xi AND y(0));
  vector_xi <= (OTHERS => xi); vector_q <= (OTHERS => q);
  two_p <= ('0'&p) + (vector_xi AND y) +  (vector_q AND m); 
  next_p <= two_p(k+1 DOWNTO 1);
  p_minus_m <= p + minus_m;
  WITH p_minus_m(k) SELECT z <= p_minus_m(k-1 DOWNTO 0) WHEN '0', p(k-1 DOWNTO 0) WHEN OTHERS;
  
  register_p: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND CLK = '1' THEN
      IF load = '1' THEN p <= (OTHERS => '0');
      ELSIF update = '1' THEN p <= next_p;
      END IF;
    END IF;
  END PROCESS;
    
  shift_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND CLK = '1' THEN
      IF load = '1' THEN int_x <= x;
      ELSIF update = '1' THEN int_x <= '0'&int_x(k-1 DOWNTO 1);
      END IF;
    END IF;
  END PROCESS;
  xi <= int_x(0);
  
  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD k;
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
        WHEN 3 => IF count = k-1 THEN current_state <= 4; END IF;
        WHEN 4 => current_state <= 0;

      END CASE;
    END IF;
  END PROCESS;

  output_function: PROCESS(clk, current_state)
  BEGIN
    CASE current_state IS
      WHEN 0 TO 1 => load <= '0'; update <= '0'; done <= '1';
      WHEN 2 => load <= '1'; update <= '0'; done <= '0';
      WHEN 3 => load <= '0'; update <= '1'; done <= '0';
      
      WHEN 4 => load <= '0'; update <= '0'; done <= '0';
      
    END CASE;
  END PROCESS;

END circuit;

