library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM_4096x16 is
    Port (
        CLK      : in  STD_LOGIC;
        ADDR     : in  STD_LOGIC_VECTOR(11 downto 0);
        DATA_IN  : in  STD_LOGIC_VECTOR(15 downto 0);
        DATA_OUT : out STD_LOGIC_VECTOR(15 downto 0);
        RnW      : in  STD_LOGIC
    );
end MEM_4096x16;

architecture behavioral of MEM_4096x16 is
    type mem_array is array (0 to 4095) of STD_LOGIC_VECTOR(15 downto 0);
    signal Matrice : mem_array := (
        0      => x"0100",
        1      => x"2101",
        2      => x"6005",
        3      => x"3100",
        4      => x"3100",
        5      => x"2100",
        6      => x"7000",
        256    => x"0005",
        257    => x"0003",
        others => x"0000"
    );
begin
    DATA_OUT <= Matrice(to_integer(unsigned(ADDR)));

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RnW = '0' then
                Matrice(to_integer(unsigned(ADDR))) <= DATA_IN;
            end if;
        end if;
    end process;
end architecture behavioral;
