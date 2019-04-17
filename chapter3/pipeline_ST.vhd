----------------------------------------------------------------------------
-- pipeline_ST.vhd
--
-- Implements the scalar product in GF(2**m) using pipeline Self Timed Circuit.
-- section 3.1.4 (not a synthesizable circuit)
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
ENTITY protocol IS
PORT (
  clk, reset, req_in, ack_in, done: IN STD_LOGIC;
  req_out, ack_out, ce, start: OUT STD_LOGIC
);
END protocol;

ARCHITECTURE data_flow OF protocol IS
  PROCEDURE sync IS
  BEGIN
    WAIT UNTIL clk'EVENT AND clk = '1';
  END sync;
--  SIGNAL ready: STD_LOGIC;
BEGIN
  PROCESS
  BEGIN
   ce <= '0'; start <= '0'; req_out <= '0'; ack_out <= '0'; sync;
    LOOP
      IF reset = '1' THEN EXIT; END IF;
      IF req_in = '1'THEN
        ce <= '1'; sync;
        ce <= '0'; ack_out <= '1'; sync; 
        ack_out <= '0'; start <= '1'; sync;
        start <= '0';
        WAIT UNTIL done = '1';
        req_out <= '1';
        WAIT UNTIL ack_in = '1';
        req_out <= '0'; sync;
      ELSE sync;
      END IF;  
    END LOOP;
  END PROCESS;
END data_flow;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.pipeline_parameters.ALL;
ENTITY pipeline_ST IS
PORT (
  xP, xA, zA, xB, zB: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  clk, reset, req_in, ack_in: IN STD_LOGIC;
  g, d, l, i: OUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  req_out, ack_out: OUT STD_LOGIC
);
END pipeline_ST;

ARCHITECTURE data_flow OF pipeline_ST IS

  PROCEDURE sync IS
  BEGIN
    WAIT UNTIL clk'EVENT AND clk = '1';
  END sync;

  COMPONENT protocol IS
  PORT (
    clk, reset, req_in, ack_in, done: IN STD_LOGIC;
    req_out, ack_out, ce, start: OUT STD_LOGIC
  );
  END COMPONENT;

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

  SIGNAL ce1, ce2, ce3, ce4,
  start1, start2, start3, start4, start5, 
  done1, done2, done3, done4, done5, end2, end4, end5,
  req0, req1, req2, req3, req4, req5,
  ack0, ack1, ack2, ack3, ack4, ack5: STD_LOGIC;

BEGIN
  req0 <= req_in;
  ack5 <= ack_in;
  req_out <= req5;
  ack_out <= ack0;
  protocol1: protocol PORT MAP (clk => clk, reset => reset, req_in => req0, ack_in => ack1, 
    done => done1, req_out => req1, ack_out => ack0, start => start1);
  protocol2: protocol PORT MAP (clk => clk, reset => reset, req_in => req1, ack_in => ack2, 
    done => done2, req_out => req2, ack_out => ack1, ce => ce1, start => start2);
  protocol3: protocol PORT MAP (clk => clk, reset => reset, req_in => req2, ack_in => ack3, 
    done => done3, req_out => req3, ack_out => ack2, ce => ce2, start => start3);
  protocol4: protocol PORT MAP (clk => clk, reset => reset, req_in => req3, ack_in => ack4, 
    done => done4, req_out => req4, ack_out => ack3, ce => ce3, start => start4);
  protocol5: protocol PORT MAP (clk => clk, reset => reset, req_in => req4, ack_in => ack5, 
    done => done5, req_out => req5, ack_out => ack4, ce => ce4, start => start5);
  mod_f_multiplier1: interleaved_mult PORT MAP (A => xA, B => ZB, clk => clk, reset => reset, start => start1, Z => a, done => done1);
  mod_f_multiplier2: interleaved_mult PORT MAP (A => xB1, B => ZA1, clk => clk, reset => reset, start => start2, Z => b1, done => end2);
  mod_f_multiplier3: interleaved_mult PORT MAP (A => xP2, B => d2, clk => clk, reset => reset, start => start3, Z => e2, done => done3);
  mod_f_multiplier4: interleaved_mult PORT MAP (A => a3, B => b3, clk => clk, reset => reset, start => start4, Z => f3, done => end4);
  mod_f_multiplier5: interleaved_mult PORT MAP (A => zA4, B => xA4, clk => clk, reset => reset, start => start5, Z => h4, done => end5);
  squarer1: classic_squarer PORT MAP (a => c1, c => d1);
  squarer2: classic_squarer PORT MAP (a => j4, c => k4);
  squarer3: classic_squarer PORT MAP (a => k4, c => l);
  squarer4: classic_squarer PORT MAP (a => h4, c => i);
  c1 <= a1 XOR b1;
  g3 <= e3 XOR f3;
  j4 <= zA4 XOR xA4;
  register1: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF ce1 = '1' THEN 
        xP1 <= xP; a1 <= a; xB1 <= xB; zA1 <= zA; xA1 <= xA;
      END IF;
    END IF;
  END PROCESS;
  register2: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF ce2 = '1' THEN 
        xP2 <= xP1; a2 <= a1; d2 <= d1; b2 <= b1; zA2 <= zA1; xA2 <= xA1;
      END IF;
    END IF;
  END PROCESS;
  register3: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF ce3 = '1' THEN 
        e3 <= e2; a3 <= a2; d3 <= d2; b3 <= b2; zA3 <= zA2; xA3 <= xA2;
      END IF;
    END IF;
  END PROCESS;
  register4: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF ce4 = '1' THEN 
        g <= g3; d <= d3; zA4 <= zA3; xA4 <= xA3;
      END IF;
    END IF;
  END PROCESS;
  segment2: PROCESS
  BEGIN
    WAIT UNTIL end2'EVENT;
    IF end2 = '1' THEN
      sync;
      sync;
      done2 <= '1';
    ELSE done2 <= '0';
    END IF;
  END PROCESS;
  segment4: PROCESS
  BEGIN
    WAIT UNTIL end4'EVENT;
    IF end4 = '1' THEN
      sync;
      done4 <= '1';
    ELSE done4 <= '0';
    END IF;
  END PROCESS;
  segment5: PROCESS
  BEGIN
    WAIT UNTIL end5'EVENT;
    IF end5 = '1' THEN
      sync;
      sync;
      done5 <= '1';
    ELSE done5 <= '0';
    END IF;
  END PROCESS;
END data_flow;
