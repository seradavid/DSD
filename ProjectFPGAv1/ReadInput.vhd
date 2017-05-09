library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ReadInput is
	port(
		DIN : in  STD_LOGIC_VECTOR(3 downto 0); -- Input data
		CLK : in  STD_LOGIC;							 -- Clock
		BTN : in  STD_LOGIC;							 -- Button
		NR1 : out STD_LOGIC_VECTOR(7 downto 0); -- First number
		NR2 : out STD_LOGIC_VECTOR(7 downto 0); -- Second number
		OP  : out STD_LOGIC_VECTOR(1 downto 0); -- Operation to be done
		E   : out STD_LOGIC);						 -- Signals the other componets to compute
end ReadInput;

architecture Read of ReadInput is
	component debouncer
	generic(
		counter_size : INTEGER := 19);
	port(
		CLK    : in  std_logic;
		BUTTON : in  std_logic;
		Q      : out std_logic);
	end component;
	for all: debouncer use entity WORK.debouncer(debounce); 
	
signal newCLK  : STD_LOGIC := '0'; -- Debounced button
attribute keep : string;

signal step : std_logic_vector(10 downto 0) := ('1', others => '0');

begin
	db: debouncer port map(clk, btn, newCLK); -- Debounce the button
	
	process(newCLK)
	variable na, nb, nc : integer range 0    to 9   := 0;
	variable n1, n2     : integer range -128 to 127 := 0;
	variable I          : integer range 0    to 9   := 0;
	variable SIGN       : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	variable A, B, C    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	variable operation  : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	attribute keep of A : variable is "true";
	begin
		if newCLK'EVENT and newCLK = '1' then
			operation := SIGN;   
			SIGN := A(1) & A(0); 
			A := B;					
			B := C;					
			C := DIN;				
			I := I + 1;				
			
			if I = 4 then                     -- We read the first number
				na := to_integer(unsigned(A)); -- First digit of the first number
				nb := to_integer(unsigned(B)); -- Second digit of the first number
				nc := to_integer(unsigned(C)); -- Third digit of the first number
				n1 := na * 100 + nb * 10 + nc; -- Construct the first number
				
				if SIGN(0) = '0' then          -- Sign is '+'
					NR1 <= std_logic_vector(to_signed(n1, 8));
				else  				             -- Sign is '-'
					NR1 <= std_logic_vector(to_signed(-n1, 8));
				end if;
			elsif I = 9 then                  -- We read the second number
				na := to_integer(unsigned(A)); -- First digit of the second number
				nb := to_integer(unsigned(B)); -- Second digit of the second number
				nc := to_integer(unsigned(C)); -- Third digit of the second number
				n2 := na * 100 + nb * 10 + nc;
				
				if SIGN(0) = '0' then          -- Sign is '+'
					NR2 <= std_logic_vector(to_signed(n2, 8));
				else                           -- Sign is '-'
					NR2 <= std_logic_vector(to_signed(-n2, 8));	
				end if;
				
				OP <= operation; -- Save the operation
				E <= '1';        -- Tell other compoenets to process data
				I := 0;			  -- Reset the counter
			else
				E <= '0';
			end if;	
		else
			null;
		end if;
	end process;
end Read;
