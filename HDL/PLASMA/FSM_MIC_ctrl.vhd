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

    type state is (INIT, STOP_FIFO, WAITING_1, FIFO_EMPTY, SEND_DATA);
    signal sdata_in : STD_LOGIC_VECTOR(6 downto 0);
    signal sSTATE : STD_LOGIC_VECTOR(2 downto 0);
    signal sHEAD : STD_LOGIC_VECTOR(7 downto 0);
    signal sBODY : STD_LOGIC_VECTOR(20 downto 0);
    signal etat : state;

begin

    -- data_process : process(data_in)
    -- begin
    --     for i in 0 to DATA_SIZE-1 loop
    --         sdata_in(i) <= data_in(DATA_SIZE-1-i);
    --     end loop;
    -- end process data_process;

    synchrone : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                etat <= INIT;
            else
                case etat is
                    when INIT       =>  etat <= STOP_FIFO;
                    when STOP_FIFO  =>  if input_valid = '1' and input_data = x"FFFFFFFF" then
                                            etat <= WAITING_1;
                                        end if;
--                    when WAITING_2  =>  if input_valid = '1' and input_data = x"0000FFFF" then
--                                            etat <= WAITING_1;
--                                        end if;
                    when WAITING_1    =>  if input_valid = '1' then
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
                    when FIFO_EMPTY => etat <= WAITING_1;
                    when SEND_DATA  => etat <= WAITING_1;
                end case;
            end if;
        end if;
    end process synchrone;

    asynchrone : process(etat, data_in)
    begin
        case etat is
            when INIT       =>  read_FIFO <= '0';
                                --output_data <= x"00000000";
                                sHEAD <= "00000000";
                                sBODY <= "000000000000000000000";
                                sSTATE <= "000";
            when STOP_FIFO  =>  read_FIFO <= '0';
                                sSTATE <= "000";
            when WAITING_1  =>  read_FIFO <= '0';
                                sSTATE <= "000";
--            when WAITING_2  =>  read_FIFO <= '0';
--                                sSTATE <= "011";
            when FIFO_EMPTY =>  read_FIFO <= '0';
                                --output_data <= x"80000000";
                                sHEAD <= "00000000";
                                sBODY <= "000000000000000000000";
                                sSTATE <= "000";
            when SEND_DATA  =>  read_FIFO <= '1';
                                --output_data <= "0" & "1000000" & "111111111111111111111111";
                                --sHEAD <= "01000000";
                                sHEAD <= "0" & data_in;
                                sBODY <= "111111111111111111111";
                                sSTATE <= "111";
            when others     =>  read_FIFO <= '0';
                                --output_data <= x"00000000";
                                sHEAD <= "00000000";
                                sBODY <= "000000000000000000000";
                                sSTATE <= "000";
        end case;
    end process asynchrone;

    output_data <= sHEAD & sBODY & sSTATE;

end Behavorial;
