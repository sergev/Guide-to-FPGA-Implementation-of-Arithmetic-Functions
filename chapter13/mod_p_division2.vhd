----------------------------------------------------------------------------
-- mod_p_division2.vhd
--
-- section 13.2 Mod p division
--
-- z = x·1/y mod p
--
-- Behavioural model (not synthezible)
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY mod_p_division2 IS
  GENERIC(k: NATURAL; p: STD_LOGIC_VECTOR);
PORT (
    x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    done: OUT STD_LOGIC 
    );
END mod_p_division2;

ARCHITECTURE data_flow OF mod_p_division2 IS

SIGNAL b_minus_a, d_plus_p, d_minus_c, c_minus_d, a_minus_2: STD_LOGIC_VECTOR (k DOWNTO 0);
SIGNAL a, b, c, d, a_minus_b: STD_LOGIC_VECTOR (k-1 DOWNTO 0);
CONSTANT two: STD_LOGIC_VECTOR (k-1 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(2, k);

PROCEDURE sync IS
BEGIN
  WAIT UNTIL clk'EVENT AND clk = '1';
END sync;

BEGIN

b_minus_a <= ('0'&b) - a; 
a_minus_b <= a - b;
WITH d(0) SELECT d_plus_p <= ('0'&d) WHEN '0', ('0'&d) + p WHEN OTHERS;
d_minus_c <= ('0'&d) - c;
c_minus_d <= ('0'&c)- d;
a_minus_2 <= ('0'&a) - two;


PROCESS
BEGIN
  
  ext_loop: LOOP
    WAIT UNTIL start = '1';
    a <= p; b <= y; c <= (OTHERS => '0'); d <= x; done <= '0'; sync;
    int_loop: LOOP
      IF a_minus_2(k) = '1' THEN EXIT; END IF;
      IF b(0) = '0' THEN b <= '0'&b(k-1 DOWNTO 1); d <= d_plus_p(k DOWNTO 1);  
      ELSIF b_minus_a(k) = '0' THEN 
        b <= b_minus_a(k-1 DOWNTO 0); 
        IF d_minus_c(k) = '0' THEN d <= d_minus_c(k-1 DOWNTO 0); ELSE d <= d_minus_c(k-1 DOWNTO 0) + p; END IF;
      ELSE
        b <= a_minus_b; 
        a <= b; 
        IF c_minus_d(k) = '0' THEN d <= c_minus_d(k-1 DOWNTO 0); ELSE d <= c_minus_d(k-1 DOWNTO 0) + p; END IF; 
        c <= d;
      END IF;
      sync;
    END LOOP int_loop;
    z <= c; done <= '1'; sync;
  END LOOP ext_loop;
END PROCESS;
END data_flow;

