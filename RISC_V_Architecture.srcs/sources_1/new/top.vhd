----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2025 15:25:18
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port (
        -- INPUTS of the top block
        clk : in std_logic;
        reset : in std_logic
    );
end top;

architecture Behavioral of top is

    ----------------------------
    -- SIGNALS BETWEEN STAGES --
    ----------------------------
    -- Signals Fetch -> Decode
    signal curr_pc_fetch_decode, next_pc_fetch_decode : std_logic_vector(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);
    
    -- Signals Decode -> Execute
    signal curr_pc_decode_execute, next_pc_decode_execute : std_logic_vector(31 downto 0);
    signal rs1_value, rs2_value : std_logic_vector(31 downto 0);
    signal immediate_value : std_logic_vector(31 downto 0);
    signal cond_opcode : std_logic_vector(1 downto 0);
    signal alu_opcode : std_logic_vector(3 downto 0);
    signal a_sel, b_sel : std_logic;
    signal op_class : std_logic_vector(4 downto 0);
    signal register_write_enable_de : std_logic;
    signal rd_forward_de : std_logic_vector(4 downto 0);
    
    -- Signals Execute -> Memory
    signal curr_pc_execute_memory, next_pc_execute_memory : std_logic_vector(31 downto 0);    
    signal branch_cond : std_logic;
    signal alu_result : std_logic_vector(31 downto 0) := (others => '0');
    signal op_class_ex_me: std_logic_vector(4 downto 0);
    signal register_write_enable_em : std_logic;
    signal rd_forward_em : std_logic_vector(4 downto 0);
    
    -- Signals Memory -> WriteBack
    signal next_pc_memory_writeb : std_logic_vector(31 downto 0);
    signal mem_out : std_logic_vector(31 downto 0);
    signal alu_result_mem_wb: std_logic_vector(31 downto 0);
    signal register_write_enable_mw : std_logic;
    signal rd_forward_mw : std_logic_vector(4 downto 0);
    
    -- Signals WriteBack -> Fetch/Decode
    signal next_final_pc : std_logic_vector(31 downto 0);
    signal write_back_value: std_logic_vector(31 downto 0);
    signal register_write_enable_wd : std_logic;
    signal rd_forward_wd : std_logic_vector(4 downto 0);
    
    -------------------------------
    -- SIGNALS FROM CONTROL UNIT --
    -------------------------------
    -- Signals ControlUnit -> Fetch
    signal instruction_load_enable : std_logic;
    -- Signal ControlUnit -> Decode
    signal register_read_write_enable : std_logic;
    -- Signal ControlUnit -> Memory
    signal memory_read_write_enable : std_logic;
    -- Signal to stall
    
begin
    
    -----------------------
    -- Instruction Fetch --
    -----------------------
    fetch_inst : entity work.fetch
    port map (
        -- INPUTS
        clk => clk,
        reset => reset,
        load_enable => instruction_load_enable, --enables the loading of the next pc
        alu_result => alu_result, --pc_out comes from the last stage
        branch_cond => branch_cond,
    
        -- OUTPUTS
        instruction_out => instruction,
        curr_pc_out => curr_pc_fetch_decode
    );
 
    ------------------
    -- Control Unit --
    ------------------   
    control_unit: entity work.control_unit
    port map (
        -- INPUTS
        clk => clk,
        reset => reset,
        instruction => instruction,
        
        -- OUTPUTS
        program_counter_loader => instruction_load_enable,
        read_write_enable_register => register_read_write_enable,
        read_write_enable_memory => memory_read_write_enable
    );

    ------------------------
    -- DECODE Instruction --
    ------------------------ 
    decode_inst : entity work.decode
    port map (
        -- INPUTS
        clk => clk,
        instruction_in => instruction,
        curr_pc_in => curr_pc_fetch_decode,
        write_enable => register_write_enable_wd,
        write_back_value => write_back_value,
    
        -- OUTPUTS
        curr_pc_out => curr_pc_decode_execute,
        opclass => op_class,
        alu_opcode => alu_opcode,
        a_sel => a_sel,
        b_sel => b_sel,
        cond_opcode => cond_opcode,
        immediate_out => immediate_value,
        rs1_value => rs1_value,
        rs2_value => rs2_value,
        
        -- FORWARD LOGIC        
        new_signal_register_write => register_write_enable_de,
        in_rd => rd_forward_wd,
        out_rd => rd_forward_de
    );

    -------------------------
    -- EXECUTE Instruction --
    -------------------------
    execute_inst : entity work.execute
    port map (
        -- INPUTS
        clk => clk,
        reset => reset,
        op_class => op_class,
        
        rs1_value => rs1_value,
        rs2_value => rs2_value,
        curr_pc => curr_pc_decode_execute,
        immediate_value => immediate_value,
        a_sel => a_sel,
        b_sel => b_sel,
        cond_opcode => cond_opcode,
        alu_opcode => alu_opcode,
        
        -- OUTPUTS
        branch_cond => branch_cond,
        op_class_ex_me => op_class_ex_me, 
        alu_result => alu_result,
        
        
        --FORWARD LOGIC
        -- are these really needed?
        curr_pc_out => curr_pc_execute_memory,
        in_forward_instruction_write_enable => register_write_enable_de,
        out_forward_instruction_write_enable => register_write_enable_em,
        in_forward_rd => rd_forward_de,
        out_forward_rd => rd_forward_em
        
    );

    -------------------------------
    -- MEMORY ACCESS Instruction --
    -------------------------------
    memory_access_inst : entity work.memory_access
    port map (
        -- INPUT
        clk => clk,
        alu_result => alu_result,
        rs2_value => rs2_value,
        mem_we => memory_read_write_enable,
        op_class => op_class_ex_me,
        
        -- OUTPUT
        mem_out => mem_out,
        
        -- FORWARD LOGIC
        -- Are these really needed?
        alu_result_out => alu_result_mem_wb,
        out_forward_instruction_write_enable => register_write_enable_mw,
        in_forward_instruction_write_enable => register_write_enable_em,
        in_forward_rd => rd_forward_em,
        out_forward_rd => rd_forward_mw
    );

    ----------------------------
    -- WRITE BACK Instruction --
    ----------------------------
    write_back_inst : entity work.write_back
    port map (
        -- INPUTS
        clk => clk,
        alu_result => alu_result_mem_wb,
        op_class => op_class,
        mem_out => mem_out,
        
        -- OUTPUTS
        rd_value => write_back_value,
        
        -- FORWARD LOGIC
        in_forward_instruction_write_enable => register_write_enable_mw,
        out_forward_instruction_write_enable => register_write_enable_wd,
        in_forward_rd => rd_forward_mw,
        out_forward_rd => rd_forward_wd
        
    );

end Behavioral;
