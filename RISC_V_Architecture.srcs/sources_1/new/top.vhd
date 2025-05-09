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
    -- Fetch -> Decode
    signal curr_pc_fetch_decode : std_logic_vector(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);
    
    -- Decode -> Execute
    signal curr_pc_decode_execute : std_logic_vector(31 downto 0);
    signal rs1_value, rs2_value : std_logic_vector(31 downto 0);
    signal immediate_value : std_logic_vector(31 downto 0);
    signal cond_opcode : std_logic_vector(1 downto 0);
    signal alu_opcode : std_logic_vector(3 downto 0);
    signal a_sel, b_sel : std_logic;
    signal rd_forward_de : std_logic_vector(4 downto 0);
    signal forward_op_class_de : std_logic_vector(4 downto 0);
    
    -- Execute -> Memory
    signal curr_pc_execute_memory : std_logic_vector(31 downto 0);    
    signal branch_cond : std_logic;
    signal alu_result : std_logic_vector(31 downto 0) := (others => '0');
    signal register_read_write_enable_em : std_logic;
    signal memory_read_write_enable_em : std_logic;
    signal rd_forward_em : std_logic_vector(4 downto 0);
    signal rs2_value_forward_em : std_logic_vector(31 downto 0);
    signal forward_op_class_em : std_logic_vector(4 downto 0);
    
    -- Memory -> WriteBack
    signal next_pc_memory_writeb : std_logic_vector(31 downto 0);
    signal mem_out : std_logic_vector(31 downto 0);
    signal alu_result_mem_wb: std_logic_vector(31 downto 0);
    signal register_write_enable_mw : std_logic;
    signal rd_forward_mw : std_logic_vector(4 downto 0);
    signal forward_op_class_mw : std_logic_vector(4 downto 0);
    
    -- WriteBack -> Fetch/Decode
    signal next_final_pc : std_logic_vector(31 downto 0);
    signal write_back_value: std_logic_vector(31 downto 0);
    signal register_write_enable_wd : std_logic;
    signal rd_forward_wd : std_logic_vector(4 downto 0);
    
    -------------------------------
    -- SIGNALS FROM CONTROL UNIT --
    -------------------------------
    -- Signals ControlUnit -> Fetch
    signal instruction_load_enable : std_logic;
    -- Signal ControlUnit -> Execute
    signal register_read_write_enable_ce : std_logic;
    signal memory_read_write_enable_ce : std_logic;
    
begin
    
    -----------------------
    -- FETCH iNSTRUCTION --
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
    -- CONTROL UNIT --
    ------------------   
    control_unit: entity work.control_unit
    port map (
        -- INPUTS
        clk => clk,
        reset => reset,
        instruction => instruction,
        
        -- OUTPUTS
        program_counter_loader => instruction_load_enable,
        read_write_enable_register => register_read_write_enable_ce,
        read_write_enable_memory => memory_read_write_enable_ce
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
        register_write_enable => register_write_enable_wd,
        write_back_value => write_back_value,
    
        -- OUTPUTS
        curr_pc_out => curr_pc_decode_execute,
        opclass => forward_op_class_de,
        alu_opcode => alu_opcode,
        a_sel => a_sel,
        b_sel => b_sel,
        cond_opcode => cond_opcode,
        immediate_out => immediate_value,
        rs1_value => rs1_value,
        rs2_value => rs2_value,
        
        -- FORWARD LOGIC
        rd_address => rd_forward_wd,
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
        in_op_class => forward_op_class_de,
        
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
        out_op_class => forward_op_class_em, 
        alu_result => alu_result,
        
        
        --FORWARD LOGIC
        curr_pc_out => curr_pc_execute_memory,
        in_forward_instruction_write_enable => register_read_write_enable_ce,
        out_forward_instruction_write_enable => register_read_write_enable_em,
        in_forward_memory_write_enable => memory_read_write_enable_ce,
        out_forward_memory_write_enable => memory_read_write_enable_em,
        in_forward_rd => rd_forward_de,
        out_forward_rd => rd_forward_em,
        out_forward_rs2_value => rs2_value_forward_em
        
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
        mem_we => memory_read_write_enable_em,
        
        -- OUTPUT
        mem_out => mem_out,
        
        -- FORWARD LOGIC
        alu_result_out => alu_result_mem_wb,
        in_forward_instruction_write_enable => register_read_write_enable_em,
        out_forward_instruction_write_enable => register_write_enable_mw,
        in_forward_rd => rd_forward_em,
        out_forward_rd => rd_forward_mw,
        in_opclass => forward_op_class_em,
        out_opclass => forward_op_class_mw
    );

    ----------------------------
    -- WRITE BACK Instruction --
    ----------------------------
    write_back_inst : entity work.write_back
    port map (
        -- INPUTS
        clk => clk,
        alu_result => alu_result_mem_wb,
        op_class => forward_op_class_mw,
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
