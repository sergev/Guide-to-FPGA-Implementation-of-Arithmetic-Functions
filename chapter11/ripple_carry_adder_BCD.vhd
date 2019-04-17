------------------------------------------------------------------
-- BCD ripple carry Adder 
-- Simple version
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity ripple_adder_BCD is
Generic (NDigit : integer:=16);
Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        cin : in  STD_LOGIC;
        cout : out  STD_LOGIC;
        s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end ripple_adder_BCD;

architecture Behavioral of ripple_adder_BCD is

component bcd_rp_cell is port (
   x, y: in std_logic_vector (3 downto 0);
   c_in: in std_logic;
   z: out std_logic_vector (3 downto 0);
   c_out: inout std_logic);
end component;

signal cyin: std_logic_vector(NDigit downto 0);

begin

cyin(0) <= cin; 	
   
GenAdd: for i in 0 to NDigit-1 generate
 cell: bcd_rp_cell PORT MAP( 
       x => a((i+1)*4-1 downto i*4), y => b((i+1)*4-1 downto i*4), c_in => cyin(i),
       z => s((i+1)*4-1 downto i*4), c_out => cyin(i+1) );
end generate;	

cout <= cyin(NDigit); 

end Behavioral;

