library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_module is
    Generic (   DATA_SIZE : integer range 1 to 16 := 7;
                INIT_VAL  : integer range 0 to 1000000 := 0
            );
    Port (  clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            data_mic    : in STD_LOGIC;
            data_ready  : out STD_LOGIC;
            data_out    : out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0)
            );
end counter_module;

architecture Behavorial of counter_module is

    signal counter  : integer range 0 to 2**DATA_SIZE-1;
    signal value    : integer range 0 to 2**DATA_SIZE-1;

begin

synchrone : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            counter <= INIT_VAL;
            value <= 0;
            data_ready <= '0';
        elsif counter = 2**DATA_SIZE-1 then
            data_ready <= '1';
            counter <= 0;
            if data_mic = '1' then
                value <= value + 1;
            end if;
        elsif counter = 0 then
            data_ready <= '0';
            counter <= counter + 1;
            if data_mic = '1' then
                value <= 1;
            else
                value <= 0;
            end if;
        else
            data_ready <= '0';
            counter <= counter + 1;
            if data_mic = '1' then
                value <= value + 1;
            end if;
        end if;
    end if;
end process synchrone;

data_out <= STD_LOGIC_VECTOR(to_unsigned(value, DATA_SIZE));

end Behavorial;
