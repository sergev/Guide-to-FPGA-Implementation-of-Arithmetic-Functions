----------------------------------------------------------------------------
-- carry_select_adder2_FF.vhd
-- 
-- FFs for timing
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY carry_select_adder3_FF IS
  GENERIC(n1: NATURAL:= 16; n2: NATURAL:= 16; n3: NATURAL:= 4 );
PORT(
   x, y: IN STD_LOGIC_VECTOR(n1*n2*n3- 1 DOWNTO 0);
   c_in: IN STD_LOGIC;
   clk: IN STD_LOGIC;
   z: OUT STD_LOGIC_VECTOR(n1*n2*n3- 1 DOWNTO 0);
   c_out: OUT STD_LOGIC
);
END carry_select_adder3_FF;

ARCHITECTURE circuit OF carry_select_adder3_FF IS

   COMPONENT carry_select_adder3 IS
     GENERIC(n1, n2, n3: NATURAL);
   PORT(
     x, y: IN STD_LOGIC_VECTOR(n1*n2*n3 - 1 DOWNTO 0);
     c_in: IN STD_LOGIC;
     z: OUT STD_LOGIC_VECTOR(n1*n2*n3 - 1 DOWNTO 0);
     c_out: OUT STD_LOGIC );
   END COMPONENT;

  SIGNAL x_r, y_r, z_r: STD_LOGIC_VECTOR(n1*n2*n3- 1 DOWNTO 0);
  SIGNAL c_in_r, c_out_r: STD_LOGIC;  
   
BEGIN

   FFs: PROCESS(clk)
   BEGIN
    IF rising_edge(clk) THEN
      x_r <= x;
      y_r <= y; 
      c_in_r <= c_in;
      z <= z_r; 
      c_out <= c_out_r;  
   END IF;
   END PROCESS;

   comp: carry_select_adder3 
   GENERIC MAP(n1 => n1, n2 => n2, n3 => n3 )
   PORT MAP(
     x => x_r, y => y_r, c_in => c_in_r,
     z => z_r, c_out => c_out_r );

END circuit;  
