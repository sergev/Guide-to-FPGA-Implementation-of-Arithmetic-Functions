------------------------------------------------------------------
-- BCD mult by one BCD (1 by N)
-- Simple version. Uses 1x1 BCD multiplications
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity mult_Nx1_BCD is
	Generic (NDigit : integer:= 4);
   Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           p : out  STD_LOGIC_VECTOR ((NDigit+1)*4-1 downto 0));
end mult_Nx1_BCD;

architecture Behavioral of mult_Nx1_BCD is

  --    COMPONENT bcd_mul_arith1
  --    COMPONENT bcd_mul_arith2
  --    COMPONENT bcd_mul_mem1
  COMPONENT bcd_mul_mem2
  PORT(a, b : IN  std_logic_vector(3 downto 0);
       c, d : OUT  std_logic_vector(3 downto 0) );
  end component;

--  component cych_adder_BCD_v1 is
  component cych_adder_BCD_v2 is
  Generic (NDigit : integer:=4);
  Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
         cin : in  STD_LOGIC;
         cout : out  STD_LOGIC;
         s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
  end component;

  type partialMul is array (NDigit-1 downto 0) of STD_LOGIC_VECTOR (3 downto 0);
  signal c, d: partialMul;
  signal op_c, op_d, sum : STD_LOGIC_VECTOR (NDigit*4-1 downto 0);

begin 
 
	GenMuls: for i in 0 to NDigit-1 generate
   begin
    --  mult: bcd_mul_mem1 PORT MAP (
    mult: bcd_mul_mem2 PORT MAP (
          a => a((i+1)*4-1 downto i*4), b => b, c => c(i), d => d(i) );
	end generate;	

  op_c(NDigit*4-1 downto (NDigit-1)*4) <= (others => '0'); 
  op_d(NDigit*4-1 downto (NDigit-1)*4) <= d(NDigit-1); 
	GenOps: for i in 0 to NDigit-2 generate
        op_d((i+1)*4-1 downto i*4) <= d(i); 
        op_c((i+1)*4-1 downto i*4) <= c(i+1);
	end generate;	

--	adder: cych_adder_BCD_v1 generic map (NDIGIT => NDigit) 
	adder: cych_adder_BCD_v2 generic map (NDIGIT => NDigit) 
          PORT MAP( a => op_c, b => op_d, cin => '0', cout => open,	s => sum );
  
  p((NDigit+1)*4-1 downto 4) <= sum;
  p(3 downto 0) <= c(0);

end Behavioral;

