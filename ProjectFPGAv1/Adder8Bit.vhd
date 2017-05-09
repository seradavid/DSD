library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Adder8Bit is
	port(
		A    : in  STD_LOGIC_VECTOR(7 downto 0);
		B    : in  STD_LOGIC_VECTOR(7 downto 0);
		CIN  : in  STD_LOGIC;
		S    : out STD_LOGIC_VECTOR(7 downto 0);
		COUT : out STD_LOGIC);
end Adder8Bit; 

architecture Add of Adder8Bit is
	component adder
	port(
		A    : in  std_logic;
		B    : in  std_logic;
		CIN  : in  std_logic;
		S    : out std_logic;
		COUT : out std_logic);
	end component;
	for all: adder use entity WORK.adder(add);

signal CARRY : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal MSB   : STD_LOGIC := '0';

begin
	a0: adder port map(A(0), B(0), CIN,      S(0), CARRY(0));	 
	a1: adder port map(A(1), B(1), CARRY(0), S(1), CARRY(1));
	a2: adder port map(A(2), B(2), CARRY(1), S(2), CARRY(2));
	a3: adder port map(A(3), B(3), CARRY(2), S(3), CARRY(3));
	a4: adder port map(A(4), B(4), CARRY(3), S(4), CARRY(4));
	a5: adder port map(A(5), B(5), CARRY(4), S(5), CARRY(5));
	a6: adder port map(A(6), B(6), CARRY(5), S(6), CARRY(6));
	a7: adder port map(A(7), B(7), CARRY(6), MSB,  CARRY(7));
	
	process(CARRY(7), MSB)
	begin
		if ((CARRY(6) xor CARRY(7)) = '1') then -- We have overflow
			COUT <= CARRY(7);
		else												 -- We need to do sign extension
			COUT <= MSB;
		end if;
	end process;
	
	S(7) <= MSB;
	
end Add;

