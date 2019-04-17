----------------------------------------------------------------------------
-- pipeline_DF2.vhd
--
-- Implements the scalar product in GF(2**m) using pipeline.
-- section 3.1.3 (not a synthesizable circuit)
-- Uses interlived_multiplier and clasic squares defined in ch2
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE pipeline_parameters IS
  CONSTANT M: INTEGER := 163;
  CONSTANT delta: NATURAL := 30000;--delta = interval between successive inputs
END pipeline_parameters;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.pipeline_parameters.ALL;
ENTITY pipeline_DF2 IS
PORT (
    xP, xA, zA, xB, zB: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    clk, reset: IN STD_LOGIC;
    g, d, l, i: OUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    time_out: INOUT STD_LOGIC
);
END pipeline_DF2;

ARCHITECTURE data_flow OF pipeline_DF2 IS

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

SIGNAL a, 
xP1, a1, xB1, zA1, xA1, b1, c1, d1, 
xP2, a2, d2, b2, zA2, xA2, e2,
e3, a3, d3, b3, zA3, xA3, f3, g3,
zA4, xA4, j4, k4, h4: STD_LOGIC_VECTOR (M-1 DOWNTO 0);

SIGNAL start: STD_LOGIC;

PROCEDURE sync IS
BEGIN
  WAIT UNTIL clk'EVENT AND clk = '1';
END sync;

BEGIN

mod_f_multiplier1: interleaved_mult PORT MAP (A => xA, B => ZB, clk => clk, reset => reset, start => start, Z => a);
mod_f_multiplier2: interleaved_mult PORT MAP (A => xB1, B => ZA1, clk => clk, reset => reset, start => start, Z => b1);
mod_f_multiplier3: interleaved_mult PORT MAP (A => xP2, B => d2, clk => clk, reset => reset, start => start, Z => e2);
mod_f_multiplier4: interleaved_mult PORT MAP (A => a3, B => b3, clk => clk, reset => reset, start => start, Z => f3);
mod_f_multiplier5: interleaved_mult PORT MAP (A => zA4, B => xA4, clk => clk, reset => reset, start => start, Z => h4);
squarer1: classic_squarer PORT MAP (a => c1, c => d1);
squarer2: classic_squarer PORT MAP (a => j4, c => k4);
squarer3: classic_squarer PORT MAP (a => k4, c => l);
squarer4: classic_squarer PORT MAP (a => h4, c => i);
c1 <= a1 XOR b1;
g3 <= e3 XOR f3;
j4 <= zA4 XOR xA4;

segment1: PROCESS
BEGIN
--  WAIT UNTIL time_out = '0';
  WAIT UNTIL time_out = '1'; 
  xP1 <= xP; a1 <= a; xB1 <= xB; zA1 <= zA; xA1 <= xA;
END PROCESS;

segment2: PROCESS
BEGIN
--  WAIT UNTIL time_out = '0';
  WAIT UNTIL time_out = '1'; 
  xP2 <= xP1; a2 <= a1; d2 <= d1; b2 <= b1; zA2 <= zA1; xA2 <= xA1;
END PROCESS;

segment3: PROCESS
BEGIN
--  WAIT UNTIL time_out = '0';
  WAIT UNTIL time_out = '1'; 
  e3 <= e2; a3 <= a2; d3 <= d2; b3 <= b2; zA3 <= zA2; xA3 <= xA2;
END PROCESS;
      
segment4: PROCESS
BEGIN
--  WAIT UNTIL time_out = '0';
  WAIT UNTIL time_out = '1'; 
  g <= g3; d <= d3; zA4 <= zA3; xA4 <= xA3;
END PROCESS;
 
control_unit: PROCESS    
BEGIN
  LOOP
    time_out <= '0'; start <= '0'; sync;
    IF reset = '1' THEN EXIT; END IF;
    start <= '1'; sync;
    FOR i IN 1 TO delta-3 LOOP
      sync;
    END LOOP;
    time_out <= '1'; sync;
  END LOOP;
END PROCESS;
    
END data_flow;

