library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIC_ctrl is
    Generic (   DATA_SIZE : integer range 1 to 16 := 7);
    Port (  clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            input_valid     : in STD_LOGIC;
            proc_in_data    : in STD_LOGIC_VECTOR(31 downto 0);
            proc_out_data   : out STD_LOGIC_VECTOR(31 downto 0);

            clk_mic         : out STD_LOGIC;
            data_mic        : in STD_LOGIC;
            LR_sel          : out STD_LOGIC);
end MIC_ctrl;

architecture Behavorial of MIC_ctrl is

    component gen_clk_2M5 is
        Port (  clk     : in STD_LOGIC;
                reset   : in STD_LOGIC;
                clk_2M5 : out STD_LOGIC);
    end component;

    component counter_module is
        Generic (   DATA_SIZE : integer range 1 to 16 := 7;
                    INIT_VAL  : integer range 0 to 1000000 := 0
                );
        Port (  clk         : in STD_LOGIC;
                reset       : in STD_LOGIC;
                data_mic    : in STD_LOGIC;
                data_ready  : out STD_LOGIC;
                data_out    : out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0)
                );
    end component;

    component data_processing_module is
        Generic (   DATA_SIZE : integer range 1 to 16);
        Port (  data_ready_1    : in STD_LOGIC;
                data_ready_2    : in STD_LOGIC;
                data_1          : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
                data_2          : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

                write_FIFO      : out STD_LOGIC;
                data_out        : out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0));
    end component;

    component FIFO_module is
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
    end component;

    component FSM_MIC_ctrl is
        Generic (   DATA_SIZE : integer range 1 to 16);
        Port (  clk         : in STD_LOGIC;
                reset       : in STD_LOGIC;

                empty       : in STD_LOGIC;
                full        : in STD_LOGIC;
                read_FIFO   : out STD_LOGIC;
                data_in     : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

                input_valid : in STD_LOGIC;
                input_data  : in STD_LOGIC_VECTOR(31 downto 0);
                output_data : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

----------------------- Signals -------------------------------

    signal  clk_2M5, data_ready_1, data_ready_2, full, empty,
            write_FIFO, read_FIFO : STD_LOGIC;
    signal  data_cmp_1, data_cmp_2,
            data_FIFO_in, data_FIFO_out : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);

begin

    iclk_2M5 : gen_clk_2M5
        Port map (
            clk     => clk,
            reset   => reset,
            clk_2M5 => clk_2M5
        );

    counter1 : counter_module
        Generic map (
            DATA_SIZE   => DATA_SIZE,
            INIT_VAL    => 0
        )
        Port map (
            clk         => clk_2M5,
            reset       => reset,
            data_mic    => data_mic,
            data_ready  => data_ready_1,
            data_out    => data_cmp_1
        );

    counter2 : counter_module
        Generic map (
            DATA_SIZE   => DATA_SIZE,
            INIT_VAL    => 64
        )
        Port map (
            clk         => clk_2M5,
            reset       => reset,
            data_mic    => data_mic,
            data_ready  => data_ready_2,
            data_out    => data_cmp_2
        );

    data_processing : data_processing_module
        Generic map (
            DATA_SIZE   => DATA_SIZE
        )
        Port map (
            data_ready_1    => data_ready_1,
            data_ready_2    => data_ready_2,
            data_1          => data_cmp_1,
            data_2          => data_cmp_2,

            write_FIFO      => write_FIFO,
            data_out        => data_FIFO_in
        );

    FIFO : FIFO_module
        Generic map (
            DATA_SIZE   => DATA_SIZE,
            DEPTH       => 64
        )
        Port map (
            clk         => clk,
            reset       => reset,

            write_data  => write_FIFO,
            data_in     => data_FIFO_in,

            read_data   => read_FIFO,
            data_out    => data_FIFO_out,

            full        => full,
            empty       => empty
        );

    FSM : FSM_MIC_ctrl
        Generic map (
            DATA_SIZE   => DATA_SIZE
        )
        Port map (
            clk         => clk,
            reset       => reset,

            empty       => empty,
            full        => full,
            read_FIFO   => read_FIFO,
            data_in     => data_FIFO_out,

            input_valid => input_valid,
            input_data  => proc_in_data,
            output_data => proc_out_data
        );

    clk_mic <= clk_2M5;
    LR_sel <= '0';

end Behavorial;
