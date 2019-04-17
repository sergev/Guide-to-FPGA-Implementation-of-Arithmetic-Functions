----------------------------------------------------------------------------
-- test_long_operand_adder.vhd
--
-- section 7.6
--
-- exhaustive test bench for sequential addition
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY test_long_operand_adder IS 
END test_long_operand_adder;

ARCHITECTURE test OF test_long_operand_adder IS
   CONSTANT s: natural:= 4;
   CONSTANT k: natural:= 3;

   COMPONENT long_operand_adder IS
   GENERIC(s: NATURAL:= 8; k: NATURAL:= 8);
   PORT(
     x, y: IN STD_LOGIC_VECTOR(s*k-1 DOWNTO 0);
     c_in, clk, reset, start: IN STD_LOGIC;
     z: OUT STD_LOGIC_VECTOR(s*k-1 DOWNTO 0);
     c_out, done: OUT STD_LOGIC
   );
   END COMPONENT;
   SIGNAL x, y: STD_LOGIC_VECTOR(k*s-1 DOWNTO 0);
   SIGNAL c_in: STD_LOGIC;
   SIGNAL z: STD_LOGIC_VECTOR(k*s-1 DOWNTO 0);
   SIGNAL zz: STD_LOGIC_VECTOR(k*s DOWNTO 0);
   SIGNAL c_out: STD_LOGIC;
   SIGNAL clk, reset, start, done: STD_LOGIC;


   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: long_operand_adder GENERIC MAP(s => s, k => k)
   PORT MAP(x => x, y => y, c_in => c_in, 
            clk => clk, reset => reset, start=> start, 
            z => z, c_out => c_out, done => done);

   zz <= ('0' & x) + y + c_in;
  
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
   FOR i IN 0 TO 2**(k*s)-1 LOOP
    FOR j IN 0 TO 2**(k*s)-1 LOOP
      c_in <= '0';
      start <= '1';
      x <= conv_std_logic_vector(i,k*s); 
      y <= conv_std_logic_vector(j,k*s); 
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;     
      ASSERT ( z = zz(k*s-1 DOWNTO 0)) REPORT "error in addition: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;
      ASSERT ( c_out = zz(k*s)) REPORT "error in c_out: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;

      c_in <= '1';
      start <= '1';      
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;
      ASSERT ( z = zz(k*s-1 DOWNTO 0)) REPORT "error in addition: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;
      ASSERT ( c_out = zz(k*s)) REPORT "error in c_out: " & integer'image(i) & " + " & integer'image(j) SEVERITY ERROR;             
    END LOOP;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;