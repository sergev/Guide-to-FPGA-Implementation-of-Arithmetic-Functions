----------------------------------------------------------------------------
-- SquareRootNR4.vhd
--
-- section 10.3 Square Rooters. Newton-Raphson Algorithm (10.3.4)
--
-- x = x2n-1 x2n-2 ... x0: natural (2*n bits)
-- root = qn+p-1 qn+p-2 ... qp.qp-1 qp-2 ... q0: natural (n+p bits)
-- x = q^2 + r, i.e q^2 <= x < (q+1)^2
-- gives as result n bits plus p fractional bits.
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE package_SquareRoot IS
  TYPE table IS ARRAY(0 TO 15) OF STD_LOGIC_VECTOR(4 DOWNTO 0);
  CONSTANT table_x0: table := ( "00001", "00101", "00110", "00111", "01001", "01001", "01010", "01011",
  "01100", "01101", "01101", "01110", "01110", "01111", "01111", "10000" );
END package_SquareRoot;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.package_SquareRoot.ALL;

ENTITY SquareRootNR4 IS
  GENERIC(n: NATURAL:= 32; p: NATURAL:= 32);
PORT(
  x: IN STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  root: OUT STD_LOGIC_VECTOR(n+p-1 DOWNTO 0);
  done: OUT STD_LOGIC
);
END SquareRootNR4;

ARCHITECTURE circuit OF SquareRootNR4 IS
  COMPONENT restoring3 IS
    GENERIC(n, p: NATURAL);
  PORT(
    x: IN STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
    y: IN STD_LOGIC_VECTOR(n+p DOWNTO 0);
    clk, reset, start:IN STD_LOGIC;
    quotient: OUT STD_LOGIC_VECTOR(n+p-1 DOWNTO 0);
    remainder: OUT STD_LOGIC_VECTOR(n+p DOWNTO 0);
    done: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL quotient: STD_LOGIC_VECTOR(n+p-1 DOWNTO 0);
  SIGNAL y, next_y, initial_y: STD_LOGIC_VECTOR(n+p DOWNTO 0);
  SIGNAL long_quotient, sum: STD_LOGIC_VECTOR(n+p DOWNTO 0);
  SIGNAL start_div, div_done, load, update: STD_LOGIC;
  SIGNAL first_bits: STD_LOGIC_VECTOR(3 DOWNTO 0);
  TYPE state IS RANGE 0 TO 6;
  SIGNAL current_state: state;
  
BEGIN

  first_bits <= x(2*n-1 DOWNTO 2*n-4);
  
  initial_y(n+p DOWNTO n+p-4) <= table_x0(CONV_INTEGER(first_bits));
  
  initial_y(n+p-5 DOWNTO 0) <= (OTHERS => '0');
  
  main_component: restoring3 GENERIC MAP(n => n, p => p)
    PORT MAP(x => x, y => y, clk => clk, reset => reset, start => start_div, quotient => quotient, done => div_done);
  long_quotient <= '0'&quotient; 
  sum <= long_quotient + y;
  next_y <= '0'&sum(n+p DOWNTO 1);   

  register_y: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN y <= initial_y;
      ELSIF update = '1' THEN y <= next_y; 
      END IF;  
    END IF;
  END PROCESS;
  root <= next_y(n+p-1 DOWNTO 0);
  
  next_state: PROCESS(clk)
  BEGIN
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
        WHEN 2 => current_state <= 3;
        WHEN 3 => current_state <= 4;
        WHEN 4 => IF div_done = '1' THEN current_state <= 5; END IF;
        WHEN 5 => current_state <= 6;
        WHEN 6 => IF y = next_y THEN current_state <= 0; ELSE current_state <= 3; END IF;      
      END CASE;
    END IF;
  END PROCESS;

  output_function: PROCESS(clk, current_state)
  BEGIN
    CASE current_state IS
      WHEN 0 TO 1 => load <= '0'; update <= '0'; start_div <= '0'; done <= '1';
      WHEN 2 => load <= '1'; update <= '1'; start_div <= '0'; done <= '0';
      WHEN 3 => load <= '0'; update <= '0'; start_div <= '1'; done <= '0';
      WHEN 4 => load <= '0'; update <= '0'; start_div <= '0'; done <= '0';
      WHEN 5 => load <= '0'; update <= '1'; start_div <= '0'; done <= '0';
      WHEN 6 => load <= '0'; update <= '0'; start_div <= '0'; done <= '0';      
    END CASE;
  END PROCESS;
   
END circuit;
