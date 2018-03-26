library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gen_clk_2M5 is
	Port (	clk		: in STD_LOGIC;
			reset	: in STD_LOGIC;
			clk_2M5	: out STD_LOGIC
		);
end gen_clk_2M5;

architecture Behavioral of gen_clk_2M5 is

signal compteur : integer range 0 to 39;
signal maintien : integer range 0 to 19;

begin

	synchrone : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				compteur 	<= 0;
				clk_2M5	 	<= '0';
				maintien 	<= 0;
			elsif compteur = 39 then
				clk_2M5 	<= '1';
				maintien 	<= 19;
				compteur	<= 0;
			elsif maintien /= 0 then
				clk_2M5 	<= '1';
				maintien 	<= maintien - 1;
				compteur    <= compteur + 1;
			else
				clk_2M5 	<= '0';
				maintien 	<= 0;
				compteur	<= compteur + 1;
			end if;
		end if;
	end process;
	
end Behavioral;