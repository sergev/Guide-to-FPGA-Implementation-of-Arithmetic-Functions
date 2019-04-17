-----------------------------------------------------------
-- Final adjust. "Add 6 or 7"
-- The module adds "0 co co ci" ie, 0, 1, 6 or 7
-- This module can be implemented behavioural! Same performance.
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity correct_add is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           ci, co : in  STD_LOGIC;
           c : out  STD_LOGIC_VECTOR (3 downto 0));
end correct_add;

architecture Behavioral of correct_add is
begin
 c <= a + (co & co & ci);
end Behavioral;

