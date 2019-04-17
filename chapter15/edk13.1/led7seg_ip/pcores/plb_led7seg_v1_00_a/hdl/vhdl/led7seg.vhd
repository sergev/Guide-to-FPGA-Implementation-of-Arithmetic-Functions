library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity led7seg is
	port(
		Clk: in std_logic;
		Rst: in std_logic;
		Refresh: in std_logic;
		Zeros: in std_logic;
		Off: in std_logic;
		Data: in std_logic_vector(15 downto 0);
		Segments: out std_logic_vector(6 downto 0);
		Anodes: out std_logic_vector(3 downto 0));
end entity;

architecture BEH1 of led7seg is

function F_ANODES(a: integer) return std_logic_vector is
variable o: std_logic_vector(3 downto 0):=(others=>'0');
begin
	o(a):='1';
	return o;
end function;

function F_DIGIT4(a: std_logic_vector(15 downto 0); b: integer) return std_logic_vector is
type T_DIGITS is array(3 downto 0) of std_logic_vector(3 downto 0);
variable i: T_DIGITS:=(a(15 downto 12), a(11 downto 8), a(7 downto 4), a(3 downto 0));
variable o: std_logic_vector(3 downto 0);
begin
	o:=i(b);
	return o;
end function;

function F_SEGMENTS(a: std_logic_vector(3 downto 0)) return std_logic_vector is
variable i: std_logic_vector(7 downto 0);
variable o: std_logic_vector(6 downto 0);
begin
	case conv_integer(unsigned(a)) is
		when 0=> i:=X"3F";
		when 1=> i:=X"06";
		when 2=> i:=X"5B";
		when 3=> i:=X"4F";
		when 4=> i:=X"66";
		when 5=> i:=X"6D";
		when 6=> i:=X"7D";
		when 7=> i:=X"07";
		when 8=> i:=X"7F";
		when 9=> i:=X"67";
		when 10=> i:=X"77";
		when 11=> i:=X"7C";
		when 12=> i:=X"39";
		when 13=> i:=X"5E";
		when 14=> i:=X"79";
		when 15=> i:=X"71";
		when others=> i:=X"00";
	end case;
	o:=i(o'range);
	return o;
end function;

signal idx: integer range 0 to 3;

begin

	process(Clk,Rst,Refresh)
	begin
		if Rst='1' then
			idx<=3;
		elsif rising_edge(Clk) and Refresh='1' then
			if idx=0 then
				idx<=3;
			else
				idx<=idx-1;
			end if;
		end if;
	end process;
	
	process(Clk,Rst,Refresh,idx,data)
	variable digit4: std_logic_vector(3 downto 0);
	variable prev_zero: std_logic;
	begin
		if Rst='1' then
			Segments<=(others=>'0');
			Anodes<=(others=>'0');
		elsif rising_edge(Clk) and Refresh='1' then
			if Off='1' then
				Anodes<=(others=>'0');
			else 
				digit4:=F_DIGIT4(data,idx);
				Segments<=F_SEGMENTS(digit4);
				Anodes<=F_ANODES(idx);
				if idx=3 then
					prev_zero:='1';
				end if;
				if digit4="0000" then
					if Zeros='0' and prev_zero='1' and idx/=0 then
						Anodes<=(others=>'0');
					end if;
				else
					prev_zero:='0';
				end if;
			end if;
		end if;
	end process;

end architecture;