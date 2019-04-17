--------------------------------------------------------------------------
-- range detection
-- inputs1: approximations of y, 2·y, ... , 9·y;
-- input2: w";
-- result: signed digit (-1)^sign·q;
-- internally w'' is compared with the approximations of y, 2·y, ... , 9·y
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity range_detection3 is 
    Port ( 
      one_y, two_y, three_y, four_y, five_y, six_y, seven_y, eight_y, nine_y: in STD_LOGIC_VECTOR (11 downto 0); 
      ww: in STD_LOGIC_VECTOR (19 downto 0);
      sign: out STD_LOGIC;
      q: out STD_LOGIC_VECTOR(3 downto 0)
      );
end range_detection3;

architecture circuit of range_detection3 is

   signal sum1, sum2, sum3, sum4, sum5, sum6, sum7, sum8, sum9: STD_LOGIC_VECTOR (19 downto 0); 
   signal long_1_y, long_2_y, long_3_y, long_4_y, long_5_y, long_6_y, long_7_y, long_8_y, long_9_y: STD_LOGIC_VECTOR (19 downto 0);  
   signal addsub: STD_LOGIC;
   signal cyout: STD_LOGIC_VECTOR (9 downto 1);  
   signal cyout2: STD_LOGIC_VECTOR (9 downto 1);  
   type long_y_type is array (1 to 9) of STD_LOGIC_VECTOR (19 downto 0);  
   signal long_y: long_y_type;

   component addsubBCD_v2 is 
       generic (NDigit: natural:= 5);
       Port ( 
           a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           addsub : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
   end component;
begin

   addsub <= not(ww(16));
   long_y(1) <= "00000000"&one_y;
   long_y(2) <= "00000000"&two_y;
   long_y(3) <= "00000000"&three_y;
   long_y(4) <= "00000000"&four_y;
   long_y(5) <= "00000000"&five_y;
   long_y(6) <= "00000000"&six_y;
   long_y(7) <= "00000000"&seven_y;
   long_y(8) <= "00000000"&eight_y;
   long_y(9) <= "00000000"&nine_y;

   fg: for i in 1 to 9 generate
     add_subt: addsubBCD_v2 generic map(NDigit => 5)
       port map( a => ww, b => long_y(i), addsub => addsub, cout=> cyout(i));
   end generate;

   combinational_circuit: process(ww, cyout)
   begin
   if ww(16) = '0' then
     if cyout(1) = '0' then q <= "0001";
     elsif cyout(2) = '0' then q <= "0010";
     elsif cyout(3) = '0' then q <= "0011";
     elsif cyout(4) = '0' then q <= "0100";
     elsif cyout(5) = '0' then q <= "0101";
     elsif cyout(6) = '0' then q <= "0110";
     elsif cyout(7) = '0' then q <= "0111";
     elsif cyout(8) = '0' then q <= "1000";
     else q <= "1001";
     end if;
   else
     if cyout(1) = '1' then q <= "0000";
     elsif cyout(2) = '1' then q <= "0001";
     elsif cyout(3) = '1' then q <= "0010";
     elsif cyout(4) = '1' then q <= "0011";
     elsif cyout(5) = '1' then q <= "0100";
     elsif cyout(6) = '1' then q <= "0101";
     elsif cyout(7) = '1' then q <= "0110";
     elsif cyout(8) = '1' then q <= "0111";
     elsif cyout(9) = '1' then q <= "1000";
     else q <= "1001";
     end if;
   end if;
   end process;

   sign <= addsub;

end circuit;

