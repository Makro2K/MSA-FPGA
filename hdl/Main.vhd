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
    signal k:       std_logic_vector (31 downto 0);
    
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
    variable tmp_data:      std_logic_vector (31 downto 0);
    variable i:             integer := 0;
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
                data_o <= (others => '0');
            else
                case stage is
                when "000" =>
                    status_o <= std_logic_vector(TO_UNSIGNED(0,32));
                    if(control_i = 1) then
                        stage <= "001";
                    end if;
                when "001" =>
                    status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                    tmp_data := m;
                    diff <= tmp_data;
                    k <= tmp_data;                       
                    VP <= std_logic_vector(shift_left(unsigned_long,TO_INTEGER(unsigned(tmp_data)))) - 1;
                    VN <= (others => '0');
                    stage <= "010";
                when "010" =>
                    status_o <= std_logic_vector(TO_UNSIGNED(2,32));
                    if(control_i = 2) then
                        status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                        tmp_data := data_p_i;
                        b(TO_INTEGER(unsigned(tmp_data))) <= (b(TO_INTEGER(unsigned(tmp_data))) or std_logic_vector(shift_left(unsigned_long,i)));
                        i := i + 1;
                    elsif (control_i = 3) then
                        status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                        stage <= "011";
                        i := 0;
                        tmp_data := tmp_data - 1;
                        MASK <= std_logic_vector(shift_left(unsigned_long,TO_INTEGER(unsigned(tmp_data))));
                    end if;
                when "011" =>
                    status_o <= std_logic_vector(TO_UNSIGNED(3,32));
                    if (control_i = 4) then
                        status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                        tmp_data := data_t_i;
                        X <= b(TO_INTEGER(unsigned(tmp_data))) or VN;
                        D0 <= X or (VP xor (VP + (X and VP)));
                        HN <= VP and D0;
                        HP <= VN or (not(VP or D0));
                        X <= std_logic_vector(shift_left(unsigned(HP), 1));
                        VN <= X and D0;
                        VP <= (std_logic_vector(shift_left(unsigned(HN), 1))) or (not(X or D0));
                        if (HP and MASK) = 1 then
                            diff <= diff + 1;
                        end if;
                        if (HN and MASK) = 1 then
                            diff <= diff - 1;
                        end if;
                        if(diff < k) then
                            k <= diff;
                        end if;
                        data_o <= k;
                        status_o <= std_logic_vector(TO_UNSIGNED(3,32));
                    end if; 
                when others =>
                end case; 
            end if;
        end if;
    end process;
end Behavioral;
