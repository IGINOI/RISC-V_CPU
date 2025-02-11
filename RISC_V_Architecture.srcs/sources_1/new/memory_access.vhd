----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: memory_access - Behavioral
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

entity memory_access is
  Port (
    --INPUTS
    clk : in std_logic;
    
    branch_cond : in std_logic;
    next_pc : in std_logic_vector(31 downto 0);
    alu_result : in std_logic_vector(31 downto 0);
    op_class : in std_logic_vector(4 downto 0);
    rs2_value : in std_logic_vector(31 downto 0);
    mem_we : in std_logic; --coming from control path
    
    --OUTPUTS
    branch_cond_out : out std_logic;
    next_pc_out : out std_logic_vector(31 downto 0);
    alu_result_out : out std_logic_vector(31 downto 0);
    op_class_out : out std_logic_vector(4 downto 0);
    mem_out : out std_logic_vector(31 downto 0)
    
  );
end memory_access;

architecture Behavioral of memory_access is
    
    component data_memory
        Port(
            --INPUTS
            clk : in std_logic;
            
            addra : in std_logic_vector(31 downto 0);
            dina: in std_logic_vector(31 downto 0);
            wea : in std_logic;
            
            --OUTPUTS
            mem_out : out std_logic_vector(31 downto 0)
        );
    end component;
begin
    
    -- Instantiate and connect the instruction memory
    data_mem_instantiation : data_memory
        port map (
            clk => clk,
            addra => alu_result,
            dina => rs2_value,
            wea => mem_we, --CORRECT THIS, ADD THE OR
            mem_out => mem_out
        );

    branch_cond_out <= branch_cond;
    next_pc_out <= next_pc;
    alu_result_out <= alu_result;
    op_class_out <= op_class;

end Behavioral;