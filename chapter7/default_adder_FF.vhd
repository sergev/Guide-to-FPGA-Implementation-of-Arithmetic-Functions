----------------------------------------------------------------------------
-- default_adder_FF.vhd
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY default_adder_FF IS
  GENERIC(k: NATURAL:= 16; m: NATURAL:= 16);
PORT(
  x, y: IN STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_in: IN STD_LOGIC;
  clk: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  c_out: OUT STD_LOGIC
);
END default_adder_FF;

ARCHITECTURE circuit OF default_adder_FF IS


  SIGNAL x_r, y_r, z_r: STD_LOGIC_VECTOR(k*m-1 DOWNTO 0);
  SIGNAL zz: STD_LOGIC_VECTOR(k*m DOWNTO 0);
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

   zz <= ('0' & x_r) + y_r + c_in_r;
   c_out_r <= zz(k*m);
   z_r <= zz (k*m-1 DOWNTO 0);

END circuit;  
