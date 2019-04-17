----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_six_to_three_counter_cell IS
END test_six_to_three_counter_cell;

ARCHITECTURE test OF test_six_to_three_counter_cell IS
  COMPONENT six_to_three_counter_cell IS
  PORT (
    x: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL x: STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL z: STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
  dut: six_to_three_counter_cell
  PORT MAP(x => x, z => z);
  PROCESS
  BEGIN
    FOR i IN 0 TO 63 LOOP
      x <= CONV_STD_LOGIC_VECTOR(i, 6);
      WAIT FOR 100 NS;
    END LOOP;
  END PROCESS;
END test;
