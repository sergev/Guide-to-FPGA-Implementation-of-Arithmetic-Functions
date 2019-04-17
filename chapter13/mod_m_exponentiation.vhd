----------------------------------------------------------------------------
-- mod_m_exponentiation.vhd
--
-- section 13.1.2.3 Motgomery multiplier use for exponentiaition.
--
-- exp_k = 2^k mod m
-- exp_2k = 2^(2k) mod m
-- z = y^x mod m
--
-- Behavioural model (not synthezible)
--
----------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE mod_m_exponentiation_package IS
  CONSTANT k: NATURAL := 8;
  CONSTANT exp_k: STD_LOGIC_VECTOR(k-1 DOWNTO 0) := x"11"; --17d
  CONSTANT exp_2k: STD_LOGIC_VECTOR(k-1 DOWNTO 0) := x"32"; --50d
  CONSTANT one: STD_LOGIC_VECTOR(k-1 DOWNTO 0) := x"01"; 
END mod_m_exponentiation_package;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.mod_m_exponentiation_package.ALL;
ENTITY mod_m_exponentiation IS
PORT (
    x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    done: OUT STD_LOGIC 
    );
END mod_m_exponentiation;

ARCHITECTURE data_flow OF mod_m_exponentiation IS

COMPONENT Montgomery_multiplier IS
PORT(
  x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  clk, reset, start: STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END COMPONENT;

SIGNAL te, ty, y1, x2, y2, z1, z2: STD_LOGIC_VECTOR (k-1 DOWNTO 0);
SIGNAL start1, done1, start2, done2: STD_LOGIC;

PROCEDURE sync IS
BEGIN
  WAIT UNTIL clk'EVENT AND clk = '1';
END sync;

BEGIN

MP1: Montgomery_multiplier PORT MAP (
  x => te, y => y1, clk => clk, reset => reset, start => start1, z => z1, done => done1);

MP2: Montgomery_multiplier PORT MAP (
  x => x2, y => y2, clk => clk, reset => reset, start => start2, z => z2, done => done2);

PROCESS
BEGIN
  start1 <= '0'; start2 <= '0'; 
  ext_loop: LOOP
--    WAIT UNTIL start = '0';
    WAIT UNTIL start = '1';
    te <= exp_k; start1 <= '0'; start2 <= '0'; done <= '0'; sync;
    x2 <= y; y2 <= exp_2k; start2 <= '1'; sync;
    start2 <= '0'; sync;
    WAIT UNTIL done2 = '1';
    ty <= z2; sync;
    FOR i in 0 TO k-1 LOOP
      IF reset = '1' THEN EXIT ext_loop; END IF;
      IF x(i) = '1' THEN
        x2 <= ty; y2 <= ty; start2 <= '1'; y1 <= ty; start1 <= '1'; sync; 
        start1 <= '0'; start2 <= '0'; sync;         
        WAIT UNTIL (done1 AND done2) = '1';
        te <= z1; ty <= z2; sync;
      ELSE
        x2 <= ty; y2 <= ty; start2 <= '1'; sync;
        start2 <= '0'; sync;
        WAIT UNTIL done2 = '1';
        ty <= z2; sync;
      END IF;
    END LOOP;
    y1 <= one; start1 <= '1'; sync;
    start1 <= '0'; sync;
    WAIT UNTIL done1 = '1';
    z <= z1; done <= '1'; sync;
  END LOOP ext_loop;
END PROCESS;
END data_flow;
