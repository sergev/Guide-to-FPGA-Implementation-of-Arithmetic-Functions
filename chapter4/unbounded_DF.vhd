----------------------------------------------------------------------------
-- unbounded_DF2.vhd
--
-- Implements the scalar product in GF(2**m) 
-- section 4.3 Variable latency operators
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
ENTITY unbounded_DF IS
PORT (
    xP, k: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    xA, zA, xB, zB: INOUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    done: OUT STD_LOGIC );
END unbounded_DF;

ARCHITECTURE data_flow OF unbounded_DF IS

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

SIGNAL product1, product2, mult1a, mult1b, mult2a, mult2b, square_in, square, R: STD_LOGIC_VECTOR (M-1 DOWNTO 0);
CONSTANT zero: STD_LOGIC_VECTOR(M-1 DOWNTO 0) := (OTHERS => '0');
CONSTANT one: STD_LOGIC_VECTOR(M-1 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1, M);
SIGNAL start_mult1, start_mult2, done1, done2, done12: STD_LOGIC;

PROCEDURE sync IS
BEGIN
  WAIT UNTIL clk'EVENT AND clk = '1';
END sync;

BEGIN

mod_f_multiplier1: interleaved_mult PORT MAP (
  A => mult1a, B => mult1b, clk => clk, reset => reset, start => start_mult1, Z => product1, done => done1
);

mod_f_multiplier2: interleaved_mult PORT MAP (
  A => mult2a, B => mult2b, clk => clk, reset => reset, start => start_mult2, Z => product2, done => done2
);

a_squarer: classic_squarer PORT MAP (
  a => square_in, c => square
);

done12 <= done1 AND done2;

PROCESS
BEGIN
  LOOP
    WAIT UNTIL start = '0';
    WAIT UNTIL start = '1';
    xA <= one; zA <= zero; xB <= xP; zB <= one; start_mult1 <= '0'; start_mult2 <= '0'; done <= '0';
    sync;
    FOR i in 1 TO m LOOP
      IF reset = '1' THEN EXIT; END IF;
      IF k(m-i) = '0' THEN
        zB <= xA XOR zA; mult1a <= xA; mult1b <= zB; start_mult1 <= '1'; mult2a <= xB; mult2b <= zA; start_mult2 <= '1'; sync;      
        start_mult1 <= '0'; start_mult2 <= '0'; sync;
        square_in <= zB; sync;
        zB <= square; sync;
        square_in <= zB; sync;
        zB <= square; sync;
        WAIT UNTIL done12 = '1';
        R <= product1; xB <= product2; sync;
        zA <= R XOR xB; mult1a <= xA; mult1b <= zA; mult2a <= R; mult2b <= xB; start_mult1 <= '1'; start_mult2 <= '1'; sync;
        start_mult1 <= '0'; start_mult2 <= '0'; sync;
        WAIT UNTIL done12 = '1'; 
        square_in <= zA; xA <= product1; xB <= product2; sync;
        zA <= square; sync;    
        square_in <= xA; mult1a <= xP; mult1b <= zA; start_mult1 <= '1'; sync;
        R <= square; start_mult1 <= '0'; sync;
        WAIT UNTIL done1 = '1';
        xA <= product1; sync;
        xB <= xA XOR xB; xA <= zB; zA <= R; zB <= zA; sync;
      ELSE
        zA <= xB XOR zB; mult1a <= xB; mult1b <= zA; start_mult1 <= '1'; mult2a <= xA; mult2b <= zB; start_mult2 <= '1'; sync;      
        start_mult1 <= '0'; start_mult2 <= '0'; sync;
        square_in <= zA; sync;
        zA <= square; sync;
        square_in <= zA; sync;
        zA <= square; sync;
        WAIT UNTIL done12 = '1';
        R <= product1; xA <= product2; sync;
        zB <= R XOR xA; mult1a <= xB; mult1b <= zB; mult2a <= R; mult2b <= xA; start_mult1 <= '1'; start_mult2 <= '1'; sync;
        start_mult1 <= '0'; start_mult2 <= '0'; sync;
        WAIT UNTIL done12 = '1'; 
        square_in <= zB; xB <= product1; xA <= product2; sync;
        zB <= square; sync;    
        square_in <= xB; mult1a <= xP; mult1b <= zB; start_mult1 <= '1'; sync;
        R <= square; start_mult1 <= '0'; sync;
        WAIT UNTIL done1 = '1';
        xB <= product1; sync;
        xA <= xB XOR xA; xB <= zA; zB <= R; zA <= zB; sync;
      END IF;
    END LOOP;
    done <= '1';
    sync;
  END LOOP;
END PROCESS;
END data_flow;

