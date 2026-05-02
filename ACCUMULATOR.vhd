library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ACCUMULATOR is
    port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        data_in  : in  STD_LOGIC_VECTOR(15 downto 0);
        data_out : out STD_LOGIC_VECTOR(15 downto 0);
        bus_out  : out STD_LOGIC_VECTOR(15 downto 0);
        acc_ld   : in  STD_LOGIC;
        acc_oe   : in  STD_LOGIC;
        acc_z    : out STD_LOGIC;
        acc_15   : out STD_LOGIC
    );
end entity ACCUMULATOR;

architecture behavioral of ACCUMULATOR is
    signal reg : STD_LOGIC_VECTOR(15 downto 0);
begin
    p_reg : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg <= (others => '0');
            elsif acc_ld = '1' then
                reg <= data_in;
            end if;
        end if;
    end process p_reg;

    data_out <= reg;
    bus_out  <= reg;
    acc_15   <= reg(15);
    acc_z    <= '1' when reg = x"0000" else '0';
end architecture behavioral;
