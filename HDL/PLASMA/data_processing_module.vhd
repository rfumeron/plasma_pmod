library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_processing_module is
	Generic (   DATA_SIZE 		: integer range 1 to 16);
	Port 	(	data_ready_1    : in STD_LOGIC;
				data_ready_2    : in STD_LOGIC;
				data_1          : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
				data_2          : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

				write_FIFO      : out STD_LOGIC;
				data_out        : out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0)
			);
end data_processing_module;

architecture Behavioral of data_processing_module is

begin

	gen_data_out : process( data_ready_1, data_ready_2, data_1, data_2)
	begin
		if data_ready_1 = '1' then
			write_FIFO 	<= '1';
			data_out	<= data_1;
		elsif data_ready_2 = '1' then
			write_FIFO	<= '1';
			data_out	<= data_2;
		else
			write_FIFO	<= '0';
			data_out	<= STD_LOGIC_VECTOR(to_unsigned(0, DATA_SIZE));
		end if;
	end process;

end Behavioral;
