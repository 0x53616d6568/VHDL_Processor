library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processor is
    port (
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        pc_dbg  : out STD_LOGIC_VECTOR(11 downto 0);
        acc_dbg : out STD_LOGIC_VECTOR(15 downto 0);
        halted  : out STD_LOGIC
    );
end entity processor;

architecture structural of processor is

    component MUX_2_1_12 is
        Port ( d0  : in  STD_LOGIC_VECTOR(11 downto 0);
               d1  : in  STD_LOGIC_VECTOR(11 downto 0);
               sel : in  STD_LOGIC;
               y   : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    component MUX_2_1_16 is
        Port ( d0  : in  STD_LOGIC_VECTOR(15 downto 0);
               d1  : in  STD_LOGIC_VECTOR(15 downto 0);
               sel : in  STD_LOGIC;
               y   : out STD_LOGIC_VECTOR(15 downto 0) );
    end component;

    component processor_fsm is
        port ( clk    : in  STD_LOGIC;
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
               halted : out STD_LOGIC );
    end component;

    component program_counter is
        port ( clk    : in  STD_LOGIC;
               rst    : in  STD_LOGIC;
               pc_ld  : in  STD_LOGIC;
               pc_in  : in  STD_LOGIC_VECTOR(11 downto 0);
               pc_out : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    component instruction_register is
        port ( clk      : in  STD_LOGIC;
               rst      : in  STD_LOGIC;
               ir_ld    : in  STD_LOGIC;
               data_bus : in  STD_LOGIC_VECTOR(15 downto 0);
               opcode   : out STD_LOGIC_VECTOR(3 downto 0);
               operand  : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    component ACCUMULATOR is
        port ( clk      : in  STD_LOGIC;
               rst      : in  STD_LOGIC;
               data_in  : in  STD_LOGIC_VECTOR(15 downto 0);
               data_out : out STD_LOGIC_VECTOR(15 downto 0);
               bus_out  : out STD_LOGIC_VECTOR(15 downto 0);
               acc_ld   : in  STD_LOGIC;
               acc_oe   : in  STD_LOGIC;
               acc_z    : out STD_LOGIC;
               acc_15   : out STD_LOGIC );
    end component;

    component ALU_16bit is
        Port ( A     : in  STD_LOGIC_VECTOR(15 downto 0);
               B     : in  STD_LOGIC_VECTOR(15 downto 0);
               alufs : in  STD_LOGIC_VECTOR(3 downto 0);
               S     : out STD_LOGIC_VECTOR(15 downto 0) );
    end component;

    component MEM_4096x16 is
        Port ( CLK      : in  STD_LOGIC;
               ADDR     : in  STD_LOGIC_VECTOR(11 downto 0);
               DATA_IN  : in  STD_LOGIC_VECTOR(15 downto 0);
               DATA_OUT : out STD_LOGIC_VECTOR(15 downto 0);
               RnW      : in  STD_LOGIC );
    end component;

    signal selA, selB, RmW, ir_ld, pc_ld, acc_ld, acc_oe : STD_LOGIC;
    signal alufs     : STD_LOGIC_VECTOR(3 downto 0);
    signal opcode    : STD_LOGIC_VECTOR(3 downto 0);
    signal accZ      : STD_LOGIC;
    signal acc15     : STD_LOGIC;

    signal pc_out     : STD_LOGIC_VECTOR(11 downto 0);
    signal ir_operand : STD_LOGIC_VECTOR(11 downto 0);
    signal addr_bus   : STD_LOGIC_VECTOR(11 downto 0);
    signal data_bus   : STD_LOGIC_VECTOR(15 downto 0);
    signal mem_data_out : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_data_out : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_bus_out  : STD_LOGIC_VECTOR(15 downto 0);
    signal alu_a, alu_b, alu_s : STD_LOGIC_VECTOR(15 downto 0);

begin

    pc_dbg  <= pc_out;
    acc_dbg <= acc_data_out;

    muxA_inst: MUX_2_1_12
        port map (d0 => pc_out, d1 => ir_operand, sel => selA, y => addr_bus);

    muxB_inst: MUX_2_1_16
        port map (d0 => data_bus, d1 => acc_data_out, sel => selB, y => alu_a);

    alu_b <= "0000" & addr_bus when (alufs = "0011" or pc_ld = '1') else mem_data_out;

    data_bus <= acc_bus_out when (acc_oe = '1') else mem_data_out;

    fsm_inst: processor_fsm
        port map (
            clk => clk, rst => rst,
            opcode => opcode, accZ => accZ, acc15 => acc15,
            selA => selA, selB => selB, alufs => alufs,
            RmW => RmW, ir_ld => ir_ld, pc_ld => pc_ld,
            acc_ld => acc_ld, acc_oe => acc_oe,
            halted => halted
        );

    pc_inst: program_counter
        port map (
            clk => clk, rst => rst,
            pc_ld => pc_ld, pc_in => alu_s(11 downto 0),
            pc_out => pc_out
        );

    ir_inst: instruction_register
        port map (
            clk => clk, rst => rst,
            ir_ld => ir_ld, data_bus => data_bus,
            opcode => opcode, operand => ir_operand
        );

    acc_inst: ACCUMULATOR
        port map (
            clk => clk, rst => rst,
            data_in => alu_s, data_out => acc_data_out,
            bus_out => acc_bus_out,
            acc_ld => acc_ld, acc_oe => acc_oe,
            acc_z => accZ, acc_15 => acc15
        );

    alu_inst: ALU_16bit
        port map (
            A => alu_a, B => alu_b,
            alufs => alufs, S => alu_s
        );

    mem_inst: MEM_4096x16
        port map (
            CLK => clk, ADDR => addr_bus,
            DATA_IN => data_bus, DATA_OUT => mem_data_out,
            RnW => RmW
        );

end architecture structural;
