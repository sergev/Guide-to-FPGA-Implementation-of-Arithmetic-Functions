----------------------------------------------------------------------------
-- mod_f_squaring.vhd
--
-- section 13.2.3 mod f squarer
--
-- Computes the polynomial multiplication A.A mod f in GF(2**m)
-- The hardware is genenerate for a specific f.
--
-- Its is based on classic modular multiplier, but use the fact that
-- Squaring a polinomial is simplier than multiply.
--
-- Defines 2 entities:
-- poly_reducer: reduces a (2*m-1)- bit polynomial by f to an m-bit polinomial
-- classic_multiplication: instantiates the poly_reducer and squares the A polinomial
-- and a Package (classic_multiplier_parameterse)
-- 
----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
package classic_squarer_parameters is
  constant M: integer := 233;
  --constant F: std_logic_vector(M-1 downto 0):= "00011011";
  --constant F: std_logic_vector(M-1 downto 0):= x"001B"; --for M=16 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"0101001B"; --for M=32 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"010100000101001B"; --for M=64 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"0000000000000000010100000101001B"; --for M=128 bits
  --constant F: std_logic_vector(M-1 downto 0):= "000"&x"00000000000000000000000000000000000000C9"; --for M=163
  constant F: std_logic_vector(M-1 downto 0):= (0=> '1', 74 => '1', others => '0'); --for M=233
  type matrix_reductionR is array (0 to M-1) of STD_LOGIC_VECTOR(M-2 downto 0);
  function reduction_matrix_R return matrix_reductionR;
end classic_squarer_parameters;

package body classic_squarer_parameters is
  function reduction_matrix_R return matrix_reductionR is
  variable R: matrix_reductionR;
  begin
  for j in 0 to M-1 loop
     for i in 0 to M-2 loop
        R(j)(i) := '0'; 
     end loop;
  end loop;
  for j in 0 to M-1 loop
     R(j)(0) := f(j);
  end loop;
  for i in 1 to M-2 loop
     for j in 0 to M-1 loop
        if j = 0 then 
           R(j)(i) := R(M-1)(i-1) and R(j)(0);
        else
           R(j)(i) := R(j-1)(i-1) xor (R(M-1)(i-1) and R(j)(0)); 
        end if;
     end loop;
  end loop;
  return R;
end reduction_matrix_R;

end classic_squarer_parameters;

------------------------------------------------------------
-- poly_reducer
------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.classic_squarer_parameters.all;

entity poly_reducer is
port (
  d: in std_logic_vector(2*M-2 downto 0);
  c: out std_logic_vector(M-1 downto 0)
);
end poly_reducer;

architecture simple of poly_reducer is
  constant R: matrix_reductionR := reduction_matrix_R;
begin

  gen_xors: for j in 0 to M-1 generate
    l1: process(d) 
        variable aux: std_logic;
        begin
          aux := d(j);
          for i in 0 to M-2 loop 
            aux := aux xor (d(M+i) and R(j)(i)); 
          end loop;
          c(j) <= aux;
    end process;
  end generate;

end simple;

------------------------------------------------------------
-- Classic Squaring
------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.classic_squarer_parameters.all;

entity mod_f_squaring is
port (
  a: in std_logic_vector(M-1 downto 0);
  c: out std_logic_vector(M-1 downto 0)
);
end mod_f_squaring;

architecture simple of mod_f_squaring is

  component poly_reducer port (
    d: in std_logic_vector(2*M-2 downto 0);
    c: out std_logic_vector(M-1 downto 0));
  end component;

  signal d: std_logic_vector(2*M-2 downto 0);

begin

  D(0) <= A(0);
  square: for i in 1 to M-1 generate
    D(2*i-1) <= '0';
    D(2*i) <= A(i);
  end generate;
  
  inst_reduc: poly_reducer port map(d => d, c => c);
  
end simple;