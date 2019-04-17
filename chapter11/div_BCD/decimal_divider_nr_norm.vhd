----------------------------------------------------
-- decimal divider:
-- 10^(n-1) <= y < 10^n (normalized)
-- -y <= x < y
-- if x >= 0 then x = 0....; if x < 0 then x = 9 ...
-- x·10p = y·q + r
-- logp is the number of bits of p-1
--
-- non-restoring like divider. As in Paper. 
-- For normalized numbers
--
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity decimal_divider_nr_norm is 
    --generic (n: natural:= 48; p: natural := 48; logp: natural := 6);
    generic (n: natural:= 16; p: natural := 16; logp: natural := 4);
    Port ( 
        x : in  STD_LOGIC_VECTOR (4*n+3 downto 0);
        y : in  STD_LOGIC_VECTOR (4*n-1 downto 0);
        clk, reset, start : in  STD_LOGIC;
        quotient : out  STD_LOGIC_VECTOR (4*p+3 downto 0);
        remainder : out  STD_LOGIC_VECTOR (4*n+3 downto 0);
        done : out  STD_LOGIC
        );
end decimal_divider_nr_norm;


architecture circuit of decimal_divider_nr_norm is

  component bcd_shift_register is
     Generic (NDigit : integer:=4);
      Port ( serial_in : in  STD_LOGIC_VECTOR (3 downto 0);
             clk, shift : in  STD_LOGIC;
             parallel_out : inout  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
  end component;

  component addsubBCD_v2 is 
      generic (NDigit: natural:= 4);
      Port (a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
          addsub : in  STD_LOGIC;
          cout : out  STD_LOGIC;
          s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
  end component;
  
  component mult_Nx1_BCD is
     Generic (NDigit : integer:=8);
     Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
             b : in  STD_LOGIC_VECTOR (3 downto 0);
             p : out  STD_LOGIC_VECTOR ((NDigit+1)*4-1 downto 0));
  end component;

  signal sign, not_sign, equal_zero: STD_LOGIC;
  signal q, positive_q, negative_q: STD_LOGIC_VECTOR(3 downto 0);
  signal positive_quotient, negative_quotient: STD_LOGIC_VECTOR (4*p-1 downto 0);
  signal long_positive_quotient, long_negative_quotient: STD_LOGIC_VECTOR (4*p+3 downto 0);
  signal r, next_r, r_by_10 : STD_LOGIC_VECTOR(4*n+7 downto 0);
  signal r_by_10_4d: STD_LOGIC_VECTOR(15 downto 0);
  signal load, update: STD_LOGIC;
  signal count: STD_LOGIC_VECTOR(logp-1 downto 0);

  type states is range 0 to 3;
  signal current_state: states;
  constant zero: STD_LOGIC_VECTOR(logp-1 downto 0) := (others => '0');
  
  type mult_y is array (1 to 9) of STD_LOGIC_VECTOR (15 downto 0); --4 digits 
  signal yy_by, y_by: mult_y;
  signal cyy: STD_LOGIC_VECTOR(9 downto 1);
  signal q_by_y: STD_LOGIC_VECTOR(4*n+3 downto 0);
  signal long_q_by_y: STD_LOGIC_VECTOR(4*n+7 downto 0);

begin

  y_by(1) <= "00000000" & y(4*n-1 downto 4*n-8) ;
--  genMul: for i in 2 to 9 generate
--    multi_by: mult_b1_BCD_v1 generic map(NDigit => 3)
--        port map(a => y(4*n-1 downto 4*n-12), b => conv_std_logic_vector(i,4), p => yy_by(i) );
--        y_by(i) <= "0000" & yy_by(i)(15 downto 4);
--  end generate;
  genMul: for i in 2 to 9 generate
    multi_by: mult_Nx1_BCD generic map(NDigit => 2)
        port map(a => y(4*n-1 downto 4*n-8), b => conv_std_logic_vector(i,4), p => y_by(i)(11 downto 0) );
        y_by(i)(15 downto 12) <= "0000";
  end generate;  
  
  genAddSubss: for i in 1 to 9 generate
    --adder_subt_cout: addsubBCD_cout generic map(NDigit => 4) 
    adder_subt_cout: addsubBCD_v2 generic map(NDigit => 4) 
        port map(a => r_by_10_4d, b => y_by(i), addsub => not_sign, cout=> cyy(i));
  end generate;

  not_sign <= not(sign);
  r_by_10 <= r(4*n+3 downto 0) & "0000"; 
  r_by_10_4d <= r_by_10(4*n+7 downto 4*n-8);--4 more significant bits 

  comb_circuit: process(sign, cyy)
  begin
  if sign = '0' then
    if cyy(1) = '0' then q <= "0000";
    elsif cyy(2) = '0' then q <= "0001";
    elsif cyy(3) = '0' then q <= "0010";
    elsif cyy(4) = '0' then q <= "0011";
    elsif cyy(5) = '0' then q <= "0100";
    elsif cyy(6) = '0' then q <= "0101";
    elsif cyy(7) = '0' then q <= "0110";
    elsif cyy(8) = '0' then q <= "0111";
    elsif cyy(9) = '0' then q <= "1000";
    else q <= "1001";
    end if; 
  else
    if cyy(1) = '1' then q <= "0000";
    elsif cyy(2) = '1' then q <= "0001";
    elsif cyy(3) = '1' then q <= "0010";
    elsif cyy(4) = '1' then q <= "0011";
    elsif cyy(5) = '1' then q <= "0100";
    elsif cyy(6) = '1' then q <= "0101";
    elsif cyy(7) = '1' then q <= "0110";
    elsif cyy(8) = '1' then q <= "0111";
    elsif cyy(9) = '1' then q <= "1000";
    else q <= "1001";
    end if;
  end if;
  end process;

  main_mult: mult_Nx1_BCD generic map(NDigit => n)
                            port map( a => y, b => q, p => q_by_y );
  long_q_by_y <= "0000" & q_by_y;

  next_remainder: addsubBCD_v2 generic map(NDigit => n+2)
      port map(a => r_by_10, b => long_q_by_y, addsub => not_sign, s => next_r);

  main_register: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then 
      r <= x(4*n+3 downto 4*n) & x;
      sign <= x(n*4+3);
    elsif update = '1' then 
      r <= next_r;
      sign <= next_r(n*4);
    end if;
  end if;
  end process;

  and_gates_1: for i in 0 to 3 generate 
      positive_q(i) <= q(i) and not(sign);
  end generate;
  positive_quotient_register: bcd_shift_register  generic map(NDigit => p)
      port map(serial_in => positive_q, clk => clk, shift => update, parallel_out => positive_quotient);

  and_gates_2: for i in 0 to 3 generate 
      negative_q(i) <= q(i) and sign;
  end generate;
  negative_quotient_register: bcd_shift_register  generic map(NDigit => p)
      port map(serial_in => negative_q, clk => clk, shift => update, parallel_out => negative_quotient );

  long_positive_quotient <= "0000" & positive_quotient;
  long_negative_quotient <= "0000" & negative_quotient;
  output_adder: addsubBCD_v2 generic map(NDigit => p+1)
      port map( a => long_positive_quotient, b => long_negative_quotient, addsub => '1', s => quotient );

  a_counter: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then count <= CONV_STD_LOGIC_VECTOR(p-1, logp);
    elsif update = '1' then count <= count - 1;
    end if;
  end if;
  end process;
  equal_zero <= '1' when count = zero else '0'; 

  remainder <= r(4*n+3 downto 0);
  
  -----------------------------------------------
  -- The control unit
  control_unit: process(clk, reset, current_state)
  begin
    case current_state is
      when 0 to 1 => load <= '0'; update <= '0'; done <= '1';
      when 2 => load <= '1'; update <= '0'; done <= '0';
      when 3 => load <= '0'; update <= '1'; done <= '0';
    end case;

    if reset = '1' then current_state <= 0;
    elsif clk'event and clk = '1' then
      case current_state is
      when 0 => if start = '0' then current_state <= 1; end if;
      when 1 => if start = '1' then current_state <= 2; end if;
      when 2 => current_state <= 3;
      when 3 => if equal_zero = '1' then current_state <= 0; end if;
      end case;
    end if;
  end process control_unit;
  ---------------------------------------------------
end circuit;

