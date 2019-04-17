
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_twenty_four_operand_adder_simple IS
END test_twenty_four_operand_adder_simple;

ARCHITECTURE test OF test_twenty_four_operand_adder_simple IS
  COMPONENT twenty_four_operand_adder IS
    GENERIC(n: NATURAL);
  PORT(
    x: IN STD_LOGIC_VECTOR(24*n-1 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL x: STD_LOGIC_VECTOR(24*32-1 DOWNTO 0);
  SIGNAL z: STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
  dut: twenty_four_operand_adder GENERIC MAP(n => 32)
  PORT MAP(x => x, z => z);
  x(24*32-1 DOWNTO 23*32) <= x"00000012";
  x(23*32-1 DOWNTO 22*32) <= x"00000023";
  x(22*32-1 DOWNTO 21*32) <= x"00000034";
  x(21*32-1 DOWNTO 20*32) <= x"00000045";
  x(20*32-1 DOWNTO 19*32) <= x"00000056";
  x(19*32-1 DOWNTO 18*32) <= x"00000067";
  x(18*32-1 DOWNTO 17*32) <= x"00000078";
  x(17*32-1 DOWNTO 16*32) <= x"00000089";
  x(16*32-1 DOWNTO 15*32) <= x"0000009a";
  x(15*32-1 DOWNTO 14*32) <= x"000000ab";
  x(14*32-1 DOWNTO 13*32) <= x"000000bc";
  x(13*32-1 DOWNTO 12*32) <= x"000000cd";
  x(12*32-1 DOWNTO 11*32) <= x"000000de";
  x(11*32-1 DOWNTO 10*32) <= x"000000ef";
  x(10*32-1 DOWNTO 9*32) <= x"000000f0";
  x(9*32-1 DOWNTO 8*32) <= x"00000001";
  x(8*32-1 DOWNTO 7*32) <= x"00000012";
  x(7*32-1 DOWNTO 6*32) <= x"00000023";
  x(6*32-1 DOWNTO 5*32) <= x"00000034";
  x(5*32-1 DOWNTO 4*32) <= x"00000045";
  x(4*32-1 DOWNTO 3*32) <= x"00000056";
  x(3*32-1 DOWNTO 2*32) <= x"00000067";
  x(2*32-1 DOWNTO 32) <= x"00000078";
  x(31 DOWNTO 0) <= x"00000089";
END test;
    
  
