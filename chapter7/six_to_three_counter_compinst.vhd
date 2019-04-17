----------------------------------------------------------------------------
-- six_to_three_counter_compinst.vhd
--
-- section 7.7 six_to_three_counter_cell 
-- n: size of each operand
-- Z = (x0 + x1 + x2 + x3 + x4 + x5) mod 2^n = (u + v + w) mod 2^n
--
-- uses Xilinx 6-LUT component
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
-- for low level component instantiations
library UNISIM; use UNISIM.VComponents.all;


ENTITY six_to_three_counter_compinst IS
  GENERIC(n: NATURAL:= 8);
PORT(
  x0, x1, x2, x3, x4, x5: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  u, v, w: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);  
END six_to_three_counter_compinst;

ARCHITECTURE circuit OF six_to_three_counter_compinst IS
  TYPE outputs IS ARRAY (0 TO n-1) OF STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL z: outputs;
  TYPE inputs IS ARRAY (0 TO n-1) OF STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL x: inputs;
BEGIN
  iteration1: FOR i IN 0 TO n-1 GENERATE
     LUT6_inst1 : LUT6 GENERIC MAP (INIT => X"000101170117177F")
     PORT MAP ( O => z(i)(0), I0 => x0(i), I1 => x1(i), I2 => x2(i), I3 => x3(i), I4 => x4(i), I5 => x5(i));
     LUT6_inst2 : LUT6 GENERIC MAP (INIT => X"177E7EE87EE8E881")
     PORT MAP ( O => z(i)(1), I0 => x0(i), I1 => x1(i), I2 => x2(i), I3 => x3(i), I4 => x4(i), I5 => x5(i));
     LUT6_inst3 : LUT6 GENERIC MAP (INIT => X"6996966996696996")
     PORT MAP ( O => z(i)(2), I0 => x0(i), I1 => x1(i), I2 => x2(i), I3 => x3(i), I4 => x4(i), I5 => x5(i));  
     u(i) <= z(i)(0);   
  END GENERATE;

  v(0) <= '0';
  w(0) <= '0';
  w(1) <= '0';  
  v(1) <= z(0)(1);
  iteration2: FOR i IN 2 TO n-1 GENERATE
    v(i) <= z(i-1)(1); 
    w(i) <= z(i-2)(2);
  END GENERATE;
END circuit;
