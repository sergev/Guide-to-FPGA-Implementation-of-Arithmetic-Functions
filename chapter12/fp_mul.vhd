----------------------------------------------------------------------------------
-- Floating Point Multiplication for binary IEEE 754 (fp_mul.vhd)
--
-- Do not support subnormals. They are interpreted as zeros.
--
-- Section 12.5.2. Example 12.9. Floating Point Multiplication
-- Combinational circuits but registering input and output. 
-- For pipelined version contact the authors at arithmetic-circuits.org
--
-- K size of FP (s, exp, significand). Also Extorege width
-- E size of Exponent
-- P size of significant or fractional (includind the 1.). Also precision.
-- K = E+P
--
-- binary32; K=32, E= 8, P=24
-- binary64; K=64, E=11, P=53
--
-- In code is used the name frac (from fractional) instead of sig (from significant) 
-- in order to not be confused with the sign.
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity FP_mul is
   --generic(K: natural:= 64; P: natural:= 53; E: natural:= 11);
   generic(K: natural:= 32; P: natural:= 24; E: natural:= 8);
   port ( FP_A : in  std_logic_vector (K-1 downto 0);
        FP_B : in  std_logic_vector (K-1 downto 0);
        clk : in  std_logic;
        ce  : in  std_logic;
        FP_Z : out  std_logic_vector (K-1 downto 0));     
end FP_mul ;

architecture one_cycle of FP_mul is

   -- Internal constant declarations
   constant ZEROS : std_logic_vector(K-1 downto 0) := (others => '0');
   constant ONES : std_logic_vector(K-1 downto 0) := (others => '1');
   
   -- Internal signal declarations
   signal A_int, B_int : std_logic_vector(K-1 downto 0);   
   signal frac_A, frac_B : std_logic_vector(P-1 downto 0);   
   signal sign_A, sign_B : std_logic;
   signal exp_A, exp_B  : std_logic_vector(E-1 downto 0);
   signal expA_FF, expB_FF, expA_Z, expB_Z : std_logic;
   signal fracA_Z, fracB_Z : std_logic;
   
   signal isNaN_A, isNaN_B, isInf_A, isInf_B, isZero_A, isZero_B, isNaN, isInf : std_logic;

   signal prod: std_logic_vector(2*P-1 downto 0);
   signal sticky, isZero: std_logic;
   
   signal exp_stg2, exp_res, exp_int: std_logic_vector(E-1 downto 0);
   signal exp_pos, exp_neg : std_logic;
   signal exp_pos_stg2, exp_neg_stg2  : std_logic;
   signal sign_stg2, sign_res : std_logic;
   signal frac_stg2, frac_res : std_logic_vector((P+3) downto 0);--3 rounding bits 
   signal isInf_stg2, isNaN_stg2, isZ_stg2  : std_logic;
   
   signal frac_norm: std_logic_vector (P+2 downto 0);    
   signal frac_round: std_logic_vector(P-1 downto 0);
   signal frac_final: std_logic_vector(P-2 downto 0); --hidden one
   signal isRoundUp, didNorm, isTwo: std_logic;
   
   signal exp_final: std_logic_vector(E-1 downto 0);
   signal FP_Z_int: std_logic_vector(K-1 downto 0);
   signal frac_isZ, isZero_f, isInf_f: std_logic;
   signal overflow, underflow: std_logic;
   
begin
   --Input Register
    process(clk)
    begin
       if (rising_edge(clk)) then
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
   isInf_A <= expA_FF; -- not compared the fractional part since NaN  has priority.
   isInf_B <= expB_FF; -- 
   isZero_A <= expA_Z and fracA_Z;
   isZero_B <= expB_Z and fracB_Z;
   
   --special cases computation
   isNaN <= (isInf_A and isZero_B) or (isZero_A and isInf_B) or (isNaN_A or isNaN_B);
   isInf <= isInf_A or isInf_B;
   isZero <= isZero_A or isZero_B;   

   -- Effective operation
   prod(2*P-1 downto 0) <= (unsigned(frac_A(P-1 downto 0)) * unsigned(frac_B(P-1 downto 0)));

   sticky_gen:process(frac_A, frac_B)
      variable firstOne_A, firstOne_B : natural;
      constant NZ : natural := P-4; --for binary32 is 20
   begin
      firstOne_A := NZ+1; firstOne_B := NZ+1;
      for i in 0 to NZ loop
         if frac_A(i) = '1' then
            firstOne_A := i; exit;
         end if;
      end loop;
      for i in 0 to NZ loop
         if frac_B(i) = '1' then
            firstOne_B := i; exit;
         end if;
      end loop;
      if firstOne_A + firstOne_B <= NZ then sticky <= '1';
      else sticky <= '0';
      end if;
   end process;

   frac_res <= prod(2*P-1 downto P-3) & sticky;  --in binary32 47..21  
   exp_int <= unsigned(exp_A) + unsigned(exp_B) + 1; --e1+e2-bias = e1+e2-2^n+1
   exp_res <= (not exp_int(E-1)) & exp_int(E-2 downto 0);
   sign_res <= sign_A xor sign_B;
   
   exp_pos  <= exp_A(E-1) and exp_B(E-1);
   exp_neg  <= not (exp_A(E-1) or exp_B(E-1));
   
   --Start second stage 
   frac_stg2     <= frac_res;
   exp_pos_stg2  <= exp_pos;
   exp_neg_stg2  <= exp_neg;
   sign_stg2     <= sign_res;
   isInf_stg2    <= isInf; 
   isNaN_stg2    <= isNaN;
   isZ_stg2      <= isZero;
   exp_stg2      <= exp_res;


   Nomalization: process(frac_stg2)
   begin
      if (frac_stg2(P+3)='1') then  --if s >= 2.0
         frac_norm <= frac_stg2(P+3 downto 2) & (frac_stg2(1) or frac_stg2(0));
         didNorm <= '1';
      else
         frac_norm <= frac_stg2(P+2 downto 0);
         didNorm <= '0';
      end if;
   end process;


   isRoundUp <= '1' when ( (frac_norm(2) = '1' and (frac_norm(1) = '1' or frac_norm(0) = '1')) or frac_norm(3 downto 0)="1100") else '0';
   frac_round <= unsigned(frac_norm(P+2 downto 3)) + isRoundUp;

   isTwo <= '1' when (frac_stg2(P+2 downto 2)= ONES(P+2 downto 2)) else '0'; 
   exp_final <= unsigned(exp_stg2) + (didNorm or isTwo);

   frac_final <= frac_round(P-2 downto 0); --cut the hidden one
   frac_isZ <= '1' when ((frac_norm(P+2 downto 2)=ZEROS(P downto 0)) ) else '0';
   isZero_f <= frac_isZ or isZ_stg2;   

   overflow <= '1' when ( ((exp_stg2(E-1 downto 1) = ONES(E-1 downto 1)) and (exp_stg2(0) = '1' or didNorm ='1' or isTwo='1')  and (exp_neg_stg2='0'))  
                         or ((exp_pos_stg2='1') and (exp_stg2(E-1)='0')) ) else '0'; --if FF or FE+1 or FE+isTwo or pos+pos = neg
   underflow <= '1' when (exp_neg_stg2='1' and exp_stg2(E-1)='1') or (exp_stg2(E-1 downto 0) = ZEROS(E-1 downto 0) and didNorm='0' and isTwo='0') else '0'; --neg+neg = pos => underflow
  
   isInf_f <= (isInf_stg2 or overflow) and (not isZero_f);
    
   packing: process(sign_stg2, isNaN_stg2,isInf_f, isZero_f, exp_final, frac_final, underflow)
   begin
     FP_Z_int(K-1) <= sign_stg2;
     
     if (isNaN_stg2='1') then
         FP_Z_int(K-2 downto P-1) <= ONES(E-1 downto 0);
         FP_Z_int(P-2 downto 0) <= '1'& ZEROS(P-3 downto 0);
      elsif (isInf_f='1') then
         FP_Z_int(K-2 downto P-1) <= ONES(E-1 downto 0);
         FP_Z_int(P-2 downto 0) <= ZEROS(P-2 downto 0);
      elsif (isZero_f='1') or (underflow = '1') then
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

end one_cycle;