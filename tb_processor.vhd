library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_processor is
end entity;

architecture sim of tb_processor is
    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '1';
    signal pc_dbg  : STD_LOGIC_VECTOR(11 downto 0);
    signal acc_dbg : STD_LOGIC_VECTOR(15 downto 0);
    signal halted  : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;
    signal cycle_count : integer := 0;
    signal sim_done    : boolean := false;

    function to_hex(v : STD_LOGIC_VECTOR) return string is
        variable result : string(1 to v'length / 4);
        variable nibble : STD_LOGIC_VECTOR(3 downto 0);
        variable idx    : integer;
    begin
        for i in result'range loop
            idx := v'length - i * 4;
            nibble := v(idx + 3 downto idx);
            case nibble is
                when "0000" => result(i) := '0';
                when "0001" => result(i) := '1';
                when "0010" => result(i) := '2';
                when "0011" => result(i) := '3';
                when "0100" => result(i) := '4';
                when "0101" => result(i) := '5';
                when "0110" => result(i) := '6';
                when "0111" => result(i) := '7';
                when "1000" => result(i) := '8';
                when "1001" => result(i) := '9';
                when "1010" => result(i) := 'A';
                when "1011" => result(i) := 'B';
                when "1100" => result(i) := 'C';
                when "1101" => result(i) := 'D';
                when "1110" => result(i) := 'E';
                when "1111" => result(i) := 'F';
                when others => result(i) := 'X';
            end case;
        end loop;
        return result;
    end function;

    function state_name(pc : STD_LOGIC_VECTOR; acc : STD_LOGIC_VECTOR; halted : STD_LOGIC) return string is
    begin
        if halted = '1' then
            return "HALT    ";
        elsif pc = x"000" and acc = x"0000" then
            return "RESET   ";
        else
            return "RUN     ";
        end if;
    end function;
begin

    uut: entity work.processor
        port map (
            clk     => clk,
            rst     => rst,
            pc_dbg  => pc_dbg,
            acc_dbg => acc_dbg,
            halted  => halted
        );

    clk_gen: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    monitor: process(clk)
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;

            if cycle_count = 0 then
                report "=============================================================";
                report "  CYCLE |   STATE   |   PC   |   ACC    | HALTED ";
                report "=============================================================";
            end if;

            report "   " & integer'image(cycle_count) & "    | " &
                   state_name(pc_dbg, acc_dbg, halted) & " |  0x" &
                   to_hex(pc_dbg) & "  | 0x" &
                   to_hex(acc_dbg) & " |   " &
                   STD_LOGIC'image(halted);

            if halted = '1' then
                report "=============================================================";
                report "  PROCESSOR HALTED";
                report "  Final PC  = 0x" & to_hex(pc_dbg) & " (" & integer'image(to_integer(unsigned(pc_dbg))) & ")";
                report "  Final ACC = 0x" & to_hex(acc_dbg) & " (" & integer'image(to_integer(unsigned(acc_dbg))) & ")";
                if acc_dbg = x"000D" and pc_dbg = x"007" then
                    report "  TEST PASSED";
                else
                    report "  TEST FAILED: expected PC=0x007 ACC=0x00D";
                end if;
                report "=============================================================";
                sim_done <= true;
            end if;

            if cycle_count >= 50 then
                report "TIMEOUT: processor did not halt within 50 cycles" severity failure;
                sim_done <= true;
            end if;
        end if;
    end process;

    stim: process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait;
    end process;

end architecture;
