library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Adder is
	port(
		A    : in  STD_LOGIC;
		B    : in  STD_LOGIC;
		CIN  : in  STD_LOGIC;
		S    : out STD_LOGIC;
		COUT : out STD_LOGIC);
end Adder;

architecture Add of Adder is
begin
	COUT <= (A and B) or ((A xor B) and CIN);
	S    <= A xor B xor CIN;
end Add;