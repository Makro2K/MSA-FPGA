-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 11.9.2024 08:43:57 UTC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_Main is
end tb_Main;

architecture tb of tb_Main is

    component Main
        port (clk_i     : in std_logic;
              rst_i     : in std_logic;
              data_t_i  : in std_logic_vector (31 downto 0);
              data_p_i  : in std_logic_vector (31 downto 0);
              data_n_i  : in std_logic_vector (31 downto 0);
              data_m_i  : in std_logic_vector (31 downto 0);
              control_i : in std_logic_vector (31 downto 0);
              data_o    : out std_logic_vector (31 downto 0);
              status_o  : out std_logic_vector (31 downto 0));
    end component;

    signal clk_i     : std_logic;
    signal rst_i     : std_logic;
    signal data_t_i  : std_logic_vector (31 downto 0);
    signal data_p_i  : std_logic_vector (31 downto 0);
    signal data_n_i  : std_logic_vector (31 downto 0);
    signal data_m_i  : std_logic_vector (31 downto 0);
    signal control_i : std_logic_vector (31 downto 0);
    signal data_o    : std_logic_vector (31 downto 0);
    signal status_o  : std_logic_vector (31 downto 0);

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : Main
    port map (clk_i     => clk_i,
              rst_i     => rst_i,
              data_t_i  => data_t_i,
              data_p_i  => data_p_i,
              data_n_i  => data_n_i,
              data_m_i  => data_m_i,
              control_i => control_i,
              data_o    => data_o,
              status_o  => status_o);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2;

    -- EDIT: Check that clk_i is really your main clock signal
    clk_i <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        data_t_i <= (others => '0');
        data_p_i <= (others => '0');
        data_n_i <= (others => '0');
        data_m_i <= (others => '0');
        control_i <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rst_i is really your reset signal
        rst_i <= '0';
        wait for 100 ns;
        rst_i <= '1';
        wait for 100 ns;

        -- EDIT Add stimuli here
       -- wait for 100 * TbPeriod;
        control_i <= (others => '0');
        wait for 100 ns;
        data_m_i <= std_logic_vector(TO_UNSIGNED(1,32));
        control_i <= std_logic_vector(TO_UNSIGNED(1,32));
        
        wait for 100 ns;
        
        data_p_i <= std_logic_vector(TO_UNSIGNED(2,32));
        control_i <= std_logic_vector(TO_UNSIGNED(2,32));
        
        wait for 40 ns;
        
        control_i <= std_logic_vector(TO_UNSIGNED(3,32));
        
        wait for 40 ns;
        
        data_t_i <= std_logic_vector(TO_UNSIGNED(3,32));
        control_i <= std_logic_vector(TO_UNSIGNED(4,32));
        wait for 40 ns;
        
        for x in 0 to 5 loop
            data_t_i <= std_logic_vector(TO_UNSIGNED(0,32));
            control_i <= std_logic_vector(TO_UNSIGNED(4,32));
            wait for 40 ns;
        end loop;
        
        control_i <= std_logic_vector(TO_UNSIGNED(5,32));
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_Main of tb_Main is
    for tb
    end for;
end cfg_tb_Main;
