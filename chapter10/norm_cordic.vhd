----------------------------------------------------------------------------
-- norm_cordic.vhd
--
-- section 10.6 Trigonometric function (Morm Cordic)
--
-- x, y  : p-bits naturals
-- z = (x^2 + y^2)^0.5 p+1 bits natural
-- m: internal operation accuracy
-- n: number of iterations
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY shifter IS
  GENERIC(m: NATURAL);
PORT(
  a: IN STD_LOGIC_VECTOR(m DOWNTO 0);
  shift: IN NATURAL;
  b: OUT STD_LOGIC_VECTOR(m DOWNTO 0)
 );
 END shifter;

ARCHITECTURE behavior OF shifter IS
BEGIN
  PROCESS(shift, a)
  BEGIN
    FOR i IN 0 TO m-1 LOOP
      IF shift = i THEN 
        b(m DOWNTO m-i) <= (OTHERS => a(m));
        b(m-i-1 DOWNTO 0) <= a(m-1 DOWNTO i);
      END IF;
    END LOOP;
  END PROCESS;
END behavior; 

-------------------------------------------------------------
-- norm_cordic
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY norm_cordic IS
  GENERIC(p: NATURAL := 8; m: NATURAL := 16; n: NATURAL := 8);
PORT(
  x, y: IN STD_LOGIC_VECTOR(p-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
  done: OUT STD_LOGIC
);
END norm_cordic;

ARCHITECTURE circuit OF norm_cordic IS
  COMPONENT shifter IS
    GENERIC(m: NATURAL);
  PORT(
    a: IN STD_LOGIC_VECTOR(m DOWNTO 0);
    shift: IN NATURAL;
    b: OUT STD_LOGIC_VECTOR(m DOWNTO 0)
   );
  END COMPONENT;
  SIGNAL long_x, next_x: STD_LOGIC_VECTOR(m+2 DOWNTO 0);
  SIGNAL long_y, next_y: STD_LOGIC_VECTOR(m+2 DOWNTO 0);
  SIGNAL shifted_x: STD_LOGIC_VECTOR(m+2 DOWNTO 0);
  SIGNAL shifted_y: STD_LOGIC_VECTOR(m+2 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SIGNAL long_z: STD_LOGIC_VECTOR(m+17 DOWNTO 0);
    
  SUBTYPE index IS NATURAL RANGE 0 TO n-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN

  shifter_x: shifter GENERIC MAP(m => m+2)
  PORT MAP(a => long_x, shift => count, b => shifted_x);
  shifter_y: shifter GENERIC MAP(m => m+2)
  PORT MAP(a => long_y, shift => count, b => shifted_y);
  
  WITH long_y(m+2) SELECT next_x <= long_x - shifted_y WHEN '1', long_x + shifted_y WHEN OTHERS;
  WITH long_y(m+2) SELECT next_y <= long_y + shifted_x(m DOWNTO 0) WHEN '1', long_y - shifted_x(m DOWNTO 0) WHEN OTHERS;

      
  register_x: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN long_x(m+2 DOWNTO m) <= "000"; long_x(m-1 DOWNTO m-p) <= x; long_x(m-p-1 DOWNTO 0) <= (OTHERS => '0');
      ELSIF update = '1' THEN long_x <= next_x; 
      END IF;  
    END IF;
  END PROCESS;
  long_z <= long_x(m+1 DOWNTO 0) * x"9b74";
  z <= long_z(m+16 DOWNTO m+16-p);
     
  register_y: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN long_y(m+2 DOWNTO m) <= "000"; long_y(m-1 DOWNTO m-p) <= y; long_y(m-p-1 DOWNTO 0) <= (OTHERS => '0');
      ELSIF update = '1' THEN long_y <= next_y; 
      END IF;  
    END IF;
  END PROCESS;


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

--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--ENTITY test_norm_cordic IS
--END test_norm_cordic;
--
--ARCHITECTURE test OF test_norm_cordic IS
--  COMPONENT norm_cordic IS
--    GENERIC(p, m, n: NATURAL);
--  PORT(
--    x, y: IN STD_LOGIC_VECTOR(p-1 DOWNTO 0);
--    clk, reset, start:IN STD_LOGIC;
--    z: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
--    done: OUT STD_LOGIC
--  );
--  END COMPONENT;
--  SIGNAL x, y: STD_LOGIC_VECTOR(7 DOWNTO 0);
--  SIGNAL z: STD_LOGIC_VECTOR(8 DOWNTO 0);
--  SIGNAL clk: STD_LOGIC := '0';
--  SIGNAL reset, start, done: STD_LOGIC;
--  
--BEGIN
--  dut: norm_cordic 
--    GENERIC MAP(p => 8, m => 16, n => 8)
--    PORT MAP(x => x, y => y, z => z, clk => clk, reset => reset, start => start, done => done);
--  clk <= NOT(clk) AFTER 50 NS;
--  reset <= '1', '0' AFTER 100 NS;
--  start <= '0', '1' AFTER 200 NS, '0' AFTER 400 NS, '1' AFTER 2200 NS, '0' AFTER 2400 NS, '1' AFTER 4200 NS, '0' AFTER 4400 NS, '1' AFTER 6200 NS;
--  x <= x"4d", x"d9" AFTER 2000 NS, x"FF" AFTER 4000 NS, x"86" AFTER 6000 NS;
--  y <= x"66", x"a8" AFTER 2000 NS, x"FF" AFTER 4000 NS, x"86" AFTER 6000 NS;
--  
--END test;