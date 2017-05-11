library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier is
	port(
		A   : in  STD_LOGIC_VECTOR(7 downto 0);
		B   : in  STD_LOGIC_VECTOR(7 downto 0);
		CLK : in  STD_LOGIC;	
		E   : in  STD_LOGIC;
		Q   : out STD_LOGIC_VECTOR(15 downto 0));
end Multiplier; 

architecture Multiply of Multiplier is
		
signal state        : STD_LOGIC := '0';

begin
	process(CLK)
	variable NA  : STD_LOGIC_VECTOR(7  downto 0) := (others => '0');
	variable NB  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	variable SUM : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	variable sign : STD_LOGIC := '0';
	begin
		if CLK'EVENT and CLK = '1' then	
			case state is
				when '0' =>	-- Wait state
					if A(7) = '0' then 	 -- Initialize variable A 
						NA := A;
					else
						NA := (not A) + 1; -- If the fist number is negative, we take the modulus
						sign := not sign;  -- and change the sign
					end if;
					
					if B(7) = '0' then                 -- Initialize variable B
						NB := "00000000" & B;  
					else
						NB := "00000000" & (not B) + 1; -- If the second number si negative, we take the modulus
						sign := not sign;               -- and change the sign
					end if; 
					
					SUM := (others => '0');
					
					if E = '1' then	       -- If Enable is '1' begin the algorithm
						state <= '1';
					else
						state <= '0';         -- Else remain in Wait state
					end if;	 
				when '1' => -- Compute state
					if NA > "00000000" then	-- If A > 0
						if NA(0) = '1' then	-- If A is an even number, than we add B to the sum
							SUM := SUM + NB;
						end if;
						
						NA(7 downto 0)  := '0' & NA(7 downto 1);  -- Shift A to the right
						NB(15 downto 0) := NB(14 downto 0) & '0'; -- Shift B to the left
					else                    -- If A is 0, the algorithm is done
						if sign = '0' then   -- We update the output
							Q <= SUM;			   
						else                 -- We change the sign based on the first numbers signs
							Q <= (not SUM) + 1;
						end if;			      
						state <= '0';	      -- And go to the Wait state
					end if;
				when others => null;
			end case;
		else
			null;		
		end if;
	end process;
end Multiply;