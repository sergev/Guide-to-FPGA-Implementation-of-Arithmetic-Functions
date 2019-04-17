--------------------------------------------------------------------------------
-- Testbench BCD addder
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
 
ENTITY test_adder_BCD IS
END test_adder_BCD;
 
ARCHITECTURE behavior OF test_adder_BCD IS 
 
constant NDIG :integer := 2;
    -- Component Declaration for the Unit Under Test (UUT)
    ---COMPONENT ripple_adder_BCD is
    COMPONENT cych_adder_BCD_V2 is
    --COMPONENT cych_adder_BCD_V1 is
    Generic (NDigit : integer := NDIG);
    Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
    END COMPONENT;

   --Inputs
   signal a,b : std_logic_vector(NDIG*4-1 downto 0) := (others => '0');
   signal cin : std_logic;

  --Outputs
   signal s : std_logic_vector(NDIG*4-1 downto 0);
   signal cout : std_logic;
   

BEGIN

   --uut:  ripple_adder_BCD PORT MAP ( 
   uut:  cych_adder_BCD_V2 PORT MAP ( 
   --uut:  cych_adder_BCD_V1 PORT MAP ( 
          a => a, b => b, cin => cin, cout => cout, s => s );

  process
  variable m1, m2,ii,jj,aux: integer;
  begin
  wait for 100 ns;
  for w in 0 to 1 loop
    if w = 0 then cin <= '0'; else cin <= '1'; end if;
    for i in 0 to 10**NDIG-1 loop
      for j in 0 to 10**NDIG-1 loop
        ii := i; jj := j;
        for k in 0 to NDIG-1 loop
          a((k+1)*4-1 downto k*4) <= conv_std_logic_vector(ii mod 10,4); 
          b((k+1)*4-1 downto k*4) <= conv_std_logic_vector(jj mod 10,4);
          ii := ii/10; jj:= jj/10;
        end loop;
        wait for 100 ns;
        m1 := i+j+w;
        if cout = '0' then m2 := 0;
        else m2 := 10**NDIG; end if;
        for k in 0 to NDIG-1 loop
          m2 := m2 + conv_integer(s((k+1)*4-1 downto k*4))*(10**k);
        end loop;
        ASSERT (m1 = m2) REPORT "error mult: " & integer'image(i) & " + " & integer'image(j) & " = " & integer'image(m1) & "  /= res: " & integer'image(m2) SEVERITY ERROR;
       end loop;
    end loop;
  end loop;  
  
  ASSERT (FALSE) REPORT "NOT ERROR: end of simulation" SEVERITY FAILURE;

end process;

END;
