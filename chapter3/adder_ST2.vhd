----------------------------------------------------------------------------
-- adder_ST.vhd
--
-- section 3.1.4 a self timed adder
-- 
------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY adder_ST2 IS
  GENERIC(n: NATURAL:= 32);
PORT (
  x, y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  c_in, reset: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  c_out, done: OUT STD_LOGIC
);
END adder_ST2;
  
ARCHITECTURE data_flow OF adder_ST2 IS
  SIGNAL carries, carriesb, eoc: STD_LOGIC_VECTOR(n DOWNTO 0); 
BEGIN

  adder: PROCESS(reset, carries, carriesb, eoc)
  BEGIN
    IF reset = '1' THEN carries <= (OTHERS => '0') AFTER 1 NS; 
      carriesb <= (OTHERS => '0') AFTER 1 NS; 
      eoc <= (OTHERS => '0') AFTER 1 NS;
    ELSE 
      carries(0) <= c_in; carriesb(0) <= NOT(c_in); eoc(0) <= '1';
      FOR i IN 0 TO n-1 LOOP
        carries(i+1) <= (x(i) AND y(i)) OR (x(i) AND carries(i)) OR (y(i) AND carries(i)) AFTER 1 NS;
        carriesb(i+1) <= (NOT(x(i)) AND NOT(y(i))) OR (NOT(x(i)) AND carriesb(i)) OR (NOT(y(i)) AND carriesb(i)) AFTER 1 NS;
        eoc(i+1) <= eoc(i) AND (carries(i+1) XOR carriesb(i+1)) AFTER 0.2 NS;
      END LOOP;
    END IF;
  END PROCESS;
  z <= x XOR y XOR carries(n-1 DOWNTO 0) AFTER 1 NS;
  c_out <= carries(n);
  done <= eoc(n);

--  end_detection: PROCESS(carries, carriesb)
--    VARIABLE acc: STD_LOGIC;
--  BEGIN
--    acc := '1'; 
--    FOR i IN 0 TO n LOOP
--      acc := acc AND (carries(i) XOR carriesb(i));
--    END LOOP;
--    done <= acc AFTER 5 NS;
--  END PROCESS;

END data_flow;

