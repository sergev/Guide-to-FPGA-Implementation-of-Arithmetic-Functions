------------------------------------------------------------------
-- BCD mult by one BCD (1 by N)
-- Return a carry save representation of result.
-- p = s + c*10 = a*b
-- Simple version
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity mult_Nx1_BCD_carrysave is
   Generic (NDigit : integer:=8);
   Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           s,c : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end mult_Nx1_BCD_carrysave;

architecture Behavioral of mult_Nx1_BCD_carrysave is
  -- any basic cell is posible
  component bcd_mul_mem2
  PORT(a, b : IN  std_logic_vector(3 downto 0);
       c, d : OUT  std_logic_vector(3 downto 0) );
  end component;

  type partialMul is array (NDigit-1 downto 0) of STD_LOGIC_VECTOR (3 downto 0);
  signal e, f: partialMul;

begin 
 
	GenMuls: for i in 0 to NDigit-1 generate
    begin
    mult: bcd_mul_mem2 PORT MAP (
          a => a((i+1)*4-1 downto i*4), b => b, c => e(i), d => f(i) );
	end generate;	

	GenOps: for i in 0 to NDigit-1 generate
        c((i+1)*4-1 downto i*4) <= f(i); 
        s((i+1)*4-1 downto i*4) <= e(i);
	end generate;	

end Behavioral;

