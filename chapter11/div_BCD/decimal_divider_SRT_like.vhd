----------------------------------------------------
-- decimal divider, SRT-Like Algorithm:
-- 10^(n-1) <= y < 10^n
-- -y <= x < y
-- if x >= 0 then x = 0....; if x < 0 then x = 9 ...
-- x·10p = y·q + r
-- logp is the number of bits of p-1
--
-- Some low level changes...
-- Multiplier carry-save
-- use 4 to 2 BCD reducer
-- No minus 5 => changes in range-detector
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity decimal_divider_srt_like is 
    --generic (n: natural:= 48; p: natural := 48; logp: natural := 6);
    generic (n: natural:= 16; p: natural := 16; logp: natural := 4);
    Port ( 
        x : in  STD_LOGIC_VECTOR (4*n+3 downto 0);
        y : in  STD_LOGIC_VECTOR (4*n-1 downto 0);
        clk, reset, start : in  STD_LOGIC;
        quotient : out  STD_LOGIC_VECTOR (4*p+3 downto 0);
        remainder : out  STD_LOGIC_VECTOR (4*n+3 downto 0);
        done : out  STD_LOGIC );
end decimal_divider_srt_like;

architecture circuit of decimal_divider_srt_like is

   type mult_y is array (1 to 9) of STD_LOGIC_VECTOR (11 downto 0); 
   signal reg_y_by, y_by: mult_y;
   type multilpe_y is array (1 to 9) of STD_LOGIC_VECTOR (15 downto 0); 
   signal prod: multilpe_y;
   signal sign: STD_LOGIC;
   signal q, positive_q, negative_q: STD_LOGIC_VECTOR(3 downto 0);
   signal q_by_y: STD_LOGIC_VECTOR(4*n+3 downto 0);
   signal long_q_by_y, s, next_s, long_c: STD_LOGIC_VECTOR(4*n+7 downto 0);
   signal long_q_by_y_s, long_q_by_y_c: STD_LOGIC_VECTOR(4*n+7 downto 0);
   signal c, next_c: STD_LOGIC_VECTOR(n+1 downto 0);
   signal s_by_ten: STD_LOGIC_VECTOR(4*n+11 downto 0);
   signal c_by_ten:STD_LOGIC_VECTOR(n+2 downto 0);
   signal st, long_ct: STD_LOGIC_VECTOR(19 downto 0);
   signal ct: STD_LOGIC_VECTOR(4 downto 0);
   signal load, update, equal_zero: STD_LOGIC;
   signal ww, ww_minus_five: STD_LOGIC_VECTOR (19 downto 0);
   signal positive_quotient, negative_quotient: STD_LOGIC_VECTOR (4*p-1 downto 0);
   signal long_positive_quotient, long_negative_quotient: STD_LOGIC_VECTOR (4*p+3 downto 0);
   signal count: STD_LOGIC_VECTOR(logp-1 downto 0);
   signal cc, next_cc: STD_LOGIC_VECTOR(4*n+7 downto 0);
   signal ss, next_ss: STD_LOGIC_VECTOR(4*n+7 downto 0);
   signal ss_by_ten: STD_LOGIC_VECTOR(4*n+11 downto 0);
   signal cc_by_ten:STD_LOGIC_VECTOR(4*n+11 downto 0);
   signal q_by_y_s, q_by_y_c: STD_LOGIC_VECTOR(4*n-1 downto 0);

   type states is range 0 to 3;
   signal current_state: states;
   constant zero: STD_LOGIC_VECTOR(logp-1 downto 0) := (others => '0');

   component mult_Nx1_BCD is
     Generic (NDigit : integer:=8);
     Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
             b : in  STD_LOGIC_VECTOR (3 downto 0);
             p : out  STD_LOGIC_VECTOR ((NDigit+1)*4-1 downto 0));
   end component;

   component mult_Nx1_BCD_carrysave is
    Generic (NDigit : integer:=8);
   Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           s,c : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
   end component;

   component range_detection3 is 
      Port ( 
        one_y, two_y, three_y, four_y, five_y, six_y, seven_y, eight_y, nine_y: in STD_LOGIC_VECTOR (11 downto 0); 
        ww: in STD_LOGIC_VECTOR (19 downto 0);
        sign: out STD_LOGIC;
        q: out STD_LOGIC_VECTOR(3 downto 0)
        );
   end component;

   component decimal_CSAS_4to2 is 
    generic (NDigit: natural:= 4);
    Port ( 
        s_s, s_c : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        m_s, m_c : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        addsub : in  STD_LOGIC;
        s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
        c : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0) );
   end component;

   component cych_adder_BCD_v2 is
     Generic (NDigit : integer:=4);
     Port (  a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
             cin : in  STD_LOGIC;
             cout : out  STD_LOGIC;
             s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
   end component;

   component special_5digit_adder is
     Port (  a, b : in  STD_LOGIC_VECTOR (19 downto 0);
             s : out  STD_LOGIC_VECTOR (19 downto 0));
   end component;

   component bcd_shift_register is
     Generic (NDigit : integer:=4);
      Port ( serial_in : in  STD_LOGIC_VECTOR (3 downto 0);
             clk, shift : in  STD_LOGIC;
             parallel_out : inout  STD_LOGIC_VECTOR (NDigit*4-1 downto 0)
             );
   end component;

   component addsubBCD_v2 is 
      generic (NDigit: natural:= 4);
      Port ( 
          a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
          addsub : in  STD_LOGIC;
          cout : out  STD_LOGIC;
          s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
   end component;

begin

  y_by(1) <= "0000" & y(4*n-1 downto 4*n-8);

  genMul: for i in 2 to 9 generate
    three_digit_mult: mult_Nx1_BCD generic map(NDigit => 3)
          port map( a => y(4*n-1 downto 4*n-12), b => conv_std_logic_vector(i,4), p => prod(i) );
    y_by(i) <= prod(i)(15 downto 4);  
  end generate;
  
  main_mult: mult_Nx1_BCD_carrysave generic map(NDigit => n)
              port map( a => y, b => q, s => q_by_y_s, c => q_by_y_c);
  long_q_by_y_c <= "0000" & q_by_y_c & "0000";
  long_q_by_y_s <= "00000000" & q_by_y_s;
  
  main_register: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then 
      ss <= x(4*n+3 downto 4*n) & x; 
      cc <= (OTHERS => '0');
      for i in 1 to 9 loop
        reg_y_by(i) <= y_by(i);
      end loop;
    elsif update = '1' then 
      ss <= next_ss; 
      cc <= next_cc;
    end if;
  end if;
  end process;

  ss_by_ten <= ss & "0000"; cc_by_ten <= cc & "0000";
  s_by_ten <= s & "0000"; c_by_ten <= c & '0';
  st <= ss_by_ten(4*n+11 downto 4*n-8); 
  long_ct <= cc_by_ten(4*n+11 downto 4*n-8); 

--  five_bit_adder: cych_adder_BCD_v2 generic map(NDigit => 5) port map( a => st, b => long_ct , cin => '0', s => ww );
 five_bit_adder: special_5digit_adder port map( a => st, b => long_ct, s => ww );
   
  range_detector3: range_detection3 port map(
      one_y => reg_y_by(1), two_y => reg_y_by(2), three_y => reg_y_by(3), four_y => reg_y_by(4), five_y => reg_y_by(5), 
      six_y => reg_y_by(6), seven_y => reg_y_by(7), eight_y => reg_y_by(8), nine_y => reg_y_by(9), ww => ww,
      sign => sign, q => q );
                 
  cs_addsubtr: decimal_CSAS_4to2  generic map(NDigit => n+2)
        port map (  s_s => ss_by_ten(4*n+7 downto 0), 
                    s_c => cc_by_ten(4*n+7 downto 0),
                    m_s => long_q_by_y_s, m_c=> long_q_by_y_c,
                    addsub => sign, s => next_ss, c => next_cc);                 
                    
  and_gates_1: for i in 0 to 3 generate 
    positive_q(i) <= q(i) and sign;
  end generate;
  positive_quotient_register: bcd_shift_register  generic map(NDigit => p)
  port map(serial_in => positive_q, clk => clk, shift => update, parallel_out => positive_quotient);

  and_gates_2: for i in 0 to 3 generate 
    negative_q(i) <= q(i) and not(sign);
  end generate;
  negative_quotient_register: bcd_shift_register  generic map(NDigit => p)
      port map(serial_in => negative_q, clk => clk, 
               shift => update, parallel_out => negative_quotient );

  long_positive_quotient <= "0000"&positive_quotient;
  long_negative_quotient <= "0000"&negative_quotient;
  output_adder: addsubBCD_v2 generic map(NDigit => p+1)
                port map( a => long_positive_quotient, b => long_negative_quotient, addsub => '1', s => quotient );

  long_c_generation: for i in 0 to n+1 generate
    long_c(4*i+3 downto 4*i) <= "000"&c(i);
  end generate;

  CSA_decoder: cych_adder_BCD_v2 generic map(NDigit => n+1)
               port map( a => ss(4*n+3 downto 0), b => cc(4*n+3 downto 0), cin => '0', s => remainder );

  a_counter: process(clk)
  begin
    if clk'event and clk = '1' then
      if load = '1' then 
        count <= CONV_STD_LOGIC_VECTOR(p-1, logp);
      elsif update = '1' then 
        count <= count - 1;
      end if;
    end if;
  end process;
  equal_zero <= '1' when count = zero else '0'; 

  -----------------------------------------------
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

end circuit;

