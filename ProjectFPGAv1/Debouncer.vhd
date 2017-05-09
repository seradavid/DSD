LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

entity Debouncer is
  generic(
    counter_size : integer := 20); --counter size
  port(
    CLK    : in  STD_LOGIC;  --input clock
    BUTTON : in  STD_LOGIC;  --input signal to be debounced
    Q      : out STD_LOGIC); --debounced signal
end Debouncer;

architecture Debounce of Debouncer is
  signal flipflops   : STD_LOGIC_VECTOR(1 downto 0); --input flip flops
  signal counter_set : STD_LOGIC;                    --sync reset to zero
  signal counter     : STD_LOGIC_VECTOR(counter_size downto 0) := (others => '0'); --counter output
  
begin
  counter_set <= flipflops(0) xor flipflops(1);   --determine when to start/reset counter
  
	process(clk)
	begin
		if clk'EVENT and clk = '1' then
			flipflops(0) <= button;
			flipflops(1) <= flipflops(0);
			
			if counter_set = '1' then                  --reset counter because input is changing
				counter <= (others => '0');
			elsif counter(counter_size) = '0' then     --stable input time is not yet met
				counter <= counter + 1;
			else                                       --stable input time is met
				Q <= flipflops(1);
			end if;
		else
			null;		
		end if;
	end process;
end Debounce;