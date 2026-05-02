library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_2_1 is
    Port (
        d0  : in  STD_LOGIC;
        d1  : in  STD_LOGIC;
        sel : in  STD_LOGIC;
        y   : out STD_LOGIC
    );
end MUX_2_1;

architecture behavioral of MUX_2_1 is
begin
    process(sel, d0, d1)
    begin
        if sel = '0' then
            y <= d0;
        else
            y <= d1;
        end if;
    end process;
end architecture behavioral;
