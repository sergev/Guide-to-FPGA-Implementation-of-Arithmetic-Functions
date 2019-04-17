-----------------------------------------------------------------------
-- Square root for Naturals. Combinational Circuit
-- No remainder. Same amount of output bits
-- optimized second part.
--
-- Generate an stiky bit. 1 if R > 0
-- Used in Floating Point SQRT of section 12.5.4.
--
----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity sqrt_wsticky is
   generic(N: integer:= 26); 
   port (
      D: in STD_LOGIC_VECTOR (N-1 downto 0);
      Q: out STD_LOGIC_VECTOR (N-1 downto 0);
      sticky: out STD_LOGIC
   );
end sqrt_wsticky;

architecture simple_arch of sqrt_wsticky is

  component  sqrt_cell is
  generic(N: integer:= N/2); 
  port (
        op_r: in STD_LOGIC_VECTOR (N-2 downto 0);
        d: in STD_LOGIC_VECTOR (1 downto 0);
        op_q: in STD_LOGIC_VECTOR (N-3 downto 0);
        new_r: out STD_LOGIC_VECTOR (N-1 downto 0);
        new_q: out STD_LOGIC_VECTOR (N-2 downto 0));
  end component;
  
  component  sqrt_cell_00 is
  generic(N: integer:= N/2); 
  port (
        op_r: in STD_LOGIC_VECTOR (N-2 downto 2);
        op_q: in STD_LOGIC_VECTOR (N-3 downto 0);
        new_r: out STD_LOGIC_VECTOR (N-1 downto 2);
        new_q: out STD_LOGIC_VECTOR (N-2 downto 0));
  end component;

  type connectionmatrix1 is array (0 to N-1) of STD_LOGIC_VECTOR (N+1 downto 0);
  signal r_con_i, r_con_o: connectionmatrix1;
  type connectionmatrix2 is array (0 to N-1) of STD_LOGIC_VECTOR (N+0 downto 0);
  signal q_con_i, q_con_o: connectionmatrix2;
  type connectionmatrix3 is array (N-1 downto N/2) of STD_LOGIC_VECTOR (N-1 downto 0);
  signal D_int: connectionmatrix3;   
  signal R: STD_LOGIC_VECTOR (N+1 downto 1);
  signal qout: STD_LOGIC_VECTOR (N/2-1 downto 0);

begin
      
  D_int(N-1) <= D;
  
  r_con_o(N-1)(2 downto 0) <= ('0' & D_int(N-1)(N-1 downto N-2)) + "111";
  q_con_o(N-1)(1) <= '0'; q_con_o(N-1)(0) <= not (r_con_o(N-1)(2));
   
  g1: for i in N-2 downto N/2 generate
     i_sqrt: sqrt_cell generic map (N => (N-i +2) )
      PORT MAP( op_r => r_con_i(i)(N-i+0 downto 0),	
                d => D_int(i)(2*(i-N/2)+1 downto 2*(i-N/2)), op_q => q_con_i(i)(N-i-1 downto 0),
                new_r => r_con_o(i)(N- i + 1 downto 0), new_q => q_con_o(i)(N-i + 0 downto 0)	);
  end generate;
  
  i_sqrt: sqrt_cell generic map (N => (N/2+1 + 2) )
      PORT MAP( op_r => r_con_i(N/2-1)(N/2+1+0 downto 0),	
                d => "00",	op_q => q_con_i(N/2-1)(N/2+1-1 downto 0),
                new_r => r_con_o(N/2-1)(N/2+1 + 1 downto 0), new_q => q_con_o(N/2-1)(N/2+1 + 0 downto 0)	);
  
  g2: for i in N/2-2 downto 0 generate
     i_sqrt: sqrt_cell_00 generic map (N => (N- i + 2) )
      PORT MAP( op_r => r_con_i(i)(N-i+0 downto 2), op_q => q_con_i(i)(N-i-1 downto 0),
                new_r => r_con_o(i)(N- i + 1 downto 2), new_q => q_con_o(i)(N-i + 0 downto 0)	);
  end generate;
     
   Q <= q_con_o(0)(N-1 downto 0);

   con_g1: for i in N-1 downto 1 generate
      r_con_i(i-1) <= r_con_o(i);
      q_con_i(i-1) <= q_con_o(i);
   end generate;

   con_g2: for i in N-1 downto N/2+1 generate
      D_int(i-1) <= D_int(i);
   end generate;

  sticky <= r_con_o(0)(N+1);

end simple_arch;
