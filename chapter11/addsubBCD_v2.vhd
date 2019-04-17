----------------------------------------------------
-- Decimal Adder/subtractor
-- Computing P-G direct from inputs
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity addsubBCD_v2 is 
    generic (NDigit: natural:= 8);
    Port ( 
        a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        addsub : in  STD_LOGIC;
        cout : out  STD_LOGIC;
        s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end addsubBCD_v2;


architecture Behavioral of addsubBCD_v2 is

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

  component carry_chain_v2 
      Port ( x, y : in  STD_LOGIC_VECTOR (3 downto 0);
          sub, cin: in std_logic;
          cout: out  STD_LOGIC); 
  end component;

  signal ss: std_logic_vector(NDigit*4-1 downto 0);
  signal cyin: std_logic_vector(NDigit downto 0);

begin

  cyin(0) <= addsub;

  GenAdd: for i in 0 to NDigit-1 generate
      for addSbt: addsub_1BCD use entity WORK.addsub_1BCD(LowLevel);      
      --for addSbt: addsub_1BCD use entity WORK.addsub_1BCD(Behavioral);      
      for cych: carry_chain_v2 use entity WORK.carry_chain_v2(LowLevel);
      --for cych: carry_chain_v2 use entity WORK.carry_chain_v2(mediumLevel);
      --for cych: carry_chain_v2 use entity WORK.carry_chain_v2(Behavioral);
  begin
    addSbt: addsub_1BCD Port map( a => a((i+1)*4-1 downto i*4), b => b((i+1)*4-1 downto i*4),
          sub => addsub, c => ss((i+1)*4-1 downto i*4), cout => open);
    cych: carry_chain_v2 Port map ( x => a((i+1)*4-1 downto i*4), y => b((i+1)*4-1 downto i*4), 
          sub => addsub, cin => cyin(i), cout => cyin(i+1));
    fadd: correct_add Port map( a => ss((i+1)*4-1 downto i*4),
          co => cyin(i+1),ci => cyin(i), c => s((i+1)*4-1 downto i*4));
  end generate;

  cout <= cyin(NDigit); 

end Behavioral;

