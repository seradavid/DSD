library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Calculator is
	port(
		CLK : in  STD_LOGIC;
		DIN : in  STD_LOGIC_VECTOR(3 downto 0);
		BTN : in  STD_LOGIC;
		Q   : out STD_LOGIC_VECTOR(6 downto 0);
		AN0, AN1, AN2, AN3 : out STD_LOGIC);
end Calculator;

architecture Calculate of Calculator is
	component readinput
	port(
		DIN : in  std_logic_vector(3 downto 0);
		CLK : in  std_logic;
		BTN : in  std_logic;
		NR1 : out std_logic_vector(7 downto 0);
		NR2 : out std_logic_vector(7 downto 0);
		OP  : out std_logic_vector(1 downto 0);
		E   : out std_logic);
	end component;
	for all: readinput use entity WORK.readinput(read);

	component adder8bit
	port(
		A    : in  std_logic_vector(7 downto 0);
		B    : in  std_logic_vector(7 downto 0);
		CIN  : in  std_logic;
		S    : out std_logic_vector(7 downto 0);
		COUT : out std_logic);
	end component;
	for all: adder8bit use entity WORK.adder8bit(add);

	component multiplier
	port(
		A   : in  std_logic_vector(7 downto 0);
		B   : in  std_logic_vector(7 downto 0);
		CLK : in  std_logic;
		E   : in  std_logic;
		Q   : out std_logic_vector(15 downto 0));
	end component;
	for all: multiplier use entity WORK.multiplier(multiply);

	component divider
	port(
		X   : in  std_logic_vector(7 downto 0);
		Y   : in  std_logic_vector(7 downto 0);
		CLK : in  std_logic;
		E   : in  std_logic;
		Q   : out std_logic_vector(7 downto 0);
		REMAINDER : out std_logic_vector(7 downto 0));
	end component;
	for all: divider use entity WORK.divider(divide);

	component decoder
	port(
		CLK : in  std_logic;
		A   : in  std_logic_vector(15 downto 0);
		Q   : out std_logic_vector(6 downto 0);
		AN0 : out std_logic;
		AN1 : out std_logic;
		AN2 : out std_logic;
		AN3 : out std_logic);
	end component;
	for all: decoder use entity WORK.decoder(display);
	
signal nr1, nr2, nr2n : STD_LOGIC_VECTOR(7  downto 0) := (others => '0');
signal op             : STD_LOGIC_VECTOR(1  downto 0) := (others => '0');
signal E              : STD_LOGIC := '0';
signal add, sub       : STD_LOGIC_VECTOR(8  downto 0) := (others => '0');
signal div, remainder : STD_LOGIC_VECTOR(7  downto 0) := (others => '0');
signal mul            : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal output         : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin
	read0: readinput  port map(DIN, CLK,    BTN, nr1,             nr2,  op, E);
	add1 : adder8bit  port map(nr1, nr2,    '0', add(7 downto 0), add(8));
	sub2 : adder8bit  port map(nr1, nr2n,   '1', sub(7 downto 0), sub(8));
	mul3 : multiplier port map(nr1, nr2,    CLK, E,               mul);
	div4 : divider    port map(nr1, nr2,    CLK, E,               div,  remainder);
	dpl5 : decoder    port map(CLK, output, Q,   AN0,             AN1,  AN2, AN3);
	
	nr2n <= not nr2;
	
	process(E, add, sub, mul, div, op)
	variable O : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	begin
		if E = '1' then
			case op is
				when "00" =>
					O := std_logic_vector(resize(signed(add), 16));
				when "01" =>
					O := std_logic_vector(resize(signed(sub), 16));
				when "10" =>
					O:= mul;
				when "11" =>
					O := std_logic_vector(resize(signed(div), 16));	
				when others =>
					null;
			end case;
			
			output <= O;
		else
			output <= (others => '0');
		end if;
	end process;
end Calculate;