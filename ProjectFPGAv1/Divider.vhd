library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity Divider is
	port(
		X         : in  STD_LOGIC_VECTOR(7 downto 0);
		Y         : in  STD_LOGIC_VECTOR(7 downto 0);
		CLK       : in  STD_LOGIC;
		E         : in  STD_LOGIC;
		Q         : out STD_LOGIC_VECTOR(7 downto 0);
		REMAINDER : out STD_LOGIC_VECTOR(7 downto 0));
end Divider;  

architecture Divide of Divider is
	component adder8bit
	port(
		A    : in  std_logic_vector(7 downto 0);
		B    : in  std_logic_vector(7 downto 0);
		CIN  : in  std_logic;
		S    : out std_logic_vector(7 downto 0);
		COUT : out std_logic);
	end component;
	for all: adder8bit use entity WORK.adder8bit(add);

type st is (S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13); 
signal state : st := S1;

signal A, B, C, NC : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal add, sub    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal cout        : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');	

begin
	add0: adder8bit port map(A, C,  '0', add, cout(0)); -- Calculate the sum between A and C
	sub0: adder8bit port map(A, NC, '1', sub, cout(1)); -- Calculate the difference bewteen A and C
	
	process(CLK)
	variable I : integer range 0 to 7 := 0;
	variable sign : STD_LOGIC := '0';
	begin
		if CLK'EVENT and CLK = '1' then
			case state is
				when S1 => 
					if E = '1' then
						state <= S2;
					else
						state <= S1;
					end if;
				when S2 =>
					A <= (others => '0');
					
					if X(7) = '0' then
						B <= X;
					else						
						B <= (not X) + 1; -- If the first number is negative, we take the modulus
						sign := not sign; -- and change the sign
					end if;
					
					if Y(7) = '0' then
						C <= Y;
					else
						C <= (not Y) + 1; -- If the second number is negative, we take the modulus
						sign := not sign; -- and change the sign
					end if;

					I := 0;
					state <= S3;
				when S3 =>
					A(7 downto 0) <= A(6 downto 0) & B(7);
					B(7 downto 0) <= B(6 downto 0) & '0'; 
					state <= S4;
				when S4 =>
					A <= sub;
					state <= S5;
				when S5 =>
					if A(7) = '1' then
						state <= S6;
					else
						state <= S8;
					end if;
				when S6 =>
					A(7 downto 0) <= A(6 downto 0) & B(7);
					B(7 downto 0) <= B(6 downto 0) & '0';
					state <= S7;
				when S7	=>
					A <= add;
					I := I + 1;	
					state <= S11;
				when S8	=>
					B(0) <= '1';
					state <= S9;
				when S9 =>
					A(7 downto 0) <= A(6 downto 0) & B(7);
					B(7 downto 0) <= B(6 downto 0) & '0';
					state <= S10;
				when S10	=>
					A <= sub;
					I := I + 1;	
					state <= S11;  
				when S11 =>
					if I = 7 then
						state <= S12;
					else
						state <= S5;
					end if;
				when S12 =>
					if A(7) = '1' then
						A <= add;
					else
						B(0) <= '1'; 
					end if;
					state <= S13;
				when S13 =>
					 if sign = '0' then -- Change the sign of the output based on the initial numbers
						Q <= B;
					else
						Q <= (not B) + 1; 
					end if;
					
					REMAINDER <= A;
					state <= S1;
				when others => null;
			end case;
		else
			null;
		end if;
	end process;
	
	NC <= not C;
	
end Divide;