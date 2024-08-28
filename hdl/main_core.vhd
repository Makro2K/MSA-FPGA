library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;


entity main_core is
    generic (
		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
    Port ( data_i:      in  STD_LOGIC_VECTOR    (C_S_AXI_ADDR_WIDTH-1 downto 0);
           control_i:   in  STD_LOGIC_VECTOR    (C_S_AXI_ADDR_WIDTH-1 downto 0);
           data_o:      out STD_LOGIC_VECTOR    (C_S_AXI_ADDR_WIDTH-1 downto 0);
           clk_i:       in  std_logic;
           rst_i:       in  std_logic);
end main_core;

architecture Behavioral of main_core is
    signal xmove:   std_logic_vector (7 downto 0);
    signal ymove:   std_logic_vector (7 downto 0);
    signal bestx:   integer;
    signal besty:   integer;
begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if(rst_i = '0') then
            
            else
                
            end if;
        end if; 
    end process;
end Behavioral;
