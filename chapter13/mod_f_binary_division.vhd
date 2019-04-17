----------------------------------------------------------------------------
-- mod_f_binary_division.vhd
--
-- section 13.4 Mod f division. Binary division algorithm for polynomials
--
-- Computes the x/y mod f in GF(2**m)
-- Implements a sequential circuit 
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
package binary_algorithm_parameters is
  constant M: integer := 8;
  constant logM: integer := 4;--logM is the number of bits of m plus an additional sign bit
  constant F: std_logic_vector(M downto 0):= "100011011"; --for M=8 bits
  --constant F: std_logic_vector(M downto 0):= '1'& x"001B"; --for M=16 bits
  --constant F: std_logic_vector(M downto 0):= '1'& x"0101001B"; --for M=32 bits
  --constant F: std_logic_vector(M downto 0):=  '1'& x"010100000101001B"; --for M=64 bits
  --constant F: std_logic_vector(M downto 0):= '1'& x"0000000000000000010100000101001B"; --for M=128 bits
  --constant F: std_logic_vector(M downto 0):= x"800000000000000000000000000000000000000C9"; --for M=163
  --constant F: std_logic_vector(M downto 0):= (0=> '1', 74 => '1', 233 => '1',others => '0'); --for M=233
end binary_algorithm_parameters;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.binary_algorithm_parameters.all;
entity mod_f_binary_division is
port(
  g, h: in std_logic_vector(M-1 downto 0);
  clk, reset, start: in std_logic;  
  z: out std_logic_vector(M-1 downto 0);
  done: out std_logic
);
end mod_f_binary_division;

architecture circuit of mod_f_binary_division is

  signal a : std_logic_vector(M downto 0);
  signal b, c, d, next_b, next_d: std_logic_vector(M-1 downto 0);
  signal alpha, beta, next_beta, dec_input: std_logic_vector(logM-1 downto 0);
  signal ce_ac, ce_bd, load, beta_non_negative, alpha_gt_beta, b_zero: std_logic;

  type states is range 0 to 4;
  signal current_state: states;
begin

  first_iteration: for i in 0 to M-2 generate
    next_b(i) <= (b(0) and (b(i+1) xor a(i+1))) or (not(b(0)) and b(i+1));
  end generate;
  next_b(M-1) <= b(0) and a(M);

  next_d(M-1) <= (b(0) and (d(0) xor c(0))) or (not(b(0)) and d(0));
  second_iteration: for i in 0 to M-2 generate
    next_d(i) <= (f(i+1) and next_d(M-1)) xor ((b(0) and (d(i+1) xor c(i+1))) or (not(b(0)) and d(i+1)));
  end generate;

  registers_ac: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then a <= f; c <= (others => '0');
    elsif ce_ac = '1' then a <= '0'&b; c <= d; 
    end if;
  end if;
  end process registers_ac;

  registers_bd: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then b <= h; d <= g;
    elsif ce_bd = '1' then b <= next_b; d <= next_d;
    end if;
  end if;
  end process registers_bd;

  register_alpha: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then alpha <= conv_std_logic_vector(M, logM) ;
    elsif ce_ac = '1' then alpha <= beta;
    end if;
  end if;
  end process register_alpha;

  with ce_ac select dec_input <= beta when '0', alpha when others;
  next_beta <= dec_input - 1;

  register_beta: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then beta <= conv_std_logic_vector(M-1, logM) ;
    elsif ce_bd = '1' then beta <= next_beta;
    end if;
  end if;
  end process register_beta;

  z <= c;

  beta_non_negative <= '1' when beta(logM-1) = '0' else '0';
  alpha_gt_beta <= '1' when alpha > beta else '0';
  b_zero <= '1' when b(0) = '0' else '0';

  control_unit: process(clk, reset, current_state, beta_non_negative, alpha_gt_beta, b_zero)
  begin
  case current_state is
    when 0 to 1 => ce_ac <= '0'; ce_bd <='0'; load <= '0'; done <= '1';
    when 2 => ce_ac <= '0'; ce_bd <= '0'; load <= '1'; done <= '0';
    when 3 => if beta_non_negative = '0' then ce_ac <= '0'; ce_bd <= '0'; 
              elsif b_zero = '1' then ce_ac <= '0'; ce_bd <= '1'; 
              elsif alpha_gt_beta = '1' then ce_ac <= '1'; ce_bd <= '1'; 
              else ce_ac <= '0'; ce_bd <= '1'; 
              end if;
              load <= '0'; done <='0';
    when 4 => ce_ac <= '0'; ce_bd <='0'; load <= '0'; done <= '0';
  end case;

  if reset = '1' then current_state <= 0;
  elsif clk'event and clk = '1' then
  case current_state is
    when 0 => if start = '0' then current_state <= 1; end if;
    when 1 => if start = '1' then current_state <= 2; end if;
    when 2 => current_state <= 3;
    when 3 => if beta_non_negative = '0' then current_state <= 4; end if;
    when 4 => current_state <= 0;
  end case;

  end if;
  end process control_unit;

end circuit;


 