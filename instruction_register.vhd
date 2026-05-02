library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_register is
    port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        ir_ld    : in  STD_LOGIC;
        data_bus : in  STD_LOGIC_VECTOR(15 downto 0);
        opcode   : out STD_LOGIC_VECTOR(3 downto 0);
        operand  : out STD_LOGIC_VECTOR(11 downto 0)
    );
end entity instruction_register;

architecture behavioral of instruction_register is
    signal reg : STD_LOGIC_VECTOR(15 downto 0);
begin
    p_reg : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg <= (others => '0');
            elsif ir_ld = '1' then
                reg <= data_bus;
            end if;
        end if;
    end process p_reg;

    opcode  <= reg(15 downto 12);
    operand <= reg(11 downto 0);
end architecture behavioral;
