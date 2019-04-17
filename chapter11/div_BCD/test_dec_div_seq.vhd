--------------------------------------------------------------------------------
-- Testbench BCD divider
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
 
ENTITY test_dec_div_seq IS
END test_dec_div_seq;
 
ARCHITECTURE behavior OF test_dec_div_seq IS 
 
  constant NDIG :integer := 3;
  constant PDIG :integer := 3;
  constant LOGP :integer := 2;

--  component decimal_divider is 
--  component decimal_divider2 is 
--  component decimal_divider_nr2 is 
  component decimal_divider_nr_norm is 
--    component decimal_divider_srt_like is 
    generic (n: natural:= NDIG; p: natural := PDIG; logp: natural := LOGP);
    Port ( 
        x : in  STD_LOGIC_VECTOR (4*n+3 downto 0);
        y : in  STD_LOGIC_VECTOR (4*n-1 downto 0);
        clk, reset, start : in  STD_LOGIC;
        quotient : out  STD_LOGIC_VECTOR (4*p+3 downto 0);
        remainder : out  STD_LOGIC_VECTOR (4*n+3 downto 0);
        done : out  STD_LOGIC );
  end component;

   --Inputs
   signal a : std_logic_vector((NDIG+1)*4-1 downto 0) := (others => '0');
   signal b : std_logic_vector(NDIG*4-1 downto 0) := (others => '0');
   --signal cin : std_logic;

  --Outputs
   signal q : std_logic_vector(PDIG*4+3 downto 0);
   signal r : std_logic_vector(NDIG*4+3 downto 0);
   signal clk, reset, start, done : std_logic:= '0';
   
 	signal end_sim : boolean := false;
 	constant OFFSET : time := 10 ns;
	constant PERIOD : time := 50 ns; 

BEGIN

--	uut: decimal_divider --generic map(n <= NDIG, p <= PDIG, logp <= LOGP)
--	uut: decimal_divider2 --generic map(n <= NDIG, p <= PDIG, logp <= LOGP)
--	uut: decimal_divider_nr2 --generic map(n <= NDIG, p <= PDIG, logp <= LOGP)
   uut: decimal_divider_nr_norm --generic map(n <= NDIG, p <= PDIG, logp <= LOGP)
-- uut: decimal_divider_srt_like --generic map(n <= NDIG, p <= PDIG, logp <= LOGP)
          PORT MAP(	x => a, y => b, clk => clk,	reset => reset, start => start,	
                    quotient => q, remainder => r,	done => done);

	process
	begin
    wait for OFFSET;
		while not end_sim loop
			clk <= '0';
			wait for PERIOD/2;
			clk <= '1';
			wait for PERIOD/2;
		end loop;
		wait;
	end process;	
  
  process
  variable qq,rr,ii,jj,aux: integer;
  begin
    end_sim <= false;
    reset <= '1';
    wait for PERIOD;
		reset <= '0';
    wait for PERIOD;
    for w in 0 to 1 loop --w= 0 positivos, w=1 negativos
      for i in 0 to 10**(NDIG)-1 loop
        if w = 0 then
          a((NDIG+1)*4-1 downto (NDIG)*4) <= "0000"; ii := i;
        else 
          a((NDIG+1)*4-1 downto (NDIG)*4) <= "1001"; ii := i-1;
        end if;
        for k in 0 to NDIG-1 loop
          a((k+1)*4-1 downto k*4) <= conv_std_logic_vector(ii mod 10,4); 
          ii := ii/10; 
        end loop;
--        if w = 0 then aux := i+1; --for non normalized numbers
--        else aux := 10**(NDIG)-i+1; end if; 
        if w = 0 then -- if normalized didivid is required
          if i > 10**(NDIG-1) then aux := i; else aux := 10**(NDIG-1); end if;
        else
          aux := 10**(NDIG)-i;
          if aux < 10**(NDIG-1) then aux := 10**(NDIG-1); end if;
        end if; 
        for j in aux+1 to 10**NDIG-1 loop
          jj := j;
          for k in 0 to NDIG-1 loop
            b((k+1)*4-1 downto k*4) <= conv_std_logic_vector(jj mod 10,4);
            jj:= jj/10;
          end loop;
          start <= '1';
          wait for PERIOD;
          start <= '0';
          wait until done = '1';
          wait for 2*PERIOD;
          if q((PDIG+1)*4-1 downto PDIG*4) = "0000" then qq := 0; else qq := -10**PDIG; end if;
          for k in 0 to PDIG-1 loop
            qq := qq + conv_integer(q((k+1)*4-1 downto k*4))*(10**k);
          end loop;        
          rr := 0;
          if r((NDIG+1)*4-1 downto NDIG*4) < "0101" then rr := 0; else rr := -10**(NDIG+1); end if;
          for k in 0 to NDIG loop
            rr := rr + conv_integer(r((k+1)*4-1 downto k*4))*(10**k);
          end loop;
          ii := i*10**(NDIG);
          if w= 1 then ii:= (i-1-10**(NDIG) )*10**(NDIG); end if;
          ASSERT ( ii = j*qq + rr) REPORT "error div: " & integer'image(ii) & " /= " & integer'image(j) & " * " & integer'image(qq) & "  + " & integer'image(rr) SEVERITY ERROR;
          ASSERT ( abs(rr) < abs(j) ) REPORT "error rem >= div!: |" & integer'image(rr) & "| >= " & integer'image(j) SEVERITY note;
          ASSERT ( abs(rr) <= abs(j) ) REPORT "error rem >= div!: |" & integer'image(rr) & "| >= " & integer'image(j) SEVERITY ERROR;
         end loop;
      end loop;
    end loop;
  	end_sim <= true;
    ASSERT (FALSE) REPORT "NOT ERROR: end of simulation" SEVERITY FAILURE;
  end process;

END;
