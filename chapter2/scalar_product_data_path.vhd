----------------------------------------------------------------------------
-- scalar_product_data_path.vhd
--
-- Implements the data path for the scalar product in GF(2**m)
-- section 2.5 final example
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE scalar_product_parameters IS
  CONSTANT M: INTEGER := 163;
  CONSTANT logM: INTEGER := 9;--logM is the number of bits of m plus an additional sign bit
  CONSTANT F: STD_LOGIC_VECTOR(M DOWNTO 0):= x"800000000000000000000000000000000000000C9"; 
END scalar_product_parameters;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.scalar_product_parameters.ALL;
ENTITY scalar_product_data_path IS
PORT(
  xP: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  clk, reset, start_mult, load, en_XA, en_XB, en_ZA, en_ZB, en_R: IN STD_LOGIC;
  sel_p1, sel_p2, sel_a1, sel_a2, sel_sq, sel_xA, sel_xB, sel_zA, sel_zB: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  sel_R: IN STD_LOGIC;
  xA, zA, xB, zB: INOUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  mult_done: OUT STD_LOGIC
);
END scalar_product_data_path;

ARCHITECTURE circuit OF scalar_product_data_path IS

COMPONENT classic_squarer IS
PORT (
  a: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  c: OUT STD_LOGIC_VECTOR(M-1 DOWNTO 0)
);
END COMPONENT;

COMPONENT interleaved_mult IS
PORT (
  A, B: IN STD_LOGIC_VECTOR (M-1 DOWNTO 0);
  clk, reset, start: IN std_logic; 
  Z: OUT STD_LOGIC_VECTOR (M-1 DOWNTO 0);
  done: OUT std_logic
);
END COMPONENT;

SIGNAL R, next_R, next_xA, next_xB, next_zA, next_zB, square, product, adder_out, 
mult1, mult2, add1, add2, square_in: STD_LOGIC_VECTOR (M-1 DOWNTO 0);
CONSTANT zero: STD_LOGIC_VECTOR(M-1 DOWNTO 0) := (OTHERS => '0');
CONSTANT one: STD_LOGIC_VECTOR(M-1 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1, M);

BEGIN

WITH sel_p1 SELECT mult1 <= xA WHEN "00", xB WHEN "01", xP WHEN OTHERS;
WITH sel_p2 SELECT mult2 <= zA WHEN "00", zB WHEN "01", R WHEN OTHERS;
a_mod_f_multiplier: interleaved_mult PORT map (
  A => mult1, B => mult2, clk => clk, reset => reset, start => start_mult, Z => product, done => mult_done
);

WITH sel_a1 SELECT add1 <= xA WHEN "00", zB WHEN "01", R WHEN OTHERS;
WITH sel_a2 SELECT add2 <= xB WHEN "00", zA WHEN "01", R WHEN OTHERS;
--an_adder: FOR i IN 0 TO M-1 GENERATE adder_out(i) <= add1(i) XOR add2(i); END GENERATE;
adder_out <= add1 XOR add2;

WITH sel_sq SELECT square_in<= zA WHEN "00", zB WHEN "01", xA WHEN "10", xB WHEN OTHERS;
a_squarer: classic_squarer PORT map (
  a => square_in, c => square
);

WITH sel_xA SELECT next_xA <= product WHEN "00", adder_out WHEN "01", zB WHEN OTHERS;
register_xA: PROCESS(clk)
BEGIN
  IF clk'EVENT AND clk = '1' THEN
    IF load = '1' THEN xA <= one;
    ELSIF en_xA = '1' THEN xA <= next_xA;
    END IF;
  END IF;
END PROCESS;

WITH sel_xB SELECT next_xB <= product WHEN "00", adder_out WHEN "01", zA WHEN OTHERS;
register_xB: PROCESS(clk)
BEGIN
  IF clk'EVENT AND clk = '1' THEN
    IF load = '1' THEN xB <= xP;
    ELSIF en_xB = '1' THEN xB <= next_xB;
    END IF;
  END IF;
END PROCESS;

WITH sel_zA SELECT next_zA <= adder_out WHEN "00", square WHEN "01", R WHEN "10", zB WHEN OTHERS;
register_zA: PROCESS(clk)
BEGIN
  IF clk'EVENT AND clk = '1' THEN
    IF load = '1' THEN zA <= zero;
    ELSIF en_zA = '1' THEN zA <= next_zA;
    END IF;
  END IF;
END PROCESS;

WITH sel_zB SELECT next_zB <= adder_out WHEN "00", square WHEN "01", zA WHEN "10", R WHEN OTHERS;
register_zB: PROCESS(clk)
BEGIN
  IF clk'EVENT AND clk = '1' THEN
    IF load = '1' THEN zB <= one;
    ELSIF en_zB = '1' THEN zB <= next_zB;
    END IF;
  END IF;
END PROCESS;

WITH sel_R SELECT next_R <= product WHEN '0', square WHEN OTHERS;
register_R: PROCESS(clk)
BEGIN
  IF clk'EVENT AND clk = '1' THEN
    IF en_R = '1' THEN R <= next_R; END IF;
  END IF;
END PROCESS;

END circuit;

