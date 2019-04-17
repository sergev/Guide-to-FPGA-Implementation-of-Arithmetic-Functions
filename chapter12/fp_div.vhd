----------------------------------------------------------------------------------
-- Floating Point Divider for binary IEEE 754 (fp_div.vhd)
-- Combinational version
--
-- Do not support subnormals. They are interpreted as zeros.
--
-- Section 12.5.3. Example 12.10. Floating Point Division
-- Combinational circuits but registering input and output. 
-- For pipelined version contact the authors at arithmetic-circuits.org
--
-- K size of FP (s, exp, significand). Also Extorege width
-- E size of Exponent
-- P size of significant or fractional (includind the 1.). Also precision.
-- K = E+P
-- D is the pipeline depth of divider; 
-- That means that result will be sup((P+3)/D) cycles later.
--
-- binary32; K=32, E= 8, P=24
-- binary64; K=64, E=11, P=53
--
-- In code is used the name frac (from fractional) instead of sig (from significant) 
-- in order to not be confused with the sign.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity FP_div is
   --generic(K: natural:= 64; P: natural:= 53; E: natural:= 11; D: natural:= 4);
   generic(K: natural:= 32; P: natural:= 24; E: natural:= 8);
   port (
      FP_A: in std_logic_vector (K-1 downto 0);
      FP_B: in std_logic_vector (K-1 downto 0);
      clk: in std_logic;
      ce:  in std_logic;
      FP_Z: out std_logic_vector (K-1 downto 0)
   );
end FP_div;

architecture Behavioral of FP_div is
   
   -- Internal constant declarations
   constant ZEROS : std_logic_vector(K-1 downto 0) := (others => '0');
   constant ONES : std_logic_vector(K-1 downto 0) := (others => '1');
   constant BIAS : std_logic_vector(E-1 downto 0) := '0' & ONES(E-2 downto 0) ; --7Fh in 32 bits, 3FFh 64bits
   constant PBITS : natural := P+3; --P plus the 3 bits necessary in rounding
   
   component div_nr_wsticky is
   generic(NBITS : integer; PBITS : integer);
   port (
      A: in std_logic_vector (NBITS-1 downto 0);
      B: in std_logic_vector (NBITS-1 downto 0);
      Q: out std_logic_vector (PBITS-1 downto 0);
      sticky : out std_logic );
   end component;
   
   signal A_int, B_int, FP_Z_int: std_logic_vector (K-1 downto 0);
   signal exp_A, exp_B: std_logic_vector (E-1 downto 0);
   signal frac_A, frac_B: std_logic_vector (P-1 downto 0);
   signal sign_A, sign_B : std_logic;
   
   signal expA_FF, expB_FF, expA_Z, expB_Z : std_logic;
   signal fracA_Z, fracB_Z : std_logic;
   signal exp_noBIAS, exp_Biased, exp_Biased_Norm: std_logic_vector (E downto 0);
   
   signal isNaN_A, isNaN_B, isInf_A, isInf_B, isZero_A, isZero_B : std_logic;
   signal isNaN, isInf, isZero: std_logic;
   signal sign : std_logic;
   
   signal frac_div: std_logic_vector (PBITS-1 downto 0);
   signal frac_div_shifted: std_logic_vector (PBITS-1 downto 0);
   signal fr_sh: std_logic_vector (PBITS-2 downto 0); --alias of frac_div_shifted
   signal frac_final: std_logic_vector (P-2 downto 0);
   signal underflow, overflow: std_logic;
   signal exp_final : std_logic_vector(E-1 downto 0);
   
   signal sticky_bit : std_logic;
   signal div_by_zero: std_logic;
   
begin
   
   -- register input for timing analisys
   process(clk)
   begin
      if clk'event and clk='1' then
         if ce = '1' then
            A_int <= FP_A;
            B_int <= FP_B;
         end if;
      end if;
   end process;

   -- FP unpacking & special cases detection
   sign_A <= A_int(K-1);
   sign_B <= B_int(K-1);
   exp_A  <= A_int(K-2 downto K-E-1);   
   exp_B  <= B_int(K-2 downto K-E-1);
   frac_A <= '1' & A_int(P-2 downto 0); -- Restore hidden 1.sssss when not zero or denormal
   frac_B <= '1' & B_int(P-2 downto 0); 
   
   expA_FF <= '1' when A_int(K-2 downto K-E-1)= ONES(K-2 downto K-E-1) else '0'; 
   expB_FF <= '1' when B_int(K-2 downto K-E-1)= ONES(K-2 downto K-E-1) else '0';
   expA_Z  <= '1' when A_int(K-2 downto K-E-1)= ZEROS(K-2 downto K-E-1) else '0';
   expB_Z  <= '1' when B_int(K-2 downto K-E-1)= ZEROS(K-2 downto K-E-1) else '0';
   fracA_Z <= '1' when A_int(P-2 downto 0) = ZEROS(P-2 downto 0) else '0'; 
   fracB_Z <= '1' when B_int(P-2 downto 0) = ZEROS(P-2 downto 0) else '0';
   
   isNaN_A <= expA_FF and (not fracA_Z);
   isNaN_B <= expB_FF and (not fracB_Z);
   isInf_A <= expA_FF; -- not compared the fractional part since NaN has priority.
   isInf_B <= expB_FF; -- 
   isZero_A <= expA_Z and fracA_Z;
   isZero_B <= expB_Z and fracB_Z;

   --special cases computation
   div_by_zero <= expB_Z; -- isZero_B or subnormal;
   isNaN <= isNaN_A or isNaN_B;
   isInf <= isInf_A or isInf_B or div_by_zero; --division(inf, x) or division(x, inf) for finite x; division by zero or subnormal
   isZero <= isZero_A and not isZero_B;   

   exp_noBias <= ('0' & exp_A) - ('0' & exp_B); -- one bit more to detect overflow 
   exp_Biased <= exp_noBias + ('0' & BIAS);
   sign <= sign_A xor sign_B;
                     
   a_div : div_nr_wsticky generic map(NBITS => P, PBITS => PBITS) 
      port map(A => frac_A, B => frac_B, Q => frac_div, sticky => sticky_bit);
   
   --Normalization: shitf if significand < 1 
   frac_div_shifted <= frac_div(PBITS-2 downto 0) & '0' when frac_div(PBITS-1) = '0' else frac_div;
                              
   --sub 1 to exponent when significand is shifted (adjust in normalization)
   exp_Biased_Norm <= exp_Biased - 1 when frac_div(PBITS-1) = '0' else exp_Biased;
   exp_final <= exp_Biased_Norm(E-1 downto 0);
   -- overflow if exp > 2^e or exp = 2^e-1(inf representation).
   overflow <= '1' when ((exp_Biased_Norm(E downto E-1) = "10") or (exp_Biased_Norm(E downto 0) = '0' & ONES(E-1 downto 0) ) ) else '0';
   --underflow if exp < 0 or exp = 0 (subnormal and zero representation).
   underflow <= '1' when ((exp_Biased_Norm(E downto E-1) = "11") or (exp_Biased_Norm(E-1 downto 0) = ZEROS(E-1 downto 0) ) ) else '0';
   
   --rounding
   fr_sh <= frac_div_shifted(PBITS-2 downto 0);
   frac_final <= fr_sh(PBITS-2 downto PBITS-P) + 1 when (fr_sh(2) = '1' and (sticky_bit = '1' or fr_sh(0) = '1' or fr_sh(1) = '1')) else
                 fr_sh(PBITS-2 downto PBITS-P) + 1 when ( (sticky_bit = '1') and (fr_sh(2 downto 0) = "100") and (fr_sh(3) = '1')) else -- tie to even
                 fr_sh(PBITS-2 downto PBITS-P);
    
   packing: process(sign, isNaN, isInf, isZero, exp_final, frac_final, underflow, overflow)
   begin
     FP_Z_int(K-1) <= sign;
     if (isNaN='1') then
         FP_Z_int(K-2 downto P-1) <= ONES(E-1 downto 0);
         FP_Z_int(P-2 downto 0) <= '1' & ZEROS(P-3 downto 0);
      elsif (isInf='1') or (overflow = '1') then
         FP_Z_int(K-2 downto P-1) <= ONES(E-1 downto 0);
         FP_Z_int(P-2 downto 0) <= ZEROS(P-2 downto 0);
      elsif (isZero='1') or (underflow = '1') then
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

end Behavioral;

