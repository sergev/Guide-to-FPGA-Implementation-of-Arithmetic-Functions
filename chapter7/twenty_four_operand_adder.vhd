----------------------------------------------------------------------------
-- twenty_four_operand_adder.vhd
--
-- section 7.7  24 operand adder
-- n: size of each operand
-- Z = x0 + x1 + ... + x23 mod 2^n
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY twenty_four_operand_adder IS
  GENERIC(n: NATURAL:= 8);
PORT(
  x: IN STD_LOGIC_VECTOR(24*n-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END twenty_four_operand_adder;

ARCHITECTURE circuit OF twenty_four_operand_adder IS
  COMPONENT six_to_three_counter IS
    GENERIC(n: NATURAL);
  PORT(
    x0, x1, x2, x3, x4, x5: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    u, v, w: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );  
  END COMPONENT;
  TYPE outputs IS ARRAY(0 TO 2) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL a1, a2, a3, a4, a5, a6, a7: outputs;
  TYPE inputs IS ARRAY(0 TO 5) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL b5, b6, b7: inputs;
  SIGNAL u, v: STD_LOGIC_VECTOR(n-1 DOWNTO 0);

BEGIN
  comp1: six_to_three_counter GENERIC MAP(n => n)
  PORT MAP(x0 => x(n-1 DOWNTO 0), x1 => x(2*n-1 DOWNTO n), x2 => x(3*n-1 DOWNTO 2*n), 
  x3 => x(4*n-1 DOWNTO 3*n), x4 => x(5*n-1 DOWNTO 4*n), x5 => x(6*n-1 DOWNTO 5*n), 
  u => a1(2), v => a1(1), w => a1(0));
  comp2: six_to_three_counter GENERIC MAP(n => n)
  PORT MAP(x0 => x(7*n-1 DOWNTO 6*n), x1 => x(8*n-1 DOWNTO 7*n), x2 => x(9*n-1 DOWNTO 8*n), 
  x3 => x(10*n-1 DOWNTO 9*n), x4 => x(11*n-1 DOWNTO 10*n), x5 => x(12*n-1 DOWNTO 11*n), 
  u => a2(2), v => a2(1), w => a2(0));
  comp3: six_to_three_counter GENERIC MAP(n => n)
  PORT MAP(x0 => x(13*n-1 DOWNTO 12*n), x1 => x(14*n-1 DOWNTO 13*n), x2 => x(15*n-1 DOWNTO 14*n), 
  x3 => x(16*n-1 DOWNTO 15*n), x4 => x(17*n-1 DOWNTO 16*n), x5 => x(18*n-1 DOWNTO 17*n), 
  u => a3(2), v => a3(1), w => a3(0));
  comp4: six_to_three_counter GENERIC MAP(n => n)
  PORT MAP(x0 => x(19*n-1 DOWNTO 18*n), x1 => x(20*n-1 DOWNTO 19*n), x2 => x(21*n-1 DOWNTO 20*n), 
  x3 => x(22*n-1 DOWNTO 21*n), x4 => x(23*n-1 DOWNTO 22*n), x5 => x(24*n-1 DOWNTO 23*n), 
  u => a4(2), v => a4(1), w => a4(0));
--  b5 <= a1&a2;
  b5(0) <= a1(0); b5(1) <= a1(1); b5(2) <= a1(2); b5(3) <= a2(0); b5(4) <= a2(1); b5(5) <= a2(2);
  comp5: six_to_three_counter GENERIC MAP(n => n)
  PORT MAP(x0 => b5(0), x1 => b5(1), x2 => b5(2), x3 => b5(3), x4 => b5(4), x5 => b5(5), 
  u => a5(2), v => a5(1), w => a5(0));
--  b6 <= a3&a4;
  b6(0) <= a3(0); b6(1) <= a3(1); b6(2) <= a3(2); b6(3) <= a4(0); b6(4) <= a4(1); b6(5) <= a4(2);
  comp6: six_to_three_counter GENERIC MAP(n => n)
  PORT MAP(x0 => b6(0), x1 => b6(1), x2 => b6(2), x3 => b6(3), x4 => b6(4), x5 => b6(5), 
  u => a6(2), v => a6(1), w => a6(0));
--  b7 <= a5&a6;
  b7(0) <= a5(0); b7(1) <= a5(1); b7(2) <= a5(2); b7(3) <= a6(0); b7(4) <= a6(1); b7(5) <= a6(2);
  comp7: six_to_three_counter GENERIC MAP(n => n)
  PORT MAP(x0 => b7(0), x1 => b7(1), x2 => b7(2), x3 => b7(3), x4 => b7(4), x5 => b7(5), 
  u => a7(2), v => a7(1), w => a7(0));
  v(0) <= '0';
  u(0) <= a7(2)(0) XOR a7(1)(0) XOR a7(0)(0);
  three_to_two: FOR i IN 1 TO n-1 GENERATE
    u(i) <= a7(2)(i) XOR a7(1)(i) XOR a7(0)(i);
    v(i) <= (a7(2)(i-1) AND a7(1)(i-1)) OR (a7(2)(i-1) AND a7(0)(i-1)) OR (a7(1)(i-1) AND a7(0)(i-1));
  END GENERATE;
  z <= u + v;
END circuit;