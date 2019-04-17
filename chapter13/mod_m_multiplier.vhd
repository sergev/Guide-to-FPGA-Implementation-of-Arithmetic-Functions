----------------------------------------------------------------------------
-- mod_m_multiplier.vhd
--
-- section 13.1.2.2 mod m interleaved multiplier
--
-- x, y, z: k bits naturals
-- z = (x * y) mod m 
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
--  CONSTANT minus_2m: STD_LOGIC_VECTOR(193 DOWNTO 0):= 
--    (1 => '1', 65 => '1', 193 => '1',OTHERS => '0');
  CONSTANT k: NATURAL := 8;
  CONSTANT m: STD_LOGIC_VECTOR(7 DOWNTO 0) := "11101111";
  CONSTANT minus_m: STD_LOGIC_VECTOR(8 DOWNTO 0):= "100010001";
  CONSTANT minus_2m: STD_LOGIC_VECTOR(9 DOWNTO 0):= "1000100010";

END mod_m;

LIBRARY IEEE; USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.mod_m.ALL;
ENTITY mod_m_multiplier IS
PORT(
  x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  clk, reset, start: STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END mod_m_multiplier;

ARCHITECTURE circuit OF mod_m_multiplier IS

  SIGNAL acc, xi_by_y, vector_xi, next_acc, int_x: STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  SIGNAL s: STD_LOGIC_VECTOR(k+1 DOWNTO 0); 
  SIGNAL z1, z2: STD_LOGIC_VECTOR(k+2 DOWNTO 0);
  SIGNAL xi: STD_LOGIC;

  SIGNAL load, update: STD_LOGIC;
  SUBTYPE index IS NATURAL RANGE 0 TO k-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;

BEGIN
  vector_xi <= (OTHERS => xi);
  xi_by_y <= y AND vector_xi; 
  s <= '0'&acc&'0' + xi_by_y;
  z1 <= ('0'&s) + ("11"&minus_m);
  z2 <= ('0'&s) + ('1'&minus_2m);

  PROCESS(z1, z2, s)
  BEGIN
    IF z1(k+2) = '1' THEN next_acc <= s(k-1 DOWNTO 0);
    ELSIF z2(k+2) = '1' THEN next_acc <= z1(k-1 DOWNTO 0); 
    ELSE next_acc <= z2(k-1 DOWNTO 0); 
    END IF;
  END PROCESS;

  register_acc: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND CLK = '1' THEN
      IF load = '1' THEN acc <= (OTHERS => '0');
      ELSIF update = '1' THEN acc <= next_acc;
      END IF;
    END IF;
  END PROCESS;
  z <= acc;
    
  shift_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND CLK = '1' THEN
      IF load = '1' THEN int_x <= x;
      ELSIF update = '1' THEN int_x <= int_x(k-2 DOWNTO 0)&'0';
      END IF;
    END IF;
  END PROCESS;
  xi <= int_x(k-1);
  
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
        WHEN 3 => IF count = k-1 THEN current_state <= 0; END IF;
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
