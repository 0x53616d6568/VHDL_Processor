library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_2_1_12 is
    Port (
        d0  : in  STD_LOGIC_VECTOR(11 downto 0);
        d1  : in  STD_LOGIC_VECTOR(11 downto 0);
        sel : in  STD_LOGIC;
        y   : out STD_LOGIC_VECTOR(11 downto 0)
    );
end MUX_2_1_12;

architecture structural of MUX_2_1_12 is
    component MUX_2_1 is
        Port ( d0  : in  STD_LOGIC;
               d1  : in  STD_LOGIC;
               sel : in  STD_LOGIC;
               y   : out STD_LOGIC );
    end component;
begin
    gen_mux: for i in 0 to 11 generate
        mux_bit: MUX_2_1
            port map (d0 => d0(i), d1 => d1(i), sel => sel, y => y(i));
    end generate gen_mux;
end architecture structural;
