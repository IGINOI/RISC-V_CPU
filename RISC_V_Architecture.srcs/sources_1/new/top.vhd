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
    -- Signals Execute -> Memory
    signal curr_pc_execute_memory, next_pc_execute_memory : std_logic_vector(31 downto 0);    
    signal branch_cond : std_logic;
    signal alu_result : std_logic_vector(31 downto 0);
    -- Signals Memory -> WriteBack
    signal next_pc_memory_writeb : std_logic_vector(31 downto 0);
    signal mem_out : std_logic_vector(31 downto 0);
    -- Signals WriteBack -> Fetch/Decode
    signal next_final_pc : std_logic_vector(31 downto 0);
    signal write_back_value: std_logic_vector(31 downto 0);
    
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

    -- Instruction Fetch: Fetches instruction from memory
    fetch_inst : entity work.fetch
    port map (
        -- INPUTS
        clk => clk,
        reset => reset,
        load_enable => instruction_load_enable, --enables the loading of the next pc
        pc_in => next_final_pc, --pc_out comes from the last stage
    
        -- OUTPUTS
        instruction_out => instruction,
        curr_pc_out => curr_pc_fetch_decode,
        next_pc_out => next_pc_fetch_decode
    );
    
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

  -- Instruction Decode: Decodes the instruction and prepares signals for the ALU
    decode_inst : entity work.decode
    port map (
        -- INPUTS
        clk => clk,
        instruction_in => instruction,
        curr_pc_in => curr_pc_fetch_decode,
        next_pc_in => next_pc_fetch_decode,
        write_enable => register_read_write_enable,
        write_back_value => write_back_value,
    
        -- OUTPUTS
        curr_pc_out => curr_pc_decode_execute,
        next_pc_out => next_pc_decode_execute,
        opclass => op_class,
        alu_opcode => alu_opcode,
        a_sel => a_sel,
        b_sel => b_sel,
        cond_opcode => cond_opcode,
        immediate_out => immediate_value,
        rs1_value => rs1_value,
        rs2_value => rs2_value
    );

    -- Execute: Performs ALU operations and branch comparisons
    execute_inst : entity work.execute
    port map (
        -- INPUTS
        clk => clk,
        next_pc => next_pc_decode_execute,
        
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
        alu_result => alu_result,
        
        -- are these really needed?
        curr_pc_out => curr_pc_execute_memory,
        next_pc_out => next_pc_execute_memory
    );

  -- Memory Access: Handles memory read and write operations
    memory_access_inst : entity work.memory_access
    port map (
        -- INPUT
        clk => clk,
        alu_result => alu_result,
        rs2_value => rs2_value,
        mem_we => memory_read_write_enable,
        op_class => op_class,
        next_pc => next_pc_execute_memory,
        
        -- OUTPUT
        mem_out => mem_out,
        
        -- Are these really needed?
        branch_cond => branch_cond,
        branch_cond_out => branch_cond,
        next_pc_out => next_pc_memory_writeb,
        alu_result_out => alu_result,
        op_class_out => op_class  
    );

  -- Write-back: Manages the write-back of values to registers and updating the PC
    write_back_inst : entity work.write_back
    port map (
        -- INPUTS
        clk => clk,
        branch_cond => branch_cond,
        next_pc => next_pc_memory_writeb,
        alu_result => alu_result,
        op_class => op_class,
        mem_out => mem_out,
        
        -- OUTPUTS
        pc_out => next_final_pc,
        rd_value => write_back_value
    );

end Behavioral;
