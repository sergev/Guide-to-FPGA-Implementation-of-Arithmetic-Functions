----------------------------------------------------------
-- 
-- Basic cell for sqrt (used in FP SQRT of section 12.5.4)
-- This cell assumes 00 as new input
--
----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity sqrt_cell_00 is
    generic(N: integer:= 16); 
    port (
        op_r: in STD_LOGIC_VECTOR (N-2 downto 2);
        op_q: in STD_LOGIC_VECTOR (N-3 downto 0);
        new_r: out STD_LOGIC_VECTOR (N-1 downto 2);
        new_q: out STD_LOGIC_VECTOR (N-2 downto 0)
        );
end sqrt_cell_00;

architecture behav of sqrt_cell_00 is
  signal op_4r, op_4q, new_re: STD_LOGIC_VECTOR (N-1 downto 3);
  signal sr: STD_LOGIC;
begin
  sr <= op_r(N-2); 
  --op_4r <= op_r(N-3 downto 0) & "00";  -- it is known 1100
  op_4r <= op_r(N-3 downto 2) & '1'; --the 100 is out of the computation
  --op_4q  <= op_q(N-3 downto 1) & "011" when sr = '1' else  not (op_q(N-3 downto 1)) & "011";
  op_4q  <= op_q(N-3 downto 1) when sr = '1' else  not (op_q(N-3 downto 1));
  -- 100 + 011 = 111
  
  new_re <= op_4r + op_4q;
  new_r <= new_re & '1';
  new_q <= op_q & not (new_re(N-1));
  
end behav;
