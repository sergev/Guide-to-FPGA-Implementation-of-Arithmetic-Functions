----------------------------------------------------------
-- 
-- Basic cell for sqrt (used in FP SQRT of section 12.5.4)
--
----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity sqrt_cell is
    generic(N: integer:= 16); 
    port (
        op_r: in STD_LOGIC_VECTOR (N-2 downto 0);
        d: in STD_LOGIC_VECTOR (1 downto 0);
        op_q: in STD_LOGIC_VECTOR (N-3 downto 0);
        new_r: out STD_LOGIC_VECTOR (N-1 downto 0);
        new_q: out STD_LOGIC_VECTOR (N-2 downto 0)
        );
end sqrt_cell;

architecture behav of sqrt_cell is
  signal op_4r, op_4q, new_re: STD_LOGIC_VECTOR (N-1 downto 0);
  signal sr: STD_LOGIC;
begin
  sr <= op_r(N-2); 
  op_4r <= op_r(N-3 downto 0) & d; 
  op_4q  <= op_q(N-3 downto 1) & "011" when sr = '1' else  not (op_q(N-3 downto 1)) & "011";
  
  new_re <= op_4r + op_4q;
  new_r <= new_re;
  new_q <= op_q & not (new_re(N-1));
  
end behav;
