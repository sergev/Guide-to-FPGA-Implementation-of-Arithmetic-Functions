--------------------------------------------------------------------------------
-- Simple testbench for fp_div
-- reads a stimuli file and comprare results
--
--------------------------------------------------------------------------------
LIBRARY  IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

LIBRARY ieee;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY fp_div_tb IS
END fp_div_tb;
 
ARCHITECTURE behavior OF fp_div_tb IS 

   constant K: natural:= 32; 
   constant P: natural:= 24;
   constant E: natural:= 8; 
   constant DELAY_CYC: natural := 1; --if pipeline or registers.
   
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT fp_div is
    generic(K: natural:= K; P: natural:= P; E: natural:= E);
    Port ( FP_A : in  std_logic_vector (K-1 downto 0);
           FP_B : in  std_logic_vector (K-1 downto 0);
           clk : in  std_logic;
           ce  : in  std_logic;
           FP_Z : out  std_logic_vector (K-1 downto 0));
    END COMPONENT;
   

   --Inputs
   signal ce : std_logic := '0';
   signal ADD_SUB : std_logic := '0';
   signal FP_A : std_logic_vector(K-1 downto 0) := (others => '0');
   signal FP_B : std_logic_vector(K-1 downto 0) := (others => '0');
   signal clk : std_logic := '0';

   --Outputs
   signal FP_Z: std_logic_vector(K-1 downto 0);
   signal equals : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10ns;

   type connectionmatrix is array (DELAY_CYC downto 0) of STD_LOGIC_VECTOR (K-1 downto 0);
   FILE stimuli_file: TEXT OPEN READ_MODE IS "dataDivFloat.txt";
   signal z_file: connectionmatrix;
   signal FP_Z_file: std_logic_vector(K-1 downto 0);
   signal isNan: std_logic;
   constant ONES : std_logic_vector(E-1 downto 0) := (others => '1');

BEGIN
 
   -- Instantiate the Unit Under Test (UUT)
   uut: fp_div PORT MAP (
          FP_A => FP_A, FP_B => FP_B,
          ce => ce, clk => clk,
          FP_Z => FP_Z );

   -- Clock process definitions
   clk_process :process
   begin
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
      wait for clk_period/2;
   end process;
   
   
   read_file: process --reading the file
      variable linea : line;
      variable num: std_logic_vector (31 downto 0) ;
      variable num1, num2, num3: string (8 downto 1);
      variable char:  string (1 downto 1);
     
     procedure  read_hex_natural(str: in string; vector: out std_logic_vector (31 downto 0)) is
         variable result: natural := 0;
     begin
     --assert false report "str: " & str severity NOTE;
         for i in 8 downto 1 loop
             if ('0' <= str(i) and str(i) <= '9') then
                 result:= character'pos(str(i))-character'pos('0');
             elsif 'a' <= str(i) and str(i) <= 'f' then
                 result := character'pos(str(i))-character'pos('a')+10;
             elsif 'A' <= str(i) and str(i) <= 'F' then
                 result := character'pos(str(i))-character'pos('A')+10;
             else
                 report "error" severity error;
             end if;
             vector((i*4-1) downto (i-1)*4) := CONV_STD_LOGIC_VECTOR(result,4);
         end loop;
     end read_hex_natural;

      begin
         --wait for clk_period;
         read_loop:while (not endfile(stimuli_file)) loop
            readline(stimuli_file, linea);
            read (linea, num1);
            read (linea, char);
            read (linea, num2);
            read (linea, char);
            read (linea, num3);
            read_hex_natural(num1,num);
            FP_A <= num;
            read_hex_natural(num2,num);
            FP_B <= num;
            read_hex_natural(num3,num);
            z_file(DELAY_CYC) <= num;
                
            fl: for i in DELAY_CYC-1 downto 0  loop
               z_file(i) <= z_file(i+1);
            end loop;
            wait for clk_period;
            assert equals = '1' report "not equals" severity FAILURE;

         end loop read_loop;
            
         moreIterac: for j in DELAY_CYC downto 0  loop
            wait for clk_period/2;
            fl2: for i in DELAY_CYC-1 downto 0  loop
               z_file(i) <= z_file(i+1);
            end loop;
         wait for clk_period/2;
         end loop;
      assert false report "Simulation OK. NO errors" severity FAILURE;
   end process;

   ce <= '1';
   ADD_SUB <= '1';
   FP_Z_file <= z_file(0);
   isNan <= '1' when (FP_Z_file(K-2 downto K-E-1) = ONES) and (FP_Z_file(K-2 downto K-E-1) = ONES) else '0';
   equals <= '1' when ((FP_Z_file = FP_Z) or (isNan='1')) else '0';


END;
