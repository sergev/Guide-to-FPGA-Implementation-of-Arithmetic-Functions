----------------------------------------------------------------------------
-- test_carry_select_adder.vhd
--
-- section 7.4
--
-- exhaustive test bench for addition
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY test_carry_select_adder IS 
END test_carry_select_adder;

ARCHITECTURE test OF test_carry_select_adder IS
  CONSTANT k: natural:= 2;
  CONSTANT m: natural:= 3;
--  CONSTANT k: natural:= 3;
--  CONSTANT m: natural:= 4;
  
  COMPONENT carry_select_adder IS
    GENERIC(k, m: NATURAL);
  PORT(
    x, y: IN STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
    c_in: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
    c_out: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL x, y: STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  SIGNAL c_in: STD_LOGIC;
  SIGNAL z: STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  SIGNAL zz: STD_LOGIC_VECTOR(k*m DOWNTO 0);
  SIGNAL c_out: STD_LOGIC;
  
  CONSTANT DELAY : time := 50 ns; 
BEGIN

  dut: carry_select_adder GENERIC MAP(k => k, m => m)
  PORT MAP(x => x, y => y, c_in => c_in, z => z, c_out => c_out);
  
  zz <= ('0' & x) + y + c_in;

  stimuli: PROCESS
  BEGIN
  FOR i IN 0 TO 2**(k*m)-1 LOOP
    FOR j IN 0 TO 2**(k*m)-1 LOOP
      c_in <= '0';
      x <= conv_std_logic_vector(i,k*m); 
      y <= conv_std_logic_vector(j,k*m); 
      wait for DELAY;
      ASSERT ( z = zz(k*m-1 DOWNTO 0)) REPORT "error in addition: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;
      ASSERT ( c_out = zz(k*m)) REPORT "error in c_out: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;

      c_in <= '1';
      wait for DELAY;
      ASSERT ( z = zz(k*m-1 DOWNTO 0)) REPORT "error in addition: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;
      ASSERT ( c_out = zz(k*m)) REPORT "error in c_out: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;      
    END LOOP;
  END LOOP;
  REPORT "simulation OK";
  WAIT;
  END PROCESS;

END test;