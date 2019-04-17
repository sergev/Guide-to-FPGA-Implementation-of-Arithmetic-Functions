----------------------------------------------------------------------------
-- interleaved_mult.vhd
--
-- Section 13.3.2.2 Interleaved Multiplier in GF(2^m). LSB first
-- 
-- Computes the polynomial multiplication mod f in GF(2**m)
-- Implements a sequential circuit

-- Defines 2 entities (interleaved_data_path and interleaved_mult)
-- 
----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
package interleaved_mult_package is
  constant M: integer := 8;
  constant F: std_logic_vector(M-1 downto 0):= "00011011"; --for M=8 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"001B"; --for M=16 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"0101001B"; --for M=32 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"010100000101001B"; --for M=64 bits
  --constant F: std_logic_vector(M-1 downto 0):= x"0000000000000000010100000101001B"; --for M=128 bits
  --constant F: std_logic_vector(M-1 downto 0):= "000"&x"00000000000000000000000000000000000000C9"; --for M=163
  --constant F: std_logic_vector(M-1 downto 0):= (0=> '1', 74 => '1', others => '0'); --for M=233
end interleaved_mult_package;

-----------------------------------
-- Interleaved MSB-first multipication data_path
-----------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.interleaved_mult_package.all;

entity interleaved_data_path is
port (
  A: in std_logic_vector(M-1 downto 0);
  B: in std_logic_vector(M-1 downto 0);
  clk, inic, shift_r, reset, ce_c: in std_logic;
  Z: out std_logic_vector(M-1 downto 0)
);
end interleaved_data_path;

architecture rtl of interleaved_data_path is
  signal aa, bb, cc: std_logic_vector(M-1 downto 0);
  signal new_a, new_c: std_logic_vector(M-1 downto 0);
begin

  register_A: process(clk)
  --register and multiplexer
  begin
    if reset = '1' then aa <= (others => '0');
    elsif clk'event and clk = '1' then
      if inic = '1' then
         aa <= a;
      else
         aa <= new_a;
      end if;
    end if;
  end process register_A;

  sh_register_B: process(clk)
  begin
    if reset = '1' then bb <= (others => '0');
    elsif clk'event and clk = '1' then
      if inic = '1' then 
        bb <= b;
      end if;
      if shift_r = '1' then 
        bb <= '0' & bb(M-1 downto 1);
      end if;
    end if;
  end process sh_register_B;
  
  register_C: process(inic, clk)
  begin
    if inic = '1' or reset = '1' then cc <= (others => '0');
    elsif clk'event and clk = '1' then
      if ce_c = '1' then 
        cc <= new_c; 
      end if;
    end if;
  end process register_C;

  z <= cc;

  new_a(0) <= aa(m-1) and F(0);
  new_a_calc: for i in 1 to M-1 generate
    new_a(i) <= aa(i-1) xor (aa(m-1) and F(i));
  end generate;

  new_c_calc: for i in 0 to M-1 generate
    new_c(i) <= cc(i) xor (aa(i) and bb(0));
  end generate;

end rtl;

-----------------------------------
-- interleaved_mult
-----------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.interleaved_mult_package.all;
entity interleaved_mult is
port (
  A, B: in std_logic_vector (M-1 downto 0);
  clk, reset, start: in std_logic; 
  Z: out std_logic_vector (M-1 downto 0);
  done: out std_logic
);
end interleaved_mult;

architecture rtl of interleaved_mult is

component interleaved_data_path is
port (
  A: in std_logic_vector(M-1 downto 0);
  B: in std_logic_vector(M-1 downto 0);
  clk, inic, shift_r, reset, ce_c: in std_logic;
  Z: out std_logic_vector(M-1 downto 0)
);
end component;

signal inic, shift_r, ce_c: std_logic;
signal count: natural range 0 to M;
type states is range 0 to 3;
signal current_state: states;

begin

data_path: interleaved_data_path port map 
  (A => A, B => B,
   clk => clk, inic => inic, shift_r => shift_r, reset => reset, ce_c => ce_c,
   Z => Z);

counter: process(reset, clk)
begin
  if reset = '1' then count <= 0;
  elsif clk' event and clk = '1' then
    if inic = '1' then 
      count <= 0;
    elsif shift_r = '1' then
      count <= count+1; 
  end if;
  end if;
end process counter;

control_unit: process(clk, reset, current_state)
begin
  case current_state is
    when 0 to 1 => inic <= '0'; shift_r <= '0'; done <= '1'; ce_c <= '0';
    when 2 => inic <= '1'; shift_r <= '0'; done <= '0'; ce_c <= '0';
    when 3 => inic <= '0'; shift_r <= '1'; done <= '0'; ce_c <= '1';
  end case;

  if reset = '1' then current_state <= 0;
  elsif clk'event and clk = '1' then
    case current_state is
    when 0 => if start = '0' then current_state <= 1; end if;
    when 1 => if start = '1' then current_state <= 2; end if;
    when 2 => current_state <= 3;
    when 3 => if count = M-1 then current_state <= 0; end if;
    end case;
  end if;
end process control_unit;

end rtl;
