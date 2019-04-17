----------------------------------------------------------------------------
-- DecimalToBinary2.vhd
--
-- section 10.2 radix-B to Binary conversion (decimal to binary).
--
-- x is an m-digit decimal number
-- z is an n-bit number
-- logn is the number of bits of n-1
--
-- Uses the multiply_by_five and lut4b of chapter 9.
--
----------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY DecimalToBinary2 IS
  --GENERIC(n: NATURAL:= 16; m: NATURAL:= 5; logn: NATURAL:= 4);
  GENERIC(n: NATURAL:= 8; m: NATURAL:= 3; logn: NATURAL:= 4);
PORT(
  x: IN STD_LOGIC_VECTOR(4*m-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  done:OUT STD_LOGIC
);
END DecimalToBinary2;

ARCHITECTURE circuit OF DecimalToBinary2 IS

  COMPONENT multiply_by_five IS
    GENERIC(n: NATURAL);
  PORT(
    x: IN STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(4*n+3 DOWNTO 0)
  );
  END component;
  SIGNAL q: STD_LOGIC_VECTOR(4*m-1 DOWNTO 0);
  SIGNAL w: STD_LOGIC_VECTOR(4*m+3 DOWNTO 0);
  SIGNAL r, load, update, zero: STD_LOGIC;
  SIGNAL count: STD_LOGIC_VECTOR(logn-1 DOWNTO 0);
  TYPE states IS RANGE 0 TO 3;
  SIGNAL current_state: states;
BEGIN

  main_component: multiply_by_five GENERIC MAP(n => m)
  PORT MAP(x => q, z => w);
  
  r <= w(0);
  
  register_y: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= x;
      ELSIF update = '1' THEN q <= w(4*m+3 DOWNTO 4);
      END IF;
    END IF;
  END PROCESS;  
  
  shift_register_z: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF update = '1' THEN z <= r&z(n-1 DOWNTO 1);
      END IF;
    END IF;
  END PROCESS;  
  
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
