----------------------------------------------------------------------------
-- test_DecimalToBinary2.vhd
--
-- section 10.2 radix-B to Binary conversion.  decimal to binary.
--
-- Simple Test bench for sequential Binary to radix-B conversion
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_DecimalToBinary2 IS 
END test_DecimalToBinary2;

ARCHITECTURE test OF test_DecimalToBinary2 IS
  COMPONENT DecimalToBinary2 IS
    GENERIC(n, m, logn: NATURAL);
  PORT(
  x: IN STD_LOGIC_VECTOR(4*m-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  z: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  done:OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL x: STD_LOGIC_VECTOR(19 DOWNTO 0);
  SIGNAL clk: STD_LOGIC := '0';
  SIGNAL reset, start, done: STD_LOGIC;
  SIGNAL z: STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
  dut: DecimalToBinary2 
       GENERIC MAP(n => 16, m => 5, logn => 4)
       PORT MAP(x => x, clk => clk, reset => reset, start => start, z => z, done => done);

  clk <= NOT(clk) AFTER 50 NS;
 
  PROCESS
    VARIABLE x4, x3, x2, x1, x0, decimal_x: NATURAL;
  BEGIN
    reset <= '1';
    start <= '0';
    WAIT FOR 100 NS;
    reset <= '0';
    FOR x4 IN 0 TO 9 LOOP
      FOR x3 IN 0 TO 9 LOOP
        FOR x2 IN 0 TO 9 LOOP
          FOR x1 IN 0 TO 9 LOOP
            FOR x0 IN 0 TO 9 LOOP 
               x <= CONV_STD_LOGIC_VECTOR(x4,4)
                    & CONV_STD_LOGIC_VECTOR(x3,4)
                    & CONV_STD_LOGIC_VECTOR(x2,4)
                    & CONV_STD_LOGIC_VECTOR(x1,4)
                    & CONV_STD_LOGIC_VECTOR(x0,4);
               WAIT FOR 100 NS;
               start <= '1';
               WAIT FOR 100 NS;
               start <= '0';
               WAIT UNTIL done = '1';
               WAIT FOR 100 NS;
               decimal_x := x4*10000 + x3*1000 +x2*100 +x1*10 +x0;
               IF decimal_x < 65536 THEN      
                 ASSERT decimal_x = CONV_INTEGER(z)
                 REPORT "uncorrect conversion"
                 SEVERITY ERROR;
               ELSE 
                 ASSERT false 
                 REPORT "No errors in simultion" 
                 SEVERITY FAILURE;               
               WAIT;
               END IF;
            END LOOP;
          END LOOP;
        END LOOP;
      END LOOP;
    END LOOP;

  END PROCESS;
  
END test;
  