----------------------------------------------------------------------------
-- k_by_k_parallel_multiplier.vhd
-- 
-- section 8.2.4 
-- basic cell used in base_2k_parallel_multiplier and base_2k_csa_multiplier
-- computes a·b + c + d = zH·2^k + zL
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY k_by_k_parallel_multiplier IS
  GENERIC(k: NATURAL);
PORT(
  a, c: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  b, d: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  zL, zH: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0)
);
END k_by_k_parallel_multiplier;

ARCHITECTURE behavior OF k_by_k_parallel_multiplier IS
  SIGNAL z1: STD_LOGIC_VECTOR(2*k-1 DOWNTO 0);
  SIGNAL z: STD_LOGIC_VECTOR(2*k-1 DOWNTO 0);
  attribute mult_style: string;
  attribute mult_style of z1 : signal is "lut";
BEGIN
  --z <= a*b + c + d;
  z1 <= a*b;
  z <= z1 + c + d;
  zH <= z(2*k-1 DOWNTO k);
  zL <= z(k-1 DOWNTO 0);
END behavior;
