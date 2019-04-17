--------------------------------------------------------------------------------
-- Testbench BCD addder/subtractor
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
 
ENTITY test_addsub IS
END test_addsub;
 
ARCHITECTURE behavior OF test_addsub IS 
 
  constant NDIG :integer := 2;
  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT addsubBCD_v1 is
  --COMPONENT addsubBCD_v2 is
  Generic (NDigit : integer := NDIG);
  Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
         addsub : in  STD_LOGIC;
         cout : out  STD_LOGIC;
         s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
  END COMPONENT;
  
  --Inputs
  signal a,b : std_logic_vector(NDIG*4-1 downto 0) := (others => '0');
  signal addsub : std_logic;

  --Outputs
  signal s : std_logic_vector(NDIG*4-1 downto 0);
  signal cout : std_logic;
   
BEGIN

  uut: addsubBCD_v1 PORT MAP (
--  uut: addsubBCD_v2 PORT MAP (
          a => a, b => b, addsub => addsub, cout => cout, s => s );

  process
    variable m1, m1b, m2,ii,jj,aux: integer;
  begin
  wait for 100 ns;
  for w in 0 to 1 loop
    if w = 0 then addsub <= '0'; else addsub <= '1'; end if;
    for i in 0 to 10**NDIG-1 loop
      for j in 0 to 10**NDIG-1 loop
        ii := i; jj := j;
        for k in 0 to NDIG-1 loop
          a((k+1)*4-1 downto k*4) <= conv_std_logic_vector(ii mod 10,4); 
          b((k+1)*4-1 downto k*4) <= conv_std_logic_vector(jj mod 10,4);
          ii := ii/10; jj:= jj/10;
        end loop;
        wait for 100 ns;
        if w = 0 then --addition
          m1 := i+j;
          if cout = '0' then m2 := 0;
          else m2 := 10**NDIG; end if;
          for k in 0 to NDIG-1 loop
            assert conv_integer(s((k+1)*4-1 downto k*4)) < 10 REPORT "error digit > 10!!!" SEVERITY ERROR; 
            m2 := m2 + conv_integer(s((k+1)*4-1 downto k*4))*(10**k);
          end loop;
          ASSERT (m1 = m2) REPORT "error sum/sub: " & integer'image(i) & " + " & integer'image(j) & 
                                  " = " & integer'image(m1) & "  /= res: " & integer'image(m2) SEVERITY ERROR;
         else --subtraction
          m1 := i-j; m1b := 10**NDIG + m1; 
          if cout = '0' then m2 := 0;
          else m2 := 10**NDIG; end if;
          for k in 0 to NDIG-1 loop
            m2 := m2 + conv_integer(s((k+1)*4-1 downto k*4))*(10**k);
          end loop;
          ASSERT (m1b = m2) REPORT "error sum/sub: " & integer'image(i) & " - " & integer'image(j) & 
                                  " = " & integer'image(m1) & " (" & integer'image(m1b) & ") /= res: " & integer'image(m2) SEVERITY ERROR;
         
         end if;
       end loop;
    end loop;
  end loop;  
  
  ASSERT (FALSE) REPORT "NOT ERROR: end of simulation" SEVERITY FAILURE;

end process;

END;
