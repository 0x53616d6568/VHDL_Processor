library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity program_counter is
    port (
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        pc_ld  : in  STD_LOGIC;
        pc_in  : in  STD_LOGIC_VECTOR(11 downto 0);
        pc_out : out STD_LOGIC_VECTOR(11 downto 0)
    );
end entity program_counter;

architecture behavioral of program_counter is
begin
    p_reg : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_out <= (others => '0');
            elsif pc_ld = '1' then
                pc_out <= pc_in;
            end if;
        end if;
    end process p_reg;
end architecture behavioral;
