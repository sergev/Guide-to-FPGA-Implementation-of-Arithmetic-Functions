------------------------------------------------------------------
-- BCD multiplier N by M digits
-- Fully combiational
-- Simple version
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use work.my_package.all;
--library UNISIM;
--use UNISIM.VComponents.all;

entity mult_BCD_comb is
	Generic (NDigit : integer:=8; MDigit : integer:=8);
	Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (MDigit*4-1 downto 0);
           p : out  STD_LOGIC_VECTOR ((NDigit+MDigit)*4-1 downto 0));
end mult_BCD_comb;

architecture Behavioral of mult_BCD_comb is
   function log2sup (num: natural) return natural is
      variable i,pw: natural;
   begin
      i := 0; pw := 1;
      while(pw < num) loop i := i+1; pw := pw*2; end loop;
      return i;
   end log2sup;

  component mult_Nx1_BCD is
  Generic (NDigit : integer:=2);
  Port ( a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
         b : in  STD_LOGIC_VECTOR (3 downto 0);
         p : out  STD_LOGIC_VECTOR ((NDigit+1)*4-1 downto 0));
  end component;

  component cych_adder_BCD_v2 is
  Generic (NDigit : integer);
  Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
         cin : in  STD_LOGIC;
         cout : out  STD_LOGIC;
         s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
  end component;

  --constant logM natural := log2sup(MDigit);
  type partialSum is array (2*MDigit-2 downto 0) of STD_LOGIC_VECTOR ((NDigit+MDigit)*4-1 downto 0);
  signal pp,pps: partialSum;

begin 
 
   GenM: for i in 0 to (MDigit-1) generate --Multiply one by N
      mlt: mult_Nx1_BCD generic map (NDIGIT => NDigit) PORT MAP (
           a => a, b => b((i+1)*4-1 downto i*4), p => pp(i)((NDigit+1)*4-1 downto 0) );
   end generate;	

	GenOps: for i in 0 to log2sup(MDigit)-1 generate --Tree of adders
       G_P: for j in ((2**i-1)*2**(log2sup(MDigit)-i)) to (((2**i-1)*2**(log2sup(MDigit)-i)) + 2**(log2sup(MDigit)-i-1) -1) generate
            pps(2*j)((NDigit+MDigit)*4-1 downto (NDigit)*4) <= (others => '0');
            pps(2*j)((NDigit)*4-1 downto 0) <= pp(2*j)((NDigit+2**i)*4-1 downto (2**i)*4);
            adder: cych_adder_BCD_v2 generic map (NDIGIT => NDigit+2**i) 
                  PORT MAP( a => pps(2*j)((NDigit+2**i)*4-1 downto 0), b => pp(2*j+1)((NDigit+2**i)*4-1 downto 0), 
                            cin => '0', cout => open,	s => pp(MDIGIT+j)((NDigit+2**i+2**i)*4-1 downto ((2**i)*4))); 
            pp(MDIGIT+j)((2**i)*4-1 downto 0) <= pp(2*j)((2**i)*4-1 downto 0);
    end generate;
  end generate;
  
  p((NDigit+MDigit)*4-1 downto 0) <= pp(MDigit*2-2);
  
end Behavioral;

