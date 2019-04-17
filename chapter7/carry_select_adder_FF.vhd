----------------------------------------------------------------------------
-- carry_select_adder_FF.vhd
-- 
-- FFs for timing
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY carry_select_adder_FF IS
  GENERIC(k: NATURAL:= 8; m: NATURAL:= 16);
PORT(
  x, y: IN STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  clk: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);
END carry_select_adder_FF;

ARCHITECTURE circuit OF carry_select_adder_FF IS

   COMPONENT carry_select_adder IS
     GENERIC(k: NATURAL:= k; m: NATURAL:= m);
   PORT(
     x, y: IN STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
     c_in: IN STD_LOGIC;
     z: OUT STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
     c_out: OUT STD_LOGIC
   );
   END COMPONENT;

  SIGNAL x_r, y_r, z_r: STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
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

   comp: carry_select_adder 
   GENERIC MAP(k => k, m => m)
   PORT MAP(
     x => x_r, y => y_r, c_in => c_in_r,
     z => z_r, c_out => c_out_r );

END circuit;  
