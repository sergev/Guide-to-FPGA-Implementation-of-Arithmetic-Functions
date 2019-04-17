--------------------------------------------------------------------------------
-- Testbench BCD addder
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
 
ENTITY test_mult_comb IS
END test_mult_comb;
 
ARCHITECTURE behavior OF test_mult_comb IS 
 
constant NDIG :integer := 2;
constant MDIG :integer := 4;
    -- Component Declaration for the Unit Under Test (UUT)
   COMPONENT mult_BCD_comb is
	Generic (NDigit : integer:=NDIG; MDigit : integer:=MDIG);
   Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (MDigit*4-1 downto 0);
           p : out  STD_LOGIC_VECTOR ((NDigit+MDigit)*4-1 downto 0));
   END COMPONENT;

   --Inputs
   signal a : std_logic_vector(NDIG*4-1 downto 0) := (others => '0');
   signal b : std_logic_vector(MDIG*4-1 downto 0) := (others => '0');

  --Outputs
   signal p : std_logic_vector((NDIG+MDIG)*4-1 downto 0);
 

BEGIN

   uut: mult_BCD_comb PORT MAP (a => a, b => b, p => p );

  process
  variable m1, m2,ii,jj,aux: integer;
  begin
    wait for 100 ns;
    for i in 0 to 10**NDIG-1 loop
      ii := i;
      for k in 0 to NDIG-1 loop
        a((k+1)*4-1 downto k*4) <= conv_std_logic_vector(ii mod 10,4); 
        ii := ii/10; 
      end loop;
      for j in 0 to 10**MDIG-1 loop
        jj := j;
        for k in 0 to MDIG-1 loop
          b((k+1)*4-1 downto k*4) <= conv_std_logic_vector(jj mod 10,4);
          jj:= jj/10;
        end loop;
        wait for 100 ns;
        m1 := i*j;
        m2 := 0;
        for k in 0 to NDIG+MDIG-1 loop
          m2 := m2 + conv_integer(p((k+1)*4-1 downto k*4))*(10**k);
        end loop;
        ASSERT (m1 = m2) REPORT "error mult: " & integer'image(i) & " * " & integer'image(j) & " = " & integer'image(m1) & "  /= res: " & integer'image(m2) SEVERITY ERROR;
       end loop;
    end loop;
 
    ASSERT (FALSE) REPORT "NOT ERROR: end of simulation" SEVERITY FAILURE;

end process;

END;
