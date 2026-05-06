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
		0      => b"0000000100000000",
        1      => b"0010000100000001",
        2      => b"0110000000000101",
        3      => b"0011000100000000",
        4      => b"0011000100000000",
        5      => b"0010000100000000",
        6      => b"0111000000000000",
        256    => b"0000000000000101",
        257    => b"0000000000000011",
        others => b"0000000000000000"    
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
