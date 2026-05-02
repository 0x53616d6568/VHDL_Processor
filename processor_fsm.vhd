library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processor_fsm is
    port (
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        opcode : in  STD_LOGIC_VECTOR(3 downto 0);
        accZ   : in  STD_LOGIC;
        acc15  : in  STD_LOGIC;
        selA   : out STD_LOGIC;
        selB   : out STD_LOGIC;
        alufs  : out STD_LOGIC_VECTOR(3 downto 0);
        RmW    : out STD_LOGIC;
        ir_ld  : out STD_LOGIC;
        pc_ld  : out STD_LOGIC;
        acc_ld : out STD_LOGIC;
        acc_oe : out STD_LOGIC;
        halted : out STD_LOGIC
    );
end entity processor_fsm;

architecture behavioral of processor_fsm is
    type t_state is (
        RESET_ST, FETCH, INC_PC,
        EXEC_LDA, EXEC_STO, EXEC_ADD, EXEC_SUB,
        EXEC_JMP, EXEC_JGE, EXEC_JNE,
        HALT
    );
    signal current_state : t_state;
    signal next_state    : t_state;
begin

    p_state_reg : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= RESET_ST;
            else
                current_state <= next_state;
            end if;
        end if;
    end process p_state_reg;

    p_next_state : process(current_state, opcode, accZ, acc15)
    begin
        next_state <= current_state;
        case current_state is
            when RESET_ST => next_state <= FETCH;
            when FETCH    => next_state <= INC_PC;
            when INC_PC   =>
                case opcode is
                    when "0000" => next_state <= EXEC_LDA;
                    when "0001" => next_state <= EXEC_STO;
                    when "0010" => next_state <= EXEC_ADD;
                    when "0011" => next_state <= EXEC_SUB;
                    when "0100" => next_state <= EXEC_JMP;
                    when "0101" => next_state <= EXEC_JGE;
                    when "0110" => next_state <= EXEC_JNE;
                    when "0111" => next_state <= HALT;
                    when others => next_state <= FETCH;
                end case;
            when EXEC_LDA | EXEC_ADD | EXEC_SUB | EXEC_STO | EXEC_JMP | EXEC_JGE | EXEC_JNE => next_state <= FETCH;
            when HALT => next_state <= HALT;
            when others => next_state <= FETCH;
        end case;
    end process p_next_state;

    p_outputs : process(current_state, acc15, accZ)
    begin
        selA   <= '0';
        selB   <= '0';
        alufs  <= "0000";
        RmW    <= '1';
        ir_ld  <= '0';
        pc_ld  <= '0';
        acc_ld <= '0';
        acc_oe <= '0';

        case current_state is
            when RESET_ST  => RmW <= '1';
            when FETCH     => selA <= '0'; RmW <= '1'; ir_ld <= '1';
            when INC_PC    => selA <= '0'; selB <= '0'; alufs <= "0011"; pc_ld <= '1'; RmW <= '1';
            when EXEC_LDA  => selA <= '1'; selB <= '0'; alufs <= "0000"; RmW <= '1'; acc_ld <= '1';
            when EXEC_STO  => selA <= '1'; selB <= '1'; alufs <= "0000"; RmW <= '0'; acc_oe <= '1';
            when EXEC_ADD  => selA <= '1'; selB <= '1'; alufs <= "0010"; RmW <= '1'; acc_ld <= '1';
            when EXEC_SUB  => selA <= '1'; selB <= '1'; alufs <= "0001"; RmW <= '1'; acc_ld <= '1';
            when EXEC_JMP  => selA <= '1'; pc_ld <= '1'; RmW <= '1';
            when EXEC_JGE  => selA <= '1'; pc_ld <= not acc15; RmW <= '1';
            when EXEC_JNE  => selA <= '1'; pc_ld <= not accZ;  RmW <= '1';
            when HALT      => RmW <= '1';
            when others    => RmW <= '1';
        end case;
    end process p_outputs;

    halted <= '1' when current_state = HALT else '0';

end architecture behavioral;
