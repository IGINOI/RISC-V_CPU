----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

entity control_unit is
    Port (
        -- INPUTS of the top block
        clk : in std_logic;
        reset : in std_logic;
    
        -- to understand
        load_enable: in std_logic;
        register_write_enable: in std_logic
    );
end control_unit;

architecture Behavioral of control_unit is
    -- Signals for internal connections between modules
    signal curr_pc, next_pc : std_logic_vector(11 downto 0);
    signal curr_pc_ext, next_pc_ext : std_logic_vector(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);
    signal rs1_value, rs2_value : std_logic_vector(31 downto 0);
    signal immediate_value : std_logic_vector(31 downto 0);
    signal cond_opcode : std_logic_vector(1 downto 0);
    signal alu_opcode : std_logic_vector(3 downto 0);
    signal a_sel, b_sel : std_logic;
    signal branch_cond : std_logic;
    signal alu_result : std_logic_vector(31 downto 0);
    signal mem_out : std_logic_vector(31 downto 0);
    signal op_class : std_logic_vector(4 downto 0);
    signal wea : std_logic;
  
    signal rd_value: std_logic_vector(31 downto 0);
    signal pc_out: std_logic_vector(31 downto 0);
  
    -- Internal signal for control and data memory addresses
    signal addra : std_logic_vector(31 downto 0);
    signal dina : std_logic_vector(31 downto 0);
    signal mem_we : std_logic; -- Memory write enable from control

begin

    -- Instruction Fetch: Fetches instruction from memory
    fetch_inst : entity work.fetch
    port map (
        -- INPUTS
        clk => clk,
        reset => reset,
        load_enable => load_enable, --enables the loading of the next pc
        pc_in => pc_out, --pc_out comes from the last stage
    
        -- OUTPUTS
        instruction_out => instruction,
        curr_pc_out => curr_pc,
        next_pc_out => next_pc
    );

  -- Instruction Decode: Decodes the instruction and prepares signals for the ALU
    decode_inst : entity work.decode
    port map (
        -- INPUTS
        clk => clk,
        instruction_in => instruction,
        curr_pc_in => curr_pc,
        next_pc_in => next_pc,
    
        -- from latter stages
        write_enable => register_write_enable ,
        write_back_value => rd_value,
    
        -- OUTPUTS
        next_pc_out => curr_pc_ext,
        curr_pc_out => next_pc_ext,
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
        next_pc => next_pc_ext,
        
        rs1_value => rs1_value,
        rs2_value => rs2_value,
        curr_pc => curr_pc_ext,
        immediate_value => immediate_value,
        a_sel => a_sel,
        b_sel => b_sel,
        cond_opcode => cond_opcode,
        alu_opcode => alu_opcode,
        
        -- OUTPUTS
        branch_cond => branch_cond,
        alu_result => alu_result,
        
        -- are these really needed?
        curr_pc_out => curr_pc,
        next_pc_out => next_pc
    );

  -- Memory Access: Handles memory read and write operations
    memory_access_inst : entity work.memory_access
    port map (
        -- INPUT
        clk => clk,
        alu_result => alu_result,
        rs2_value => rs2_value,
        mem_we => wea,
        op_class => op_class,
        
        -- OUTPUT
        mem_out => mem_out,
        
        
        -- Are these really needed?
        branch_cond => branch_cond,
        next_pc => next_pc,
        branch_cond_out => branch_cond,  -- Output the branch condition
        next_pc_out => next_pc,          -- Output the next PC
        alu_result_out => alu_result,    -- Output the ALU result
        op_class_out => op_class  
    );

  -- Write-back: Manages the write-back of values to registers and updating the PC
    write_back_inst : entity work.write_back
    port map (
        -- INPUTS
        clk => clk,
        branch_cond => branch_cond,
        next_pc => next_pc,
        alu_result => alu_result,
        op_class => op_class,
        mem_out => mem_out,
        
        -- OUTPUTS
        pc_out => pc_out,
        rd_value => rd_value
    );

end Behavioral;