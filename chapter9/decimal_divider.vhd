----------------------------------------------------------------------------
-- decimal_divider.vhd
--
-- section 9.3 radix B division, B=10.
--
-- x is a signed n-digit decimal number
-- y is an n-digit decimal natural
-- (-y) <= x < y
-- q is a signed m-digit decimal number
-- q·2^(-m) is an approximation of x/y
-- error < 2^(-p)
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
ENTITY decimal_divider IS 
  GENERIC(n: NATURAL:= 16; m : NATURAL:= 16; p: NATURAL:= 54;  logp: NATURAL:= 6);
PORT(
  x: IN STD_LOGIC_VECTOR (4*n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR (4*n-1 DOWNTO 0);
  clk, reset, start: IN STD_LOGIC;
  q: OUT STD_LOGIC_VECTOR (4*m DOWNTO 0);
  done: OUT STD_LOGIC
);
END decimal_divider;

ARCHITECTURE circuit OF decimal_divider IS
  COMPONENT doubling_circuit2 IS
    GENERIC(n: NATURAL);
  PORT(
    x: IN STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
    c_in: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(4*n DOWNTO 0)  );
  END COMPONENT;
  COMPONENT multiply_by_five IS
    GENERIC(n: NATURAL);
  PORT(
    x: IN STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(4*n+3 DOWNTO 0)
  );
  END COMPONENT;

  SIGNAL r, two_r, next_r, second_operand, complement_of_y: STD_LOGIC_VECTOR(4*n DOWNTO 0);
  SIGNAL carry1: STD_LOGIC_VECTOR(n DOWNTO 0);
  SIGNAL carry2: STD_LOGIC_VECTOR(p DOWNTO 0);
  SIGNAL ulp, next_ulp: STD_LOGIC_VECTOR(4*p-1 DOWNTO 0);
  SIGNAL complement_of_ulp, signed_ulp: STD_LOGIC_VECTOR(4*p DOWNTO 0);
  SIGNAL next_ulp_by_ten: STD_LOGIC_VECTOR(4*p+3 DOWNTO 0);
  SIGNAL long_q, next_q: STD_LOGIC_VECTOR (4*p DOWNTO 0);
  SIGNAL load, update, zero: STD_LOGIC;
  SIGNAL count: STD_LOGIC_VECTOR(logp-1 DOWNTO 0);
  TYPE states IS RANGE 0 TO 3;
  SIGNAL current_state: states;
BEGIN

  a_doubling_circuit: doubling_circuit2 GENERIC MAP(n => n)
    PORT MAP(x => r(4*n-1 DOWNTO 0), z => two_r, c_in => '0');

  complement_y: FOR i IN 0 TO n-1 GENERATE
    complement_of_y(4*i+3 DOWNTO 4*i) <= "1001" - y(4*i+3 DOWNTO 4*i);
  END GENERATE;
  complement_of_y(4*n) <= '1';
  WITH r(4*n) SELECT second_operand <= ('0'&y) WHEN '1', complement_of_y WHEN OTHERS; 

  carry1(0) <= NOT(r(4*n));
  a_decimal_adder: FOR i IN 0 TO n-1 GENERATE
    carry1(i+1) <= '1' WHEN ('0'&two_r(4*i+3 DOWNTO 4*i) + second_operand(4*i+3 DOWNTO 4*i) + carry1(i)) >= "01010" ELSE '0';
    next_r(4*i+3 DOWNTO 4*i) <= 
      two_r(4*i+3 DOWNTO 4*i) + second_operand(4*i+3 DOWNTO 4*i) + carry1(i) WHEN carry1(i+1) = '0'
      ELSE two_r(4*i+3 DOWNTO 4*i) + second_operand(4*i+3 DOWNTO 4*i) + carry1(i) + "0110"; 
  END GENERATE;
  next_r(4*n) <= two_r(4*n) XOR second_operand(4*n) XOR carry1(n);

  complement_ulp: FOR i IN 0 TO p-1 GENERATE
    complement_of_ulp(4*i+3 DOWNTO 4*i) <= "1001" - ulp(4*i+3 DOWNTO 4*i);
  END GENERATE;
  complement_of_ulp(4*p) <= '1';
  WITH r(4*n) SELECT signed_ulp <= ('0'&ulp) WHEN '0', complement_of_ulp WHEN OTHERS; 

  carry2(0) <= r(4*n);
  another_decimal_adder: FOR i IN 0 TO p-1 GENERATE
    carry2(i+1) <= '1' WHEN ('0'&long_q(4*i+3 DOWNTO 4*i) + signed_ulp(4*i+3 DOWNTO 4*i) + carry2(i)) >= "01010" ELSE '0';
    next_q(4*i+3 DOWNTO 4*i) <= 
      long_q(4*i+3 DOWNTO 4*i) + signed_ulp(4*i+3 DOWNTO 4*i) + carry2(i) WHEN carry2(i+1) = '0'
      ELSE long_q(4*i+3 DOWNTO 4*i) + signed_ulp(4*i+3 DOWNTO 4*i) + carry2(i) + "0110"; 
  END GENERATE;
  next_q(4*p) <= long_q(4*p) XOR signed_ulp(4*p) XOR carry2(p);
  
  a_multiply_by_five_circuit: multiply_by_five 
    GENERIC MAP(n => p)
    PORT MAP(x => ulp, z => next_ulp_by_ten);  
  next_ulp <= next_ulp_by_ten(4*p+3 DOWNTO 4);

  register_r: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN r <= x;
      ELSIF update = '1' THEN r <= next_r;
      END IF;
    END IF;
  END PROCESS;

  register_q: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN long_q <= (OTHERS => '0');
      ELSIF update = '1' THEN long_q <= next_q;
      END IF;
    END IF;
  END PROCESS;
  q <= long_q(4*p DOWNTO 4*(p-m));

  register_ulp: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN       
        ulp(4*p-1 DOWNTO 4*p-4) <= "0101"; ulp(4*p-5 DOWNTO 0) <=(OTHERS => '0');
      ELSIF update = '1' THEN ulp <= next_ulp;
      END IF;
    END IF;
  END PROCESS;

  a_counter: PROCESS(clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF load = '1' THEN count <= CONV_STD_LOGIC_VECTOR(p-1, logp);
      ELSIF update = '1' THEN count <= count -1;
      END IF;
    END IF;
  END PROCESS;
  zero <= '1' WHEN count = 0 ELSE '0';

  control_unit: PROCESS(clk, reset, current_state, zero)
  BEGIN
    CASE current_state IS
      WHEN 0 to 1 => load <= '0'; update <= '0'; done <= '1';
      WHEN 2 => load <= '1'; update <= '0'; done <= '0';
      WHEN 3 => load <= '0'; update <= '1'; done <= '0';
    END CASE;
    IF reset = '1' THEN current_state <= 0;
    ELSIF clk'EVENT AND clk = '1' THEN
      CASE current_state IS
        WHEN 0 => IF start = '0' THEN current_state <= 1; END IF;
        WHEN 1 => IF start = '1' THEN current_state <= 2; END IF;
        WHEN 2 => current_state <= 3;
        WHEN 3 => IF zero = '1' THEN current_state <= 0; END IF;
      END CASE;
    END IF;
  END PROCESS;
END circuit;
