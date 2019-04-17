----------------------------------------------------------------------------
-- test_decimal_divider.vhd
--
-- section 9.3 radix B divider (B=10)
--
-- Test bench FOR sequential division
--
----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
 
ENTITY test_decimal_divider IS
END test_decimal_divider;
 
ARCHITECTURE behavior OF test_decimal_divider IS 
   CONSTANT n: NATURAL:= 2;
   CONSTANT m: NATURAL:= 3;
   CONSTANT p: NATURAL:= 11;
   CONSTANT logp: NATURAL:= 4;
   CONSTANT NUM_SIM: NATURAL := 100;

   COMPONENT decimal_divider IS 
     GENERIC(n: NATURAL:= n; m : NATURAL:= m; p: NATURAL:= p;  logp: NATURAL:= logp);
   PORT(
     x: IN STD_LOGIC_VECTOR (4*n DOWNTO 0);
     y: IN STD_LOGIC_VECTOR (4*n-1 DOWNTO 0);
     clk, reset, start: IN STD_LOGIC;
     q: OUT STD_LOGIC_VECTOR (4*m DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   --Inputs
   SIGNAL a : std_logic_vecTOr(4*n DOWNTO 0) := (OTHERS => '0');
   SIGNAL b : std_logic_vecTOr(n*4-1 DOWNTO 0) := (OTHERS => '0');
   --SIGNAL cIN : std_logic;

  --Outputs
   SIGNAL q : std_logic_vecTOr(m*4 DOWNTO 0);
   SIGNAL clk, reset, start, done : std_logic:= '0';
   
 	SIGNAL END_sim : boolean := false;
 	CONSTANT OFFSET : time := 10 ns;
	CONSTANT PERIOD : time := 50 ns; 

BEGIN

   uut: decimal_divider GENERIC MAP(n => n, m => m, p => p, logp => logp)
          PORT MAP(	x => a, y => b, clk => clk, reset => reset, start => start,	q => q, done => done);
 
	PROCESS
	BEGIN
    WAIT FOR OFFSET;
		WHILE not END_sim LOOP
			clk <= '0';
			WAIT FOR PERIOD/2;
			clk <= '1';
			WAIT FOR PERIOD/2;
		END LOOP;
		WAIT;
	END PROCESS;	
  
  PROCESS
  VARIABLE qq,ii,jj,aux,dif,mult: INTEGER;
  BEGIN
    END_sim <= false;
    reset <= '1';
    WAIT FOR PERIOD;
		reset <= '0';
    WAIT FOR PERIOD;
    FOR w IN 0 TO 1 LOOP --w= 0 positive, w=1 negative
      FOR i IN 0 TO 10**n-1 LOOP
        ii := i;
        IF w = 0 then a(n*4) <= '0'; else a(n*4) <= '1'; END IF;
        FOR k IN 0 TO n-1 LOOP
          a((k+1)*4-1 DOWNTO k*4) <= conv_std_logic_vecTOr(ii mod 10,4); 
          ii := ii/10; 
        END LOOP;    
        -- if normalized didivid is required
        if w = 0 then aux := i; else aux := 10**(n)-i; end if;
        FOR j IN aux TO 10**n-1 LOOP -- y >= x        
          jj := j;
          FOR k IN 0 TO n-1 LOOP
            b((k+1)*4-1 DOWNTO k*4) <= conv_std_logic_vecTOr(jj mod 10,4);
            jj:= jj/10;
          END LOOP;
          start <= '1';
          WAIT FOR PERIOD;
          start <= '0';
          WAIT until done = '1';
          WAIT FOR 2*PERIOD;
          IF q(m*4) = '0' THEN qq := 0; ELSE qq := -10**m; END IF;
          FOR k IN 0 TO m-1 LOOP
            qq := qq + conv_INTEGER(q((k+1)*4-1 DOWNTO k*4))*(10**k);
          END LOOP;        
          --ii := i*10**(n);
          --IF w = 1 then ii:= (i-1-10**(n) )*10**(n); END IF;
          ii:= i;
          IF w = 0 then ii:= i; else ii:= -10**(n)+i; END IF;
          mult := j*qq/(10**(m));
          dif := ii - mult;
          ASSERT ( abs(dif) <= 1 ) REPORT "error div: " & INTEGER'image(ii) & " /= " & INTEGER'image(j) & " * " & INTEGER'image(qq)  & " / 10^" & INTEGER'image(m) 
                                       & " = " & INTEGER'image(mult) & "  dif: " & INTEGER'image(dif) SEVERITY ERROR;
         END LOOP;
      END LOOP;
    END LOOP;
  	END_sim <= true;
   REPORT "NOT ERROR: END of simulation";
   WAIT;
  END PROCESS;

END;
