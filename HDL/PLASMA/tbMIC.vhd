library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity MIC_ctrl_tb is
end;

architecture bench of MIC_ctrl_tb is

  component MIC_ctrl
      Generic (   DATA_SIZE : integer range 1 to 16 := 7);
      Port (  clk             : in STD_LOGIC;
              reset           : in STD_LOGIC;
              input_valid     : in STD_LOGIC;
              proc_in_data    : in STD_LOGIC_VECTOR(31 downto 0);
              proc_out_data   : out STD_LOGIC_VECTOR(31 downto 0);
              clk_mic         : out STD_LOGIC;
              data_mic        : in STD_LOGIC;
              LR_sel          : out STD_LOGIC);
  end component;

  signal clk: STD_LOGIC;
  signal reset: STD_LOGIC;
  signal input_valid: STD_LOGIC;
  signal proc_in_data: STD_LOGIC_VECTOR(31 downto 0);
  signal proc_out_data: STD_LOGIC_VECTOR(31 downto 0);
  signal clk_mic: STD_LOGIC;
  signal data_mic: STD_LOGIC;
  signal LR_sel: STD_LOGIC;
  
    constant clock_period: time := 20 ns;
    signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: MIC_ctrl generic map ( DATA_SIZE     =>  7)
                   port map ( clk           => clk,
                              reset         => reset,
                              input_valid   => input_valid,
                              proc_in_data  => proc_in_data,
                              proc_out_data => proc_out_data,
                              clk_mic       => clk_mic,
                              data_mic      => data_mic,
                              LR_sel        => LR_sel );

  stimulus: process
  begin
  
    reset <= '1';
    wait for clock_period;
    reset <= '0';
    data_mic <= '1';
    wait for 51.25us;
    input_valid <= '1';
    proc_in_data <= x"FFFFFFFF";
    wait for clock_period;
    proc_in_data <= x"0000FFFF";
    wait for clock_period;
    proc_in_data <= x"FFFFFFFF";
    wait for 2*clock_period;

    stop_the_clock <= true;
    -- Put test bench stimulus code here

    wait;
  end process;
  
  clocking: process
    begin
      while not stop_the_clock loop
        clk <= '0', '1' after clock_period / 2;
        wait for clock_period;
      end loop;
      wait;
    end process;


end;