----------------------------------------------------
-- Decimal Adder/subtractor
-- Computing P-G from the intermediate sum
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity addsubBCD_v1 is 
    generic (NDigit: natural:= 8);
    Port ( 
        a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        addsub : in  STD_LOGIC;
        cout : out  STD_LOGIC;
        s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end addsubBCD_v1;


architecture Behavioral of addsubBCD_v1 is

  component addsub_1BCD 
      Port ( a,b : in  STD_LOGIC_VECTOR (3 downto 0);
             sub : in  STD_LOGIC;
             c : out  STD_LOGIC_VECTOR (3 downto 0);
             cout : out  STD_LOGIC);
  end component;

  component correct_add
      Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
             ci,co : in  STD_LOGIC;
             c : out  STD_LOGIC_VECTOR (3 downto 0));
  end component;

  component carry_chain_v1 
      Port ( s: in  STD_LOGIC_VECTOR (4 downto 0);
             cin: in std_logic;
             cout: out  STD_LOGIC); 
  end component;

  signal ss: std_logic_vector(NDigit*4-1 downto 0);
  signal cyin, ss_4: std_logic_vector(NDigit downto 0);
  type partialAdds is array (NDigit-1 downto 0) of STD_LOGIC_VECTOR (4 downto 0);
  signal sum: partialAdds;

begin

  cyin(0) <= addsub;

  GenAdd: for i in 0 to NDigit-1 generate
      for addSbt: addsub_1BCD use entity WORK.addsub_1BCD(LowLevel);      
      --for addSbt: addsub_1BCD use entity WORK.addsub_1BCD(Behavioral);      
      for cych: carry_chain_v1 use entity WORK.carry_chain_v1(LowLevel);
      --for cych: carry_chain_v1 use entity WORK.carry_chain_v1(Behavioral);
  begin
    addSbt: addsub_1BCD Port map( a => a((i+1)*4-1 downto i*4), b => b((i+1)*4-1 downto i*4),
          sub => addsub, c => ss((i+1)*4-1 downto i*4), cout => ss_4(i));
    sum(i) <= ss_4(i) & ss((i+1)*4-1 downto i*4);
    cych: carry_chain_v1 Port map ( s => sum(i),  
          cin => cyin(i), cout => cyin(i+1));
    fadd: correct_add Port map( a => ss((i+1)*4-1 downto i*4),
          co => cyin(i+1),ci => cyin(i), c => s((i+1)*4-1 downto i*4));
  end generate;

  cout <= cyin(NDigit); 

end Behavioral;

