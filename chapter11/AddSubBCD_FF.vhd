------------------------------------------------------
-- Resgistred version of add/sub for V5
--
-------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity AddSubBCD_FF is
    generic (NDigit: natural:= 4);
    Port ( clk, rst: in  STD_LOGIC;
			  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
			  addsub : in  STD_LOGIC;
        cout : out  STD_LOGIC;
        s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end AddSubBCD_FF;

architecture Behavioral of AddSubBCD_FF is

  component AddSubBCD is
    generic (NDigit: natural:= 64);
    Port ( a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           addsub : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
  end component;

  signal ffaddsub, ffcout: std_logic;
  signal co: std_logic;

  signal ffa, ffb, ffs: std_logic_vector(NDigit*4-1 downto 0);
  signal r: std_logic_vector(NDigit*4-1 downto 0);


begin

  addsubt: AddSubBCD generic map(NDigit => NDigit)
          port map ( a => ffa, b => ffb, addsub => ffaddsub, cout => co, s => r);

  process (clk, rst) -- async reset
  begin
    if (rst = '1') then
      ffa <= (others => '0'); ffb <= (others => '0');
      ffaddsub <= '0';
      ffs <= (others => '0'); ffcout<= '0';
    elsif (rising_edge(clk)) then
      ffa <= a; ffb <= b;
      ffaddsub <= addsub;
      ffs <= r; ffcout<= co;
    end if;
  end process;

  s <= ffs;
  cout <= ffcout;


end Behavioral;

