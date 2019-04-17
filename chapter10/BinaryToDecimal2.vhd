----------------------------------------------------------------------------
-- BinaryToDecimal2.vhd
--
-- section 10.1 Binary to radix-B conversion.
--
-- x in an n-bit natural
-- logn is the number of bits of n-1
-- y is an m-digit decimal natural
--
-- Uses the doubling_circuit2 and lut4b of chapter 9.
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY BinaryToDecimal2 IS
  GENERIC(n: NATURAL:= 16; m: NATURAL:= 5; logn: NATURAL:= 4);
PORT(
  x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  y: OUT STD_LOGIC_VECTOR(4*m-1 DOWNTO 0);
  done:OUT STD_LOGIC
);
END BinaryToDecimal2;

ARCHITECTURE circuit OF BinaryToDecimal2 IS

  COMPONENT doubling_circuit2 IS
    GENERIC(n: NATURAL);
  PORT(
    x: IN STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
    c_in: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(4*n DOWNTO 0)
  );
  END COMPONENT;

  SIGNAL z: STD_LOGIC_VECTOR(4*m-1 DOWNTO 0);
  SIGNAL w: STD_LOGIC_VECTOR(4*m DOWNTO 0);
  SIGNAL xNminusI, load, update, zero: STD_LOGIC;
  SIGNAL int_x: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL count: STD_LOGIC_VECTOR(logn-1 DOWNTO 0);
  TYPE states IS RANGE 0 TO 3;
  SIGNAL current_state: states;

BEGIN

  main_component: doubling_circuit2 GENERIC MAP(n => m)
  PORT MAP(x => z, z => w, c_in => xNminusI);

  register_z: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN z <= (OTHERS => '0');
      ELSIF update = '1' THEN z <= w(4*m-1 DOWNTO 0);
      END IF;
    END IF;
  END PROCESS;  
  y <= z;
  register_x: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN int_x <= x;
      ELSIF update = '1' THEN int_x <= int_x(n-2 DOWNTO 0)&'0';
      END IF;
    END IF;
  END PROCESS;  
  xNminusI <= int_x(n-1);
  a_counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN count <= CONV_STD_LOGIC_VECTOR(n-1, logn);
      ELSIF update = '1' THEN count <= count -1;
      END IF;
    END IF;
  END PROCESS;
  zero <= '1' WHEN count = 0 ELSE '0';
  control_unit: PROCESS(clk, reset, current_state, zero)
  BEGIN
    CASE current_state IS
      WHEN 0 to 1 => load <= '0'; update <= '0'; done <= '1';
      WHEN 2 => load <= '1'; update <= '0'; done <= '0';
      WHEN 3 => load <= '0'; update <= '1'; done <= '0';
    END CASE;
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
        WHEN 2 => current_state <= 3;
        WHEN 3 => IF zero = '1' THEN current_state <= 0; END IF;
      END CASE;
    END IF;
  END PROCESS;
END circuit;
