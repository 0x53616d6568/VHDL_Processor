library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_16bit is
    Port (
        A     : in  STD_LOGIC_VECTOR(15 downto 0);
        B     : in  STD_LOGIC_VECTOR(15 downto 0);
        alufs : in  STD_LOGIC_VECTOR(3 downto 0);
        S     : out STD_LOGIC_VECTOR(15 downto 0)
    );
end ALU_16bit;

architecture behavioral of ALU_16bit is
begin
    process(A, B, alufs)
    begin
        case alufs is
            when "0000" =>
                S <= B;
            when "0001" =>
                S <= STD_LOGIC_VECTOR(UNSIGNED(A) - UNSIGNED(B));
            when "0010" =>
                S <= STD_LOGIC_VECTOR(UNSIGNED(A) + UNSIGNED(B));
            when "0011" =>
                S <= STD_LOGIC_VECTOR(UNSIGNED(B) + to_unsigned(1, 16));
            when others =>
                S <= (others => '0');
        end case;
    end process;
end architecture behavioral;
