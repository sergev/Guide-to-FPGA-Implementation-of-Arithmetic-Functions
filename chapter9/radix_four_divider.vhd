----------------------------------------------------------------------------
-- radix_four_divider.vhd
--
-- section 9.2.5 radix 2^k division
--
--x = xn xn-1 ... x1 x0: integer in 2's complement form
--y = 1 yn-2 ... y1 y0: natural 
--condition: -y <= x < y
--quotient q =  q0. q1 ... q2p-1 q2p: fractional in 2's complement form
--remainder r = rn rn-1 ... r1 r0: integer in 2's complement form
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY radix_four_divider IS
  GENERIC(n: NATURAL:= 16; p: NATURAL:= 8);
PORT(
  x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  clk, reset, start:IN STD_LOGIC;
  quotient: OUT STD_LOGIC_VECTOR(0 TO 2*p);
  remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
  done: OUT STD_LOGIC
);
END radix_four_divider;

ARCHITECTURE circuit OF radix_four_divider IS
  SIGNAL r, next_r, zero_y, one_y, two_y, three_y, four_r, second_operand: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL short_r: STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL signed_digit, two_or_three, minus_two_or_three: STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL load, update: STD_LOGIC;
  SIGNAL q, qm: STD_LOGIC_VECTOR(0 TO 2*p);
  
  SUBTYPE index IS NATURAL RANGE 0 TO p-1;
  SIGNAL count: index;
  TYPE state IS RANGE 0 TO 3;
  SIGNAL current_state: state;
  
BEGIN
  zero_y <= (OTHERS => '0');
  one_y <= '0'&y;
  two_y <= one_y + one_y;
  three_y <= one_y + two_y;
  four_r <= r(n-2 DOWNTO 0)&"00";
  two_or_three <= "01"&NOT(y(n-2));
  minus_two_or_three <= '1'&y(n-2)&NOT(y(n-2));
  short_r <= r(n DOWNTO n-3);
  
  WITH short_r SELECT signed_digit <=
    "000" WHEN "0000",
    "001" WHEN "0001",
    "010" WHEN "0010",
    two_or_three WHEN "0011",
    "011" WHEN "0100",
    "011" WHEN "0101",
    "011" WHEN "0110",
    "011" WHEN "0111",
    "101" WHEN "1000",
    "101" WHEN "1001",
    "101" WHEN "1010",
    "101" WHEN "1011",
    minus_two_or_three WHEN "1100",
    "110" WHEN "1101",
    "111" WHEN "1110",
    "000" WHEN OTHERS;
  
  WITH signed_digit SELECT second_operand <=
    zero_y WHEN "000",
    one_y WHEN "001",
    two_y WHEN "010",
    three_y WHEN "011",
    three_y WHEN "101",
    two_y WHEN "110",
    one_y WHEN OTHERS;

  WITH signed_digit(2) SELECT next_r <= four_r - second_operand WHEN '0', four_r + second_operand WHEN OTHERS;
  
  remainder_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r <= x;
      ELSIF update = '1' THEN r <= next_r;
      END IF;  
    END IF;
  END PROCESS;
  remainder <= r;

  q_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN q <= (OTHERS => '0');
      ELSIF update = '1' THEN 
        CASE signed_digit IS
          WHEN "000" => q(0 TO 2*p-2) <= q(2 TO 2*p); q(2*p-1 TO 2*p) <= "00";
          WHEN "001" => q(0 TO 2*p-2) <= q(2 TO 2*p); q(2*p-1 TO 2*p) <= "01";
          WHEN "010" => q(0 TO 2*p-2) <= q(2 TO 2*p); q(2*p-1 TO 2*p) <= "10";
          WHEN "011" => q(0 TO 2*p-2) <= q(2 TO 2*p); q(2*p-1 TO 2*p) <= "11";
          WHEN "101" => q(0 TO 2*p-2) <= qm(2 TO 2*p); q(2*p-1 TO 2*p) <= "01";
          WHEN "110" => q(0 TO 2*p-2) <= qm(2 TO 2*p); q(2*p-1 TO 2*p) <= "10";
          WHEN OTHERS => q(0 TO 2*p-2) <= qm(2 TO 2*p); q(2*p-1 TO 2*p) <= "11";
        END CASE;
      END IF;  
    END IF;
  END PROCESS;

  qm_register: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN qm(0 TO 2*p-2) <= (OTHERS => '0'); qm(2*p-1 TO 2*p) <= "11";
      ELSIF update = '1' THEN 
        CASE signed_digit IS
          WHEN "000" => qm(0 TO 2*p-2) <= qm(2 TO 2*p); qm(2*p-1 TO 2*p) <= "11";
          WHEN "001" => qm(0 TO 2*p-2) <= q(2 TO 2*p); qm(2*p-1 TO 2*p) <= "00";
          WHEN "010" => qm(0 TO 2*p-2) <= q(2 TO 2*p); qm(2*p-1 TO 2*p) <= "01";
          WHEN "011" => qm(0 TO 2*p-2) <= q(2 TO 2*p); qm(2*p-1 TO 2*p) <= "10";
          WHEN "101" => qm(0 TO 2*p-2) <= qm(2 TO 2*p); qm(2*p-1 TO 2*p) <= "00";
          WHEN "110" => qm(0 TO 2*p-2) <= qm(2 TO 2*p); qm(2*p-1 TO 2*p) <= "01";
          WHEN OTHERS => qm(0 TO 2*p-2) <= qm(2 TO 2*p); qm(2*p-1 TO 2*p) <= "10";
        END CASE;
      END IF;  
    END IF;
  END PROCESS;
  quotient <= q;

  counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT and clk = '1' THEN
      IF load = '1' THEN count <= 0; 
      ELSIF update = '1' THEN count <= (count+1) MOD p;
      END IF;
    END IF;
  END PROCESS;

  next_state: PROCESS(clk, reset)
  BEGIN
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
        WHEN 2 => current_state <= 3;
        WHEN 3 => IF count = p-1 THEN current_state <= 0; END IF;
      END CASE;
    END IF;
  END PROCESS;

  output_function: PROCESS(clk, current_state)
  BEGIN
    CASE current_state IS
      WHEN 0 TO 1 => load <= '0'; update <= '0'; done <= '1';
      WHEN 2 => load <= '1'; update <= '0'; done <= '0';
      WHEN 3 => load <= '0'; update <= '1'; done <= '0';
    END CASE;
  END PROCESS;
  
END circuit;
