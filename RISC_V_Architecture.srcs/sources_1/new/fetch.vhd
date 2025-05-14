----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2025 15:38:46
-- Design Name: 
-- Module Name: fetch - Behavioral
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

entity fetch is
    Port ( 
        --INPUTS
        clk : in std_logic;
        reset : in std_logic;
        load_enable : in std_logic;
        branch_cond : in std_logic;
        alu_result : in std_logic_vector(31 downto 0);
        
        --OUTPUTS
        instruction_out : out std_logic_vector(31 downto 0);
        curr_pc_out : out std_logic_vector(31 downto 0)
    );
end fetch;

architecture Behavioral of fetch is
    
    --Used to address the instruction memory
    signal current_pc : std_logic_vector(31 downto 0);
    signal next_pc : std_logic_vector(31 downto 0);
    
    --Intruction memory component
    component instruction_memory
        Port(
            -- INPUTS
            clk: in std_logic;
            addr: in std_logic_vector(31 downto 0);
            
            -- OUTPUT
            instruction_out : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    
    -- Manage the loading and resetting of the program counter
    load_reset: process (clk)
    begin
        if rising_edge(clk) then
            -- RESETTING PC
            if reset = '1' then
                current_pc <= (others => '0');  -- If reset is clicked, the pc goes to 0
                curr_pc_out <= (others => '0');   --Also the current pc goes to 0
                next_pc <= (others => '0');
                next_pc(0) <= '1';
            -- LOADING NEXT PC ...
            elsif load_enable = '1' then
                -- ... NORMALLY
                if branch_cond /= '1' then
                    current_pc <= next_pc;
                    curr_pc_out <= next_pc;
                    next_pc <= std_logic_vector(unsigned(next_pc) + 1);
                -- ... JUMPING
                else
                    current_pc <= alu_result;
                    curr_pc_out <= alu_result;
                    next_pc <= std_logic_vector(unsigned(alu_result) + 1);
                end if;
            end if;
        end if; 
    end process load_reset;
    
    -- Fetch instruction from instruction memory
    instr_mem_instantiation : instruction_memory
        port map (
            clk => clk,
            addr => current_pc,
            instruction_out => instruction_out
        );

end Behavioral;