library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM_MIC_ctrl is
    Generic (   DATA_SIZE : integer range 1 to 16 := 7);
    Port (  clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;

            empty       : in STD_LOGIC;
            full        : in STD_LOGIC;
            read_FIFO   : out STD_LOGIC;
            data_in     : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

            input_valid : in STD_LOGIC;
            input_data  : in STD_LOGIC_VECTOR(31 downto 0);
            output_data : out STD_LOGIC_VECTOR(31 downto 0));
end FSM_MIC_ctrl;

architecture Behavorial of FSM_MIC_ctrl is

    type state is (INIT, STOP_FIFO, WAITING, FIFO_EMPTY, SEND_DATA);
    signal etat : state;

begin

    synchrone : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                etat <= INIT;
            else
                case etat is
                    when INIT       =>  etat <= STOP_FIFO;
                    when STOP_FIFO  =>  if input_valid = '1' and input_data = x"FFFFFFFF" then
                                            etat <= WAITING;
                                        end if;
                    when WAITING    =>  if input_valid = '1' then
                                            if input_data = x"FFFFFFFF" then
                                                if empty = '1' then
                                                    etat <= FIFO_EMPTY;
                                                else
                                                    etat <= SEND_DATA;
                                                end if;
                                            elsif input_data = x"00000000" then
                                                etat <= STOP_FIFO;
                                            end if;
                                        end if;
                    when FIFO_EMPTY => etat <= WAITING;
                    when SEND_DATA  => etat <= WAITING;
                end case;
            end if;
        end if;
    end process synchrone;

    asynchrone : process(etat, data_in)
    begin
        case etat is
            when INIT       =>  read_FIFO <= '0';
                                output_data <= x"00000000";
            when STOP_FIFO  =>  read_FIFO <= '0';
                                output_data <= x"00000000";
            when WAITING    =>  read_FIFO <= '0';
                                output_data <= x"00000000";
            when FIFO_EMPTY =>  read_FIFO <= '0';
                                output_data <= x"00000000";
            when SEND_DATA  =>  read_FIFO <= '0';
                                output_data <= data_in & "1111111111111111111111111";
            when others     =>  read_FIFO <= '0';
                                output_data <= x"00000000";
        end case;
    end process asynchrone;

end Behavorial;
