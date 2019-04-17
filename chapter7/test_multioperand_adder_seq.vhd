----------------------------------------------------------------------------
-- test_multioperand_adder_seq.vhd
--
-- section 7.6
--
-- exhaustive test bench for sequential multioperand addition
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY test_multioperand_adder_seq IS 
END test_multioperand_adder_seq;

ARCHITECTURE test OF test_multioperand_adder_seq IS
   CONSTANT m: natural:= 5;
   CONSTANT n: natural:= 4;

   COMPONENT csa_multioperand_adder IS
   --COMPONENT multioperand_adder IS
     GENERIC(n: NATURAL:= 8; m: NATURAL:= 8);
   PORT(
     x: IN STD_LOGIC_VECTOR(n*m-1 DOWNTO 0);
     clk, reset, start: IN STD_LOGIC;
     z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;
   
   SIGNAL x: STD_LOGIC_VECTOR(n*m-1 DOWNTO 0);
   SIGNAL z, zz: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: csa_multioperand_adder GENERIC MAP(n => n, m => m)
   --dut: multioperand_adder GENERIC MAP(n => n, m => m)
   PORT MAP(x => x, clk => clk, reset => reset, start=> start, 
            z => z, done => done);
            
   behav_sum: PROCESS(x)
   VARIABLE acc: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   BEGIN
   acc := x(n-1 downto 0);
   FOR i IN 1 TO m-1 LOOP
     acc := acc + x((i+1)*n-1 downto i*n);
   END LOOP;
   zz <= acc;
   END PROCESS;  

   clk_generation: process
   begin
   wait for OFFSET;
   while not end_sim loop
      clk <= '0';
      wait for PERIOD/2;
      clk <= '1';
      wait for PERIOD/2;
   end loop;
   wait;
   end process;

   stimuli: PROCESS
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO 2**(m*n)-1 LOOP
      start <= '1';
      x <= conv_std_logic_vector(i,m*n); 
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;     
      ASSERT ( z = zz ) REPORT "error in multioperand addition: " & integer'image(i) SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;