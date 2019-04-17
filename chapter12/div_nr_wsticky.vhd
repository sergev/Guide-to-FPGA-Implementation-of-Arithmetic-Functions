---------------------------------------------------------------
-- NON RESTORING Divider (div_nr_wsticky.vhd)
-- No pipelined version. Used in combinational FP divider.
--
-- NBITS, number of bits of inputs (dividend and divisor).
-- PBITS, number of bits of output (quotient)
-- 
-- Return que quotient Q of PBITS. 
-- The remainder is reduced to a STICKY BIT
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity div_nr_wsticky is
   generic( NBITS : integer := 6; PBITS : integer := 8);
   port (
      A: in STD_LOGIC_VECTOR (NBITS-1 downto 0);
      B: in STD_LOGIC_VECTOR (NBITS-1 downto 0);
      Q: out STD_LOGIC_VECTOR (PBITS-1 downto 0);
      sticky : out STD_LOGIC
   );
end div_nr_wsticky;

architecture div_arch of div_nr_wsticky is

   component a_s is
   generic( NBITS : integer);
   port (
      op_a: in STD_LOGIC_VECTOR (NBITS downto 0);
      op_m: in STD_LOGIC_VECTOR (NBITS downto 0);
      as: in STD_LOGIC;
      outp: out STD_LOGIC_VECTOR (NBITS downto 0)
   );
   end component;

   constant ZEROS: STD_LOGIC_VECTOR (NBITS-1 downto 0) := (others=>'0');
   type matrizconexion is array (0 to PBITS) of STD_LOGIC_VECTOR (NBITS downto 0);
   type matrizconexion_P is array (0 to PBITS) of STD_LOGIC_VECTOR (PBITS-1 downto 0);

   Signal YY_in: matrizconexion;
   Signal QQ_in: matrizconexion_P;
   Signal m_cablesIn, m_cablesOut: matrizconexion;

   Signal a_or_s: STD_LOGIC_VECTOR (PBITS downto 0);
   Signal QQ: STD_LOGIC_VECTOR (PBITS-1 downto 0);
   Signal YY, XX: STD_LOGIC_VECTOR (NBITS-1 downto 0);

begin

   XX <= A;
   YY <= B;
   Q <= QQ;

   a_or_s(0) <= '0'; 
   m_cablesIn(0) <= '0' & XX;
   YY_IN(0) <= '0' & YY;
   
   divisor: for I in 0 to PBITS-1 generate
    int_mod: a_s generic map(NBITS => NBITS)
    port map (op_a => m_cablesIn(i), op_m => YY_IN(i), 
                as => a_or_s(i), outp => m_cablesOut(i) );
   end generate;

   -- cable connections
   conex: for I in 0 to PBITS-1 generate
            a_or_s(i+1) <= m_cablesOut(i)(NBITS);	 
            m_cablesIn(i+1) <= m_cablesOut(i)(NBITS-1 downto 0) & '0';
            YY_IN(i+1) <= YY_IN(i);
            QQ_in(i+1)(i) <= a_or_s(i+1);
            rest : if I > 0 generate QQ_in(i+1)(I-1 downto 0) <= QQ_in(i)(I-1 downto 0); end generate;
     end generate;

   quotient: for I in 0 to PBITS-1 generate
   QQ(I) <= not QQ_in(PBITS)(PBITS-1-I);
   end generate;

   sticky <= '0' when m_cablesOut(PBITS-1) = ZEROS else '1';
 
end div_arch;


