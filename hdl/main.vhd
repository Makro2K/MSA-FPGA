library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;

entity Main is
    Port ( clk_i :      in STD_LOGIC;
           rst_i :      in STD_LOGIC;
           data_1_i :   in STD_LOGIC_VECTOR (31 downto 0);
           data_2_i :   in STD_LOGIC_VECTOR (31 downto 0);
           control_i :  in STD_LOGIC_VECTOR (31 downto 0);
           data_o :     out STD_LOGIC_VECTOR (31 downto 0);
           status_o :   out STD_LOGIC_VECTOR (31 downto 0));
end Main;

architecture Behavioral of Main is

    -- Initial signals from input registers
    signal n:       std_logic_vector (31 downto 0);
    signal m:       std_logic_vector (31 downto 0);
    
    -- Other initial signals
    signal w:       std_logic_vector (31 downto 0) := std_logic_vector(TO_UNSIGNED(64, 32));
    signal b_max:   std_logic_vector (31 downto 0);
    signal maxd:    std_logic_vector (31 downto 0);
    signal k:       std_logic_vector (31 downto 0);
    signal w2:      std_logic_vector (31 downto 0);
    signal high_bit:std_logic_vector (63 downto 0);
    signal one:     std_logic_vector (63 downto 0) := std_logic_vector(TO_UNSIGNED(1, 64));
    
    -- System signals
    signal stage:   std_logic_vector (2 downto 0);
    signal div_ceil:std_logic_vector (31 downto 0);

    function modulo (a, b: std_logic_vector) return std_logic_vector is
    begin 
        
    end function;

begin
    -- Set start values to signals
    --m <= std_logic_vector(TO_UNSIGNED(1024, 32)) when m > 
    --div_ceil <= ( others => '0') when ((m mod w) = 0) else std_logic_vector(TO_UNSIGNED(1, 32));
    --b_max <= std_logic_vector(TO_UNSIGNED(1, 32)) when m = 0 else
end Behavioral;

