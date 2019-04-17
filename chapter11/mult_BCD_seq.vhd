------------------------------------------------------------------
-- BCD multiplier N by M digits
-- sequential version
-- Latency: M+1 cycles
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity mult_BCD_seq is
   Generic (NDigit : integer:=8; MDigit : integer:=16);
   Port (  a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           b : in  STD_LOGIC_VECTOR (MDigit*4-1 downto 0);
           clk, reset, start : in std_logic;
           done : out std_logic;
           p : out  STD_LOGIC_VECTOR ((NDigit+MDigit)*4-1 downto 0));
end mult_BCD_seq;

architecture Behavioral of mult_BCD_seq is
   function log2sup (num: natural) return natural is
      variable i,pw: natural;
   begin
      i := 0; pw := 1;
      while(pw < num) loop i := i+1; pw := pw*2; end loop;
      return i;
   end log2sup;

   component mult_Nx1_BCD is
   Generic (NDigit : integer:=2);
   Port ( a : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
         b : in  STD_LOGIC_VECTOR (3 downto 0);
         p : out  STD_LOGIC_VECTOR ((NDigit+1)*4-1 downto 0));
   end component;

   component cych_adder_BCD_v2 is
   Generic (NDigit : integer);
   Port ( a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
         cin : in  STD_LOGIC;
         cout : out  STD_LOGIC;
         s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
   end component;

   signal reg_a : std_logic_vector(NDigit*4-1 downto 0);
   signal reg_b : std_logic_vector(MDigit*4-1 downto 0);

   signal reg_p : std_logic_vector((NDigit+MDigit)*4-1 downto 0);
   signal partial_prod, reg_prod : std_logic_vector((NDigit+1)*4-1 downto 0);  
   signal partial_sum, sum : std_logic_vector((NDigit+1)*4-1 downto 0);  
   signal shift_sum : std_logic_vector(MDigit*4-1 downto 0);  

   signal iter_cnt : std_logic_vector(log2sup(MDigit)-1 downto 0);  
   type states is (inactive, shifting, last, finish);
   signal state : states;		

begin 
 
  mlt: mult_Nx1_BCD generic map (NDIGIT => NDigit) PORT MAP (
          a => reg_a, b => reg_b(3 downto 0), p => partial_prod );

  adder: cych_adder_BCD_v2 generic map (NDIGIT => NDigit+1)  PORT MAP( 
          a => reg_prod, b => partial_sum, cin => '0', cout => open,	s => sum); 

  partial_sum((NDigit+1)*4-1 downto NDigit*4) <= "0000";    

   state_mach: process(clk,reset)
   begin
      if reset='1' then
         state <= inactive;
         reg_a <= (others=>'0') ; reg_b <= (others=>'0'); reg_prod <=(others=>'0');
         reg_p <= (others=>'0'); partial_sum <= (others=>'0');
         shift_sum <= (others=>'0'); iter_cnt <= (others => '0');
      elsif rising_edge(clk) then
         case state is
            when inactive =>
               if start='1' then
                  state <= shifting;
                  reg_a <= a;
                  reg_b <= b;
                  reg_prod <=(others=>'0');
                  partial_sum <= (others=>'0');
                  shift_sum <= (others=>'0');
                  iter_cnt <= (others => '0');
               end if;
            when shifting =>
               if iter_cnt = MDigit-1 then
                  state <= last;
               end if;
               reg_prod <= partial_prod;
               partial_sum(NDigit*4-1 downto 0) <= sum((NDigit+1)*4-1 downto 4);
               shift_sum <= sum(3 downto 0) & shift_sum(MDigit*4-1 downto 4) ;
               reg_b <= "0000" & reg_b(MDigit*4-1 downto 4);
               iter_cnt <= iter_cnt + 1;
            when last =>
               state <= finish;				
               partial_sum(NDigit*4-1 downto 0) <= sum((NDigit+1)*4-1 downto 4);
               shift_sum <= sum(3 downto 0) & shift_sum(MDigit*4-1 downto 4) ;
            when others => --finish
               state <= inactive;				
               reg_p <= partial_sum(NDigit*4-1 downto 0) & shift_sum;
         end case;
      end if;
   end process;
  
   p <= reg_p;
   done <= '0' when state/=inactive else '1';

end Behavioral;

