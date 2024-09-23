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
    signal current_stage: std_logic_vector (2 downto 0);
begin
    
    m <= std_logic_vector(TO_UNSIGNED(63,32)) when data_m_i > 63 else data_m_i;
    process(clk_i,rst_i)
    variable unsigned_long: unsigned (31 downto 0) := TO_UNSIGNED(1, 32);
    variable tmp_data:      std_logic_vector (31 downto 0);
    variable i:             integer := 0;
    variable tmp_X:         std_logic_vector (31 downto 0);
    variable tmp_D0:         std_logic_vector (31 downto 0);
    variable tmp_HN:         std_logic_vector (31 downto 0);
    variable tmp_HP:         std_logic_vector (31 downto 0);
    variable tmp_diff:         std_logic_vector (31 downto 0);
    --variable b:              b_array;
    --variable tmp_VP:         std_logic_vector (31 downto 0);
    --variable tmp_VN:         std_logic_vector (31 downto 0);
    begin
        if rising_edge(clk_i) then
            if (rst_i = '0' or control_i = 0) then
                VP <= (others => '0');
                VN <= (others => '0');
                D0 <= (others => '0');
                HN <= (others => '0');
                HP <= (others => '0');
                k <= (others => '0');
                X <= (others => '0');
                MASK <= (others => '0');
                diff <= (others => '0');
                b <= (others => (others => '0'));
                stage <= (others => '0');
                data_o <= (others => '0');
                i := 0;
            else
                case stage is
                when "000" => -- Wait for start
                    current_stage <= stage;
                    status_o <= std_logic_vector(TO_UNSIGNED(0,32));
                    if(control_i = 1) then
                        stage <= "001";
                    end if;
                when "001" => -- First stage
                    current_stage <= stage;
                    status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                    tmp_data := m;
                    tmp_diff := tmp_data;
                    k <= tmp_data;                       
                    VP <= std_logic_vector(shift_left(unsigned_long,TO_INTEGER(unsigned(tmp_data)))) - 1;
                    VN <= (others => '0');
                    stage <= "010";
                when "010" => -- Wait for p[i]
                    current_stage <= stage;
                    status_o <= std_logic_vector(TO_UNSIGNED(2,32));
                    if(control_i = 2) then -- Next p[i] iteration
                        stage <= "011";
                    elsif (control_i = 3) then -- End p-loop
                        stage <= "100";   
                    end if;
                when "011" => -- p[i] operations
                    current_stage <= stage;
                    status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                    tmp_data := data_p_i;
                    b(TO_INTEGER(unsigned(tmp_data))) <= (b(TO_INTEGER(unsigned(tmp_data))) or std_logic_vector(shift_left(unsigned_long,i)));
                    --b_test <= b;
                    i := i + 1;
                    stage <= "010";
                when "100" => -- After p-loop operations
                    current_stage <= stage;
                    status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                    i := 0;
                    tmp_data := m - 1;
                    MASK <= std_logic_vector(shift_left(unsigned_long,TO_INTEGER(unsigned(tmp_data))));
                    stage <= "101";
                when "101" => -- Wait for t[i]
                    current_stage <= stage;
                    status_o <= std_logic_vector(TO_UNSIGNED(3,32));
                    if (control_i = 4) then --Next t[i] iteration
                        stage <= "110";
                    elsif(control_i = 5) then -- End t-loop, return k value
                        stage <= "111";
                    end if;
                when "110" => -- t[i] operations
                    current_stage <= stage;
                    status_o <= std_logic_vector(TO_UNSIGNED(1,32));
                    tmp_data := data_t_i;
                    tmp_X := b(TO_INTEGER(unsigned(tmp_data))) or VN;
                    tmp_D0 := tmp_X or (VP xor (VP + (tmp_X and VP)));
                    tmp_HN := VP and tmp_D0;
                    tmp_HP := VN or (not(VP or tmp_D0));
                    tmp_X := std_logic_vector(shift_left(unsigned(tmp_HP), 1));
                    VN <= tmp_X and tmp_D0;
                    VP <= (std_logic_vector(shift_left(unsigned(tmp_HN), 1))) or (not(tmp_X or tmp_D0));
                    if (tmp_HP and MASK) > 0 then
                        tmp_diff := tmp_diff + 1;
                    end if;
                    if (tmp_HN and MASK) > 0 then
                        tmp_diff := tmp_diff - 1;
                    end if;
                    if(tmp_diff < k) then
                        k <= tmp_diff;
                    end if;
                    stage <= "101";
                when "111" => -- returning k value
                    current_stage <= stage;
                    data_o <= k;
                    status_o <= std_logic_vector(TO_UNSIGNED(4,32));
                    stage <= "000";
                when others =>
                    stage <= "000";
                end case; 
            end if;
        end if;
    end process;
end Behavioral;
