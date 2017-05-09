library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity Decoder is
    port(
        CLK : in  STD_LOGIC;
        A   : in  STD_LOGIC_VECTOR(15 downto 0);
        Q   : out STD_LOGIC_VECTOR(6 downto 0);
        AN0, AN1, AN2, AN3 : out  STD_LOGIC);
end Decoder;
 
architecture Display of Decoder is 
  
type disp is array(0 to 9) of STD_LOGIC_VECTOR(6 downto 0);
constant code : disp := ("0000001","1001111","0010010","0000110","1001100","0100100","0100000","0001111","0000000","0000100");

signal na    : std_logic_vector(15 downto 0) := (others => '0');
signal sign  : std_logic := '0';
signal state : std_logic_vector(1  downto 0) := "00";  -- The states indicates which anode(display) to use
signal I     : integer range 0 to 16384 := 0;          -- The number to be displayed
signal n1, n2, n3, n4, n5 : integer range 0 to 9 := 0; -- The five digits of the number
constant limit_50 : STD_LOGIC_VECTOR(16 downto 0) := "11000011010100000"; -- 500.000 in binary, used to reduce the frequency
signal counter_50 : STD_LOGIC_VECTOR(16 downto 0) := (others => '0');     -- Counter, used to reduce the frequency
signal newCLK  : STD_LOGIC := '0';                                        -- New clock with a frequecy of 500 Hz
constant limit_1 : STD_LOGIC_VECTOR(7 downto 0) := "11111010";            -- 250 in binary, used to reduce the frequency
signal counter_1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');       -- Counter, used to reduce the frequency
signal z : STD_LOGIC := '0';                                              -- New clock with a frequency of 1 Hz

begin
    process(A)
    begin
        if A(15) = '1' then   -- If A is negative, we take the modulus
            na <= (not A) + 1;
            sign <= '0';
        else
            na <= A;
            sign <= '1';
        end if;
    end process;
   
    I  <= to_integer(unsigned(na)); -- Convert the number to integer
	 n1 <= I rem 10;						-- Calculate the units digit
	 n2 <= (I / 10) rem 10;				-- Calculate the tens digit
	 n3 <= (I / 100) rem 10;			-- Calculate the hundreds digit
	 n4 <= (I / 1000) rem 10;        -- Calculate the thousands digit
	 n5 <=  I / 10000;               -- Calculate the first digit
   
	 process(CLK) -- Reduce the frequency of the clock to 500 Hz
	 begin
		if CLK'EVENT and CLK = '1' then
			counter_50 <= counter_50 + 1;
			if counter_50 > limit_50 then
				newCLK <= not newCLK;
				counter_50 <= (others => '0');
			else
				null;
			end if;
		else
			null;
		end if;
	 end process;
	 
	 process(newCLK) -- Reduce the frequency to 1 Hz
	 begin
		if newCLK'EVENT and newCLK = '1' then
			counter_1 <= counter_1 + 1;
			if counter_1 > limit_1 then
				z <= not z;
				counter_1 <= (others => '0');
			else
				null;
			end if;
		else
			null;
		end if;
	end process;
	
	 process(newCLK)
    begin
        if newCLK'EVENT and newCLK = '1' then
            if state = "00" then    -- Update the first display
					AN0   <= '0';
               AN1   <= '1';
               AN2   <= '1';
               AN3   <= '1';
					if z = '1' and (n4 >= 0 or n5 >= 0) then
						Q <= code(n4);
					else
						Q <= code(n1);
					end if;
               state <= "01";
            elsif state = "01" then -- Update the second display
               AN0   <= '1';
               AN1   <= '0';
               AN2   <= '1';
               AN3   <= '1';
               if z = '1' and (n4 >= 0 or n5 >= 0) then
						Q <= code(n5);
					else
						Q <= code(n2);
					end if;
               state <= "10";
            elsif state = "10" then -- Update the third display
               AN0   <= '1';
               AN1   <= '1';
               AN2   <= '0';
               AN3   <= '1';
               if z = '1' and (n4 >= 0 or n5 >= 0) then
						Q <= "1111111";
					else
						Q <= code(n3);
					end if;
               state <= "11";
            elsif state = "11" then -- Update the fourth display
               AN0   <= '1';
               AN1   <= '1';
               AN2   <= '1';
               AN3   <= '0';
					Q     <= "111111" & sign;
               state <= "00";
            else
					null;
            end if;
        else
            null;
        end if;
    end process;
end Display;