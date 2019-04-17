----------------------------------------------------------------------------
-- classic_multiplier.vhd
--
-- Section 13.3.2.1 Classic Multiplier (multiply and reduce) in GF(2^m) 
--
-- Computes the polynomial multiplication mod f in GF(2**m)
-- The hardware is genenerate for a specific f.
--
-- Defines 3 entities:
-- poly_multiplier: multiplies two m-bit polynomials and gives a 2*m-1 bits polynomial. 
-- poly_reducer: reduces a (2*m-1)- bit polynomial by f to an m-bit polynomial
-- classic_multiplication: instantiates a poly_multiplier and a poly_reducer
-- and a Package (classic_multiplier_parameters)
-- 
----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
package classic_multiplier_parameters is
  constant M: integer := 8;
  constant F: std_logic_vector(M-1 downto 0):= "00011011";
  --constant F: std_logic_vector(M-1 downto 0):= x"001B"; --for M=16 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"0101001B"; --for M=32 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"010100000101001B"; --for M=64 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"0000000000000000010100000101001B"; --for M=128 bits
  --constant F: std_logic_vector(M-1 downto 0):= "000"&x"00000000000000000000000000000000000000C9"; --for M=163
  --constant F: std_logic_vector(M-1 downto 0):= (0=> '1', 74 => '1', others => '0'); --for M=233
  type matrix_reductionR is array (0 to M-1) of STD_LOGIC_VECTOR(M-2 downto 0);
  function reduction_matrix_R return matrix_reductionR;
end classic_multiplier_parameters;

package body classic_multiplier_parameters is
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

end classic_multiplier_parameters;

------------------------------------------------------------
-- poly_multiplier
------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.classic_multiplier_parameters.all;

entity poly_multiplier is
port (
  a, b: in std_logic_vector(M-1 downto 0);
  d: out std_logic_vector(2*M-2 downto 0)
);
end poly_multiplier;


architecture simple of poly_multiplier is
  type matrix_ands is array (0 to 2*M-2) of STD_LOGIC_VECTOR(2*M-2 downto 0);
  signal a_by_b: matrix_ands;
  signal c: std_logic_vector(2*M-2 downto 0);
begin

  gen_ands: for k in 0 to M-1 generate
    l1: for i in 0 to k generate
       a_by_b(k)(i) <= A(i) and B(k-i);
    end generate;
  end generate;

  gen_ands2: for k in M to 2*M-2 generate
    l2: for i in k to 2*M-2 generate
       a_by_b(k)(i) <= A(k-i+(M-1)) and B(i-(M-1));
    end generate;
  end generate;

  d(0) <= a_by_b(0)(0);
  gen_xors: for k in 1 to 2*M-2 generate
    l3: process(a_by_b(k),c(k)) 
        variable aux: std_logic;
        begin
        if (k < M) then
          aux := a_by_b(k)(0);
          for i in 1 to k loop aux := a_by_b(k)(i) xor aux; end loop;
        else
          aux := a_by_b(k)(k);
          for i in k+1 to 2*M-2 loop aux := a_by_b(k)(i) xor aux; end loop;
        end if;
        d(k) <= aux;
    end process;
  end generate;

end simple;

------------------------------------------------------------
-- poly_reducer
------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.classic_multiplier_parameters.all;

entity poly_reducer is
port (
  d: in std_logic_vector(2*M-2 downto 0);
  c: out std_logic_vector(M-1 downto 0)
);
end poly_reducer;

architecture simple of poly_reducer is
  constant R: matrix_reductionR := reduction_matrix_R;
  signal S: matrix_reductionR;
begin
  S <= R;
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
-- Classic Multiplication
------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.classic_multiplier_parameters.all;

entity classic_multiplication is
port (
  a, b: in std_logic_vector(M-1 downto 0);
  c: out std_logic_vector(M-1 downto 0)
);
end classic_multiplication;

architecture simple of classic_multiplication is
  component poly_multiplier port (
    a, b: in std_logic_vector(M-1 downto 0);
    d: out std_logic_vector(2*M-2 downto 0) );
  end component;
  component poly_reducer port (
    d: in std_logic_vector(2*M-2 downto 0);
    c: out std_logic_vector(M-1 downto 0));
  end component;

  signal d: std_logic_vector(2*M-2 downto 0);

begin

  inst_mult:  poly_multiplier port map(a => a, b => b, d => d);
  inst_reduc: poly_reducer port map(d => d, c => c);
  
end simple;