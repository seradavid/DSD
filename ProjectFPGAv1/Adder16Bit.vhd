library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Adder16Bit is
	port(
		A    : in  STD_LOGIC_VECTOR(15 downto 0);
		B    : in  STD_LOGIC_VECTOR(15 downto 0);
		CIN  : in  STD_LOGIC;
		S    : out STD_LOGIC_VECTOR(15 downto 0);
		COUT : out STD_LOGIC);
end Adder16Bit; 

architecture Add of Adder16Bit is
	component adder8bit
	port(
		A    : in  std_logic_vector(7 downto 0);
		B    : in  std_logic_vector(7 downto 0);
		CIN  : in  std_logic;
		S    : out std_logic_vector(7 downto 0);
		COUT : out std_logic);
	end component;
	for all: adder8bit use entity WORK.adder8bit(add);


signal CARRY : STD_LOGIC := '0';
begin
	a0: adder8bit port map(A(7 downto 0),  B(7 downto 0),  CIN,   S(7 downto 0),  CARRY);	 
	a1: adder8bit port map(A(15 downto 8), B(15 downto 8), CARRY, S(15 downto 8), COUT);
end Add;