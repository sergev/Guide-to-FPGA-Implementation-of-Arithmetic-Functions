----------------------------------------------------------------------------
-- scalar_product.vhd
--
-- Implements the scalar product in GF(2**m)
-- using the scalar_product_data_path.vhd
-- section 2.5 final example
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.scalar_product_parameters.ALL;
ENTITY scalar_product IS
PORT (
    xP, k: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    xA, zA, xB, zB: INOUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
    done: OUT STD_LOGIC );
END scalar_product;

ARCHITECTURE circuit OF scalar_product IS

COMPONENT scalar_product_data_path IS
PORT(
  xP: IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  clk, reset, start_mult, load, en_xA, en_xB, en_zA, en_zB, en_R: IN STD_LOGIC;
  sel_p1, sel_p2, sel_a1, sel_a2, sel_sq, sel_xA, sel_xB, sel_zA, sel_zB: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  sel_R: IN STD_LOGIC;
  xA, zA, xB, zB: INOUT STD_LOGIC_VECTOR(M-1 DOWNTO 0);
  mult_done: OUT STD_LOGIC
);
END COMPONENT;

SIGNAL start_mult, mult_done, load, en_xA, en_xB, en_zA, en_zB, en_R, shift, sel_R: STD_LOGIC;
SIGNAL sel_p1, sel_p2, sel_a1, sel_a2, sel_sq, sel_xA, sel_xB, sel_zA, sel_zB: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL internal_k: STD_LOGIC_VECTOR(M-1 DOWNTO 0);
SIGNAL count: natural range 0 to M;

TYPE states IS RANGE 0 TO 29;
SIGNAL current_state: states;
TYPE command_type IS (nop, first, update, 
start1, wait1, end1, second, third, start4, wait4, end4, start5, wait5, end5, sixth, start7, wait7, end7, start8, wait8, end8, ninth,
start10, wait10, end10, eleventh, twelfth , start13, wait13, end13, start14, wait14, end14, fifteenth, start16, wait16, end16, 
start17, wait17, end17, eighteenth
);
SIGNAL command: command_type;

BEGIN

main_component: scalar_product_data_path PORT MAP(
  xP => xP, clk => clk, reset => reset, start_mult => start_mult, 
  load => load, en_xA => en_xA, en_xB => en_xB, en_zA => en_zA , en_zB => en_zB, en_R => en_R, 
  sel_p1 => sel_p1, sel_p2 => sel_p2, sel_a1 => sel_a1, sel_a2 => sel_a2,
  sel_sq => sel_sq, sel_xA => sel_xA, sel_xB => sel_xB, sel_zA => sel_zA, sel_zB => sel_zB, sel_R => sel_R,
  xA => xA, zA => zA, xB => xB, zB => zB, mult_done => mult_done
);  

counter: PROCESS(reset, clk)
BEGIN
  IF reset = '1' THEN count <= 0;
  ELSIF clk' EVENT AND clk = '1' THEN
    IF load = '1' THEN count <= 0;
    ELSIF shift = '1' THEN count <= count+1; 
    END IF;
  END IF;
END PROCESS;

shift_register: PROCESS(clk)
BEGIN
  IF clk'EVENT AND clk = '1' THEN
    IF load = '1' THEN internal_k <= k;
    ELSIF shift = '1' THEN internal_k <= internal_k(M-2 DOWNTO 0)&'0';
    END IF;
  END IF;
END PROCESS;

command_decoder: PROCESS(command)
BEGIN
  CASE command IS 
  WHEN nop => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN first => 
    start_mult <= '0'; load <= '1'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN update => 
    start_mult <= '0'; load <= '0'; shift <= '1'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN start1 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait1 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end1 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '1'; en_R <= '1';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "01"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN second => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '1'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "01"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "01"; sel_R <= '0';
  WHEN third => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '1'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "01"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "01"; sel_R <= '0';
  WHEN start4 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait4 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end4 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '1'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN start5 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait5 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end5 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '1'; en_xB <= '0'; en_zA <= '1'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "10"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN sixth => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '1'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "01"; sel_zB <= "00"; sel_R <= '0';
  WHEN start7 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "10"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait7 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "10"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end7 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '1'; en_zA <= '0'; en_zB <= '0'; en_R <= '1';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "10"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '1';
  WHEN start8 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "10"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait8 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "10"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end8 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '1'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN ninth => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '1'; en_xB <= '1'; en_zA <= '1'; en_zB <= '1'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "10"; sel_xB <= "01"; sel_zA <= "10"; sel_zB <= "10"; sel_R <= '0';
  WHEN start10 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait10 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end10 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '1'; en_zB <= '0'; en_R <= '1';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "01"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN eleventh => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '1'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "01"; sel_zB <= "00"; sel_R <= '0';
  WHEN twelfth => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '1'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "01"; sel_zB <= "00"; sel_R <= '0';
  WHEN start13 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait13 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end13 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '1'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN start14 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait14 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "01"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end14 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '1'; en_zA <= '0'; en_zB <= '1'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "10"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN fifteenth => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '1'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "01"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "01"; sel_R <= '0';
  WHEN start16 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "10"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait16 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "10"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end16 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '1'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '1';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "11"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '1';
  WHEN start17 => 
    start_mult <= '1'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "10"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN wait17 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '0'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "10"; sel_p2 <= "01"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN end17 => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '0'; en_xB <= '1'; en_zA <= '0'; en_zB <= '0'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "00"; sel_xB <= "00"; sel_zA <= "00"; sel_zB <= "00"; sel_R <= '0';
  WHEN eighteenth => 
    start_mult <= '0'; load <= '0'; shift <= '0'; en_xA <= '1'; en_xB <= '1'; en_zA <= '1'; en_zB <= '1'; en_R <= '0';
    sel_p1 <= "00"; sel_p2 <= "00"; sel_a1 <= "00"; sel_a2 <= "00"; sel_sq <= "00"; 
    sel_xA <= "01"; sel_xB <= "10"; sel_zA <= "11"; sel_zB <= "11"; sel_R <= '0';
  END CASE;
END PROCESS;  

control_unit: PROCESS(clk, reset, current_state, start, k, mult_done, count)
BEGIN
  CASE current_state IS
  WHEN 0 => command <= nop; done <= '1';
  WHEN 1 => IF start = '0' THEN command <= nop; ELSE command <= first; END IF; done <= '1';
  WHEN 2 => IF internal_k(m-1) = '0' THEN command <= start1; ELSE command <= start10; END IF; done <= '0';  

  WHEN 3 => IF mult_done = '0' THEN command <= wait1; ELSE command <= end1; END IF; done <= '0'; 
  WHEN 4 => command <= second; done <= '0';
  WHEN 5 => command <= third; done <= '0';
  WHEN 6  => command <= start4; done <= '0';
  WHEN 7 => IF mult_done = '0'THEN command <= wait4; ELSE command <= end4; END IF; done <= '0';
  WHEN 8 => command <= start5; done <= '0';
  WHEN 9 => IF mult_done = '0'THEN command <= wait5; ELSE command <= end5; END IF; done <= '0';
  WHEN 10 => command <= sixth; done <= '0';
  WHEN 11 => command <= start7; done <= '0';
  WHEN 12 => IF mult_done = '0'THEN command <= wait7; ELSE command <= end7; END IF; done <= '0';
  WHEN 13 => command <= start8; done <= '0';
  WHEN 14 => IF mult_done = '0'THEN command <= wait8; ELSE command <= end8; END IF; done <= '0';
  WHEN 15 => command <= ninth; done <= '0';
  
  WHEN 16 => IF mult_done = '0' THEN command <= wait10; ELSE command <= end10; END IF; done <= '0';
  WHEN 17 => command <= eleventh; done <= '0';
  WHEN 18 => command <= twelfth; done <= '0';
  WHEN 19 => command <= start13; done <= '0';
  WHEN 20 => IF mult_done = '0'THEN command <= wait13; ELSE command <= end13; END IF; done <= '0';
  WHEN 21 => command <= start14; done <= '0';
  WHEN 22 => IF mult_done = '0'THEN command <= wait14; ELSE command <= end14; END IF; done <= '0';
  WHEN 23 => command <= fifteenth; done <= '0';
  WHEN 24 => command <= start16; done <= '0';
  WHEN 25 => IF mult_done = '0'THEN command <= wait16; ELSE command <= end16; END IF; done <= '0';
  WHEN 26 => command <= start17; done <= '0';
  WHEN 27 => IF mult_done = '0'THEN command <= wait17; ELSE command <= end17; END IF; done <= '0';
  WHEN 28 => command <= eighteenth; done <= '0';
  
  WHEN 29 => IF count < m-1 THEN command <= update; ELSE command <= nop; END IF; done <= '0';
   
END CASE;

  IF reset = '1' THEN current_state <= 0;
  ELSIF clk'EVENT AND clk = '1' THEN
    CASE current_state IS
    WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
    WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
    WHEN 2 => IF internal_k(m-1) = '0' THEN current_state <= 3; ELSE current_state <= 16; END IF;
    WHEN 3 => IF mult_done = '1' THEN current_state <= 4; END IF;
    WHEN 4 => current_state <= 5;
    WHEN 5 => current_state <= 6;
    WHEN 6 => current_state <= 7;
    WHEN 7 => IF mult_done = '1' THEN current_state <= 8; END IF;
    WHEN 8 => current_state <= 9;
    WHEN 9 => IF mult_done = '1' THEN current_state <= 10; END IF;
    WHEN 10 => current_state <= 11;
    WHEN 11 => current_state <= 12;
    WHEN 12 => IF mult_done = '1' THEN current_state <= 13; END IF;
    WHEN 13 => current_state <= 14;
    WHEN 14 => IF mult_done = '1' THEN current_state <= 15; END IF;
    WHEN 15 => current_state <= 29;
    
    WHEN 16 => IF mult_done = '1' THEN current_state <= 17; END IF;
    WHEN 17 => current_state <= 18;
    WHEN 18 => current_state <= 19;
    WHEN 19 => current_state <= 20;
    WHEN 20 => IF mult_done = '1' THEN current_state <= 21; END IF;
    WHEN 21 => current_state <= 22;
    WHEN 22 => IF mult_done = '1' THEN current_state <= 23; END IF;
    WHEN 23 => current_state <= 24;
    WHEN 24 => current_state <= 25;
    WHEN 25 => IF mult_done = '1' THEN current_state <= 26; END IF;
    WHEN 26 => current_state <= 27;
    WHEN 27 => IF mult_done = '1' THEN current_state <= 28; END IF;
    WHEN 28 => current_state <= 29;
    
    WHEN 29 => IF count < m-1 THEN current_state <= 2; ELSE current_state <= 0; END IF;
    END CASE;
  END IF;  
END PROCESS;    
END circuit;