----------------------------------------------------------------------------
-- scalar_product_DF2.vhd
--
-- Implements the scalar product in GF(2**m)
-- not using the explicit separation between datapath and control.
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
ENTITY scalar_product_DF2 IS
PORT (
    xP, k: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    xA, zA, xB, zB: INOUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    done: OUT STD_LOGIC );
END scalar_product_DF2;

ARCHITECTURE data_flow OF scalar_product_DF2 IS

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

SIGNAL product, mult1, mult2, square_in, square, R: STD_LOGIC_VECTOR (M-1 DOWNTO 0);
CONSTANT zero: STD_LOGIC_VECTOR(M-1 DOWNTO 0) := (OTHERS => '0');
CONSTANT one: STD_LOGIC_VECTOR(M-1 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1, M);
SIGNAL start_mult, mult_done: STD_LOGIC;

PROCEDURE sync IS
BEGIN
  WAIT UNTIL clk'EVENT AND clk = '1';
END sync;

BEGIN

a_mod_f_multiplier: interleaved_mult PORT MAP (
  A => mult1, B => mult2, clk => clk, reset => reset, start => start_mult, Z => product, done => mult_done
);

a_squarer: classic_squarer PORT MAP (
  a => square_in, c => square
);

PROCESS
BEGIN
  LOOP
    WAIT UNTIL start = '0';
    WAIT UNTIL start = '1';
    xA <= one; zA <= zero; xB <= xP; zB <= one; start_mult <= '0'; done <= '0';
    sync;
    FOR i in 1 TO m LOOP
      IF reset = '1' THEN EXIT; END IF;
      IF k(m-i) = '0' THEN
        zB <= xA XOR zA; mult1 <= xA; mult2 <= zB; start_mult <= '1'; sync;      
        start_mult <= '0'; sync;
        square_in <= zB; sync;
        zB <= square; sync;
        square_in <= zB; sync;
        zB <= square; sync;
        WAIT UNTIL mult_done = '1';
        R <= product; sync;
        mult1 <= xB; mult2 <= zA; start_mult <= '1'; sync;
        start_mult <= '0'; sync;
        WAIT UNTIL mult_done = '1'; 
        xB <= product; sync;
        zA <= R XOR xB; mult1 <= xA; mult2 <= zA; start_mult <= '1'; sync;
        start_mult <= '0'; sync;
        square_in <= zA; sync;
        zA <= square; sync;
        WAIT UNTIL mult_done = '1';
        xA <= product; sync;
        square_in <= xA; mult1 <= R; mult2 <= xB; start_mult <= '1'; sync;
        R <= square; start_mult <= '0'; sync;
        WAIT UNTIL mult_done = '1';
        xB <= product; sync;
        mult1 <= xP; mult2 <= zA; start_mult <= '1'; sync;
        start_mult <= '0'; sync;
        WAIT UNTIL mult_done = '1';
        xA <= product; sync;
        xB <= xA XOR xB; xA <= zB; zA <= R; zB <= zA; sync;
      ELSE
        zA <= xB XOR zB; mult1 <= xB; mult2 <= zA; start_mult <= '1'; sync;      
        start_mult <= '0'; sync;
        square_in <= zA; sync;
        zA <= square; sync;
        square_in <= zA; sync;
        zA <= square; sync;
        WAIT UNTIL mult_done = '1';
        R <= product; sync;
        mult1 <= xA; mult2 <= zB; start_mult <= '1'; sync;
        start_mult <= '0'; sync;
        WAIT UNTIL mult_done = '1'; 
        xA <= product; sync;
        zB <= R XOR xA; mult1 <= xB; mult2 <= zB; start_mult <= '1'; sync;
        start_mult <= '0'; sync;
        square_in <= zB; sync;
        zB <= square; sync;
        WAIT UNTIL mult_done = '1';
        xB <= product; sync;
        square_in <= xB; mult1 <= R; mult2 <= xA; start_mult <= '1'; sync;
        R <= square; start_mult <= '0'; sync;
        WAIT UNTIL mult_done = '1';
        xA <= product; sync;
        mult1 <= xP; mult2 <= zB; start_mult <= '1'; sync;
        start_mult <= '0'; sync;
        WAIT UNTIL mult_done = '1';
        xB <= product; sync;
        xA <= xB XOR xA; xB <= zA; zB <= R; zA <= zB; sync;
      END IF;
    END LOOP;
    done <= '1';
    sync;
  END LOOP;
END PROCESS;
END data_flow;

