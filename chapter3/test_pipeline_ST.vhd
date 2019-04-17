----------------------------------------------------------------------------
-- test_pipeline_ST.vhd
--
-- section 3.1.4
--
-- Simple test bench for Self Timed scalar product in GF(2**m)
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.pipeline_parameters.ALL;
ENTITY test_pipeline_ST IS END test_pipeline_ST;

ARCHITECTURE test OF test_pipeline_ST IS

  COMPONENT pipeline_ST IS
  PORT (
   xP, xA, zA, xB, zB: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
   clk, reset, req_in, ack_in: IN STD_LOGIC;
   g, d, l, i: OUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
   req_out, ack_out: OUT STD_LOGIC
  );
  END COMPONENT;

  SIGNAL xP, xA, zA, xB, zB, g, d, l, i: STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  SIGNAL clk: STD_LOGIC := '0';
  SIGNAL reset, req_in, ack_in, req_out, ack_out: STD_LOGIC;

  PROCEDURE sync IS
  BEGIN
    WAIT UNTIL clk'EVENT AND clk = '1';
  END sync;

BEGIN

  clk <= NOT(clk) AFTER 50 NS;
  
  dut: pipeline_ST PORT MAP (
    xP => xP, xA => xA, zA => zA, xB => xB, zB => zB, 
    clk => clk, reset => reset, req_in => req_in, ack_in => ack_in,
    g => g, d => d, l => l, i => i, 
    req_out => req_out, ack_out => ack_out
    );
  
  input_data: PROCESS
  BEGIN
    xP <= "010"&x"fe13c0537bbc11acaa07d793de4e6d5e5c94eee8";
    xA <= "010"&x"fe13c0537bbc11acaa07d793de4e6d5e5c94eee0";
    xB <= "010"&x"fe13c0537bbc11acaa07d793de4e6d5e5c94ee00";
    zA <= "010"&x"fe13c0537bbc11acaa07d793de4e6d5e5c94e000";
    zB <= "010"&x"fe13c0537bbc11acaa07d793de4e6d5e5c940000";
    req_in <= '0';
    reset <= '1'; sync;
    reset <= '0'; sync;
    LOOP
      req_in <= '1'; 
      WAIT UNTIL ack_out = '1';
      req_in <= '0';
      sync; sync; sync;
    END LOOP;
  END PROCESS;
      
  output_data: PROCESS
  BEGIN
    ack_in <= '0'; 
    LOOP
      IF req_out = '1'THEN
        ack_in <= '1'; sync; 
        ack_in <= '0'; sync;
      ELSE sync;
      END IF;  
    END LOOP;
  END PROCESS;
END test;
    