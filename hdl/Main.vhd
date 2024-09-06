library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Main is
    Port ( clk_i : in STD_LOGIC;
           rst_i : in STD_LOGIC;
           data_t_i : in STD_LOGIC_VECTOR (31 downto 0);
           data_p_i : in STD_LOGIC_VECTOR (31 downto 0);
           data_n_i : in STD_LOGIC_VECTOR (31 downto 0);
           data_m_i : in STD_LOGIC_VECTOR (31 downto 0);
           control_i : in STD_LOGIC_VECTOR (31 downto 0);
           data_o : out STD_LOGIC_VECTOR (31 downto 0);
           status_o : out STD_LOGIC_VECTOR (31 downto 0));
end Main;

architecture Behavioral of Main is
    
    -- Initial signals
    signal VP:      std_logic_vector (31 downto 0);
    signal VN:      std_logic_vector (31 downto 0);
    signal D0:      std_logic_vector (31 downto 0);
    signal HN:      std_logic_vector (31 downto 0);
    signal HP:      std_logic_vector (31 downto 0);
    signal X:       std_logic_vector (31 downto 0);
    signal MASK:    std_logic_vector (31 downto 0) := (others => '0');
    signal diff:    std_logic_vector (31 downto 0);
    signal k:       std_logic_vector (7 downto 0);
    
    type b_array is array (0 to 12) of std_logic_vector (31 downto 0);
    
    signal b:       b_array;
    -- Other signals
    signal m:       std_logic_vector (31 downto 0);
    
    -- Core usage signals
    signal stage:   std_logic_vector (2 downto 0) := "000";
begin
    
    m <= std_logic_vector(TO_UNSIGNED(63,32)) when data_m_i > 63 else data_m_i;
    process(clk_i,rst_i)
    variable unsigned_long: unsigned (31 downto 0) := TO_UNSIGNED(1, 32);
    variable tmp_m: std_logic_vector (31 downto 0);
    begin
        if rising_edge(clk_i) then
            if (rst_i = '0' or control_i = 0) then
                VP <= (others => '0');
                VN <= (others => '0');
                D0 <= (others => '0');
                HN <= (others => '0');
                HP <= (others => '0');
                X <= (others => '0');
                MASK <= (others => '0');
                diff <= (others => '0');
                b <= (others => (others => '0'));
                stage <= (others => '0');
            else
                case stage is
                when "000" =>
                    status_o <= std_logic_vector(TO_UNSIGNED(0,32));
                    if(control_i = 1) then
                        stage <= "001";
                    end if;
                when "001" =>
                    status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                    tmp_m := m;
                    diff <= tmp_m;
                    k <= tmp_m(7 downto 0);   
                    for i in 0 to 1000 loop
                        exit when i = tmp_m;
                        
                        status_o <= std_logic_vector(TO_UNSIGNED(2,32));
                        b(i) <= (b(i) or std_logic_vector(shift_left(unsigned_long,i)));
                    end loop;
                    unsigned_long := shift_left(unsigned_long,TO_INTEGER(unsigned(tmp_m)));
                    VP <= std_logic_vector(shift_left(unsigned_long,TO_INTEGER(unsigned(tmp_m)))) - 1;
                    VN <= (others => '0');
                when others =>
                end case; 
            end if;
        end if;
    end process;
end Behavioral;
