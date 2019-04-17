----------------------------------------------------------------------------
-- mod_f_division2.vhd
--
-- section 13.4 Mod f division
--
-- Behavioural model (not synthezible)
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
package binary_algorithm_polynomials_parameters is
  constant M: integer := 8;
  --constant logM: integer := 9;--logM is the number of bits of m plus an additional sign bit
  constant F: std_logic_vector(M downto 0):= "100011011"; --for M=8 bits
  --constant F: std_logic_vector(M downto 0):= '1'& x"001B"; --for M=16 bits
  --constant F: std_logic_vector(M downto 0):= '1'& x"0101001B"; --for M=32 bits
  --constant F: std_logic_vector(M downto 0):=  '1'& x"010100000101001B"; --for M=64 bits
  --constant F: std_logic_vector(M downto 0):= '1'& x"0000000000000000010100000101001B"; --for M=128 bits
  --constant F: std_logic_vector(M downto 0):= x"800000000000000000000000000000000000000C9"; --for M=163
  --constant F: std_logic_vector(M downto 0):= (0=> '1', 74 => '1', 233 => '1',others => '0'); --for M=233
end binary_algorithm_polynomials_parameters;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.binary_algorithm_polynomials_parameters.ALL;
ENTITY mod_f_division2 IS
PORT (
    g, h: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(m-1 DOWNTO 0);
    done: OUT STD_LOGIC 
    );
END mod_f_division2;

ARCHITECTURE data_flow OF mod_f_division2 IS

SIGNAL a: STD_LOGIC_VECTOR (m DOWNTO 0);
SIGNAL b, u, v, a_plus_b_div_x, v_div_x, u_plus_v_div_x: STD_LOGIC_VECTOR (m-1 DOWNTO 0);
CONSTANT zero: STD_LOGIC_VECTOR (m-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL alpha, beta: INTEGER;

PROCEDURE sync IS
BEGIN
  WAIT UNTIL clk'EVENT AND clk = '1';
END sync;

BEGIN

a_plus_b_div_x(m-1) <= a(m);
v_div_x(m-1) <= v(0);
u_plus_v_div_x(m-1) <= u(0) XOR v(0);
functions: FOR i IN 0 TO m-2 GENERATE
  a_plus_b_div_x(i) <= a(i+1) XOR b(i+1);
  v_div_x(i) <= v(i+1) XOR (v(0) AND f(i+1));
  u_plus_v_div_x(i) <= u(i+1) XOR v(i+1) XOR ((u(0) XOR v(0)) AND f(i+1)); 
END GENERATE;

PROCESS
BEGIN
  
  ext_loop: LOOP
    WAIT UNTIL start = '1';
    IF reset = '1' THEN EXIT; END IF;
    a <= f; b <= h; u <= (OTHERS => '0'); v <= g; alpha <= m; beta <= m-1; done <= '0'; sync;
    int_loop: LOOP
      IF beta < zero THEN EXIT; END IF;
      IF b(0) = '0' THEN b <= '0'&b(m-1 DOWNTO 1); v <= v_div_x; beta <= beta - 1; 
      ELSIF alpha < beta THEN 
        b <= a_plus_b_div_x; v <= u_plus_v_div_x; beta <= beta - 1;
      ELSE
        a <= '0'&b; b <= a_plus_b_div_x; u <= v; v <= u_plus_v_div_x; alpha <= beta; beta <= alpha - 1;
      END IF;
      sync;
    END LOOP int_loop;
    z <= u; done <= '1'; sync;
  END LOOP ext_loop;
END PROCESS;
END data_flow;

