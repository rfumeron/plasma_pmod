------------------------------------------------------------------------------------
----        fifo_module.vhd
----
----        This module initialise a fifo with a certain depth and data size
------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_module is
    Generic (   DATA_SIZE   : integer range 1 to 16;
                DEPTH       : integer range 1 to 1000);
    Port (  clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;

            write_data  : in STD_LOGIC;
            data_in     : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

            read_data   : in STD_LOGIC;
            data_out    : out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

            full        : out STD_LOGIC;
            empty       : out STD_LOGIC);
end FIFO_module;

architecture Behavioral of fifo_module is

type ram is array (0 to DEPTH-1) of STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

signal fifo : ram;
signal sempty, sfull, looped : STD_LOGIC;
signal head, tail : integer range 0 to DEPTH-1;

begin

fifo_operation : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            head <= 0;
            tail <= 0;
            looped <= '0';
            --data_out <= std_logic_vector(to_unsigned(0, DATA_SIZE));
        else
            if write_data = '1' then
                if looped = '0' or head /= tail then
                    fifo(tail) <= data_in;
                    if tail = DEPTH-1 then
                        looped <= '1';
                        tail <= 0;
                    else
                        tail <= tail + 1;
                    end if;
                end if;
            end if;

            if read_data = '1' then
                if looped = '1' or head /= tail then
                    if head = DEPTH-1 then
                        looped <= '0';
                        head <= 0;
                    else
                        head <= head + 1;
                    end if;
                end if;
            end if;

        end if;
    end if;
end process fifo_operation;

asynchrone : process(head, tail, looped)
begin
    if head = tail then
        if looped = '1' then
            sfull <= '1';
            sempty <= '0';
        else
            sfull <= '0';
            sempty <= '1';
        end if;
    else
        sfull <= '0';
        sempty <= '0';
    end if;
end process asynchrone;

    data_out <= fifo(head);

    full <= sfull;
    empty <= sempty;

end Behavioral;
