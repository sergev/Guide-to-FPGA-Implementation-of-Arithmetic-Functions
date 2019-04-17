-----------------------------------------------------------------------
-- Floating Point square root (fp_sqrt.vhd).
--
-- Do not support subnormals. They are interpreted as zeros.
--
-- Section 12.5.4. Example 12.11. Floating Point Square Root
-- Combinational circuits but registering input and output. 
-- For pipelined version contact the authors at arithmetic-circuits.org
--
-- K size of FP (s, exp, significand). Also Extorege width
-- E size of Exponent
-- P size of significant or fractional (includind the 1.) Also precision.
-- K = E+P
-- 
-- binary32; K=32, E= 8, P=24
-- binary64; K=64, E=11, P=53
--
----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FP_sqrt is
   --generic(K: natural:= 64; P: natural:= 53; E: natural:= 11);    
   generic(K: natural:= 32; P: natural:= 24; E: natural:= 8); 
   port (
      FP_A: in STD_LOGIC_VECTOR (K-1 downto 0);
      clk: in STD_LOGIC;
      ce:  in STD_LOGIC;
      FP_Z: out STD_LOGIC_VECTOR (K-1 downto 0)
   );
end FP_sqrt;

architecture simple_arch of FP_sqrt is

   -- Internal constant declarations
   constant ZEROS : std_logic_vector(K-1 downto 0) := (others => '0');
   constant ONES : std_logic_vector(K-1 downto 0) := (others => '1');
   constant BIAS : std_logic_vector(E-1 downto 0) := '0' & ONES(E-2 downto 0) ; --7Fh in 32 bits, 3FFh 64bits
   constant BIAS_div2 : std_logic_vector(E-1 downto 0) := "00" & ONES(E-3 downto 0) ; --3Fh in 32 bits, 1FFh 64bits

   component sqrt_wsticky is
   generic(N: integer:= P+2); 
   port (
      D: in STD_LOGIC_VECTOR (N-1 downto 0);
      Q: out STD_LOGIC_VECTOR (N-1 downto 0);      
      sticky: out STD_LOGIC
      );
   end component;

   signal A_int, FP_Z_int: STD_LOGIC_VECTOR (K-1 downto 0);
   signal sign_A, exp_odd, sticky_bit: STD_LOGIC;
   signal exp_A, exp_final: STD_LOGIC_VECTOR (E-1 downto 0);
   signal frac_A_b1, frac_A_b2, frac_shifted, sqrt_frac: STD_LOGIC_VECTOR (P+1 downto 0);
   signal sqrt_exponent: STD_LOGIC_VECTOR (E-1 downto 0);
   signal sqrt_frac_p1: STD_LOGIC_VECTOR (P-2 downto 0);
   signal frac_final: std_logic_vector (P-2 downto 0);
   signal expA_FF, expA_Z, fracA_Z, fracB_Z: std_logic;
   signal isNaN_A, isInf_A, isZero_A: std_logic;
   signal isNaN, isInf, isZero, sign: std_logic;
   signal isRoundUp : std_logic;

begin
   -- Comment the FF for final implementation!!!
   FFs: process(clk) --ONLY for simulations and timming analysis!
   begin
      if CLK'event and CLK='1' then  --CLK rising edge 
        A_int <= FP_A;
      end if;
   end process;

   sign_A <= A_int(K-1);
   exp_A  <= A_int(K-2 downto K-E-1);   
   
   expA_FF <= '1' when A_int(K-2 downto K-E-1)= ONES(K-2 downto K-E-1) else '0'; 
   expA_Z  <= '1' when A_int(K-2 downto K-E-1)= ZEROS(K-2 downto K-E-1) else '0';
   fracA_Z <= '1' when A_int(P-2 downto 0) = ZEROS(P-2 downto 0) else '0'; 

   isNaN_A <= (expA_FF and (not fracA_Z));
   isInf_A <= expA_FF; -- not compared the fractional part since NaN  has priority.
   isZero_A <= expA_Z and fracA_Z;
   
   isNaN <= isNaN_A or sign_A; --sqrt(neg)
   isInf <= isInf_A;
   isZero <= isZero_A;
   sign <= sign_A;  
   
   exp_odd <= A_int(K-E-1); --remember exponent is biased by 011...1111
   
   frac_A_b1 <= "01" & A_int(P-2 DOWNTO 0) & '0'; --restoring hidden one.
   frac_A_b2 <= '1' & A_int(P-2 DOWNTO 0) & "00"; --fractional by 2
   frac_shifted <= frac_A_b1 when exp_odd = '1' else frac_A_b2;
  
   a_sqrt: sqrt_wsticky generic map(N => P+2) 
      PORT MAP(D => frac_shifted, Q => sqrt_frac, sticky => sticky_bit);
   
   sqrt_exponent <= ('0' & exp_A(E-1 downto 1)) + BIAS_div2 + exp_odd; 

   isRoundUp <= sqrt_frac(1) and (sqrt_frac(0) or sticky_bit);
   frac_final <= sqrt_frac(P downto 2) + isRoundUp;
   exp_final <= sqrt_exponent;

   packing: process(sign, isNaN, isInf, isZero, exp_final, frac_final)
   begin
     FP_Z_int(K-1) <= sign;
     if (isNaN='1') then
         FP_Z_int(K-2 downto P-1) <= ONES(E-1 downto 0);
         FP_Z_int(P-2 downto 0) <= '1' & ZEROS(P-3 downto 0);
      elsif (isInf='1') then -- overflow is not considered
         FP_Z_int(K-2 downto P-1) <= ONES(E-1 downto 0);
         FP_Z_int(P-2 downto 0) <= ZEROS(P-2 downto 0);
      elsif (isZero='1') then -- underflow is not considered
         FP_Z_int(K-2 downto P-1) <= ZEROS(E-1 downto 0);
         FP_Z_int(P-2 downto 0) <= ZEROS(P-2 downto 0);
      else	
         FP_Z_int(K-2 downto P-1) <= exp_final;
         FP_Z_int(P-2 downto 0) <= frac_final;
      end if;
   end process;

   final_reg: process(clk)
   begin
      if rising_edge(clk) then
         if ce = '1' then
            FP_Z <= FP_Z_int;
         end if;
      end if;
   end process;
     
end simple_arch;
